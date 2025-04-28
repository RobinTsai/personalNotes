# dispatcher

[dispatcher](https://kamailio.org/docs/modules/4.4.x/modules/dispatcher.html#dispatcher.p.ds_ping_interval)

用于提供 SIP 的流量负载能力。

可以用于无状态的负载均衡，不依赖于呼叫状态。

依赖模块：

- TM 模块。如果要实现自动发现网关的活动状态，则必须依赖于 TM 模块。
- 数据库引擎。如果用数据库，而不用文本文件，则必须依赖于 数据库引擎。

函数说明：

- `ds_select_dst(set, alg[, limit])`: 从 set 中选择一个负载地址，返回 bool，并将地址存到 `dst_uri` （`$du` 变量）中
- `insert into dispatcher (setid, destination, description) values("2", "sip:121.36.218.123:5474", "d3 cti");`

## 使用

> 多看模块文档中的配置文件。
> 可以使用 `kamctl dispatcher` 命令执行部分操作。

```sh
# 配置文件
route[DISPATCH] {
	if(ds_select_dst("2", "0")) {
		route(RELAY);
		exit;
	}
	send_reply("404", "No destination");
	exit;
}
```

## RPC 命令

```sh
# 重新 reload
./sbin/kamcmd dispatcher.reload
# 标记为 inactive, 这种情况下在 options probing 成功后会自动恢复
./sbin/kamcmd dispatcher.set_state ip 1 sip:8.215.102.230:5474
# 标记为 diable，这种情况下不再进行探测
./sbin/kamcmd dispatcher.set_state d 1 sip:8.215.102.230:5474
# 查看 dispatcer 后端负载列表信息
./sbin/kamcmd dispatcher.list
# 关闭（0）或打开（1） options probing
./sbin/kamcmd dispatcher.ping_active 0
```

## 关于自动负载的情况调查

在如下配置下：

```ini
modparam("dispatcher", "ds_ping_method", "OPTIONS")  # 使用 Options 方法做 ping
modparam("dispatcher", "ds_ping_interval", 30)       # 30s 一次 Options

modparam("dispatcher", "flags", 2) # 2 启动故障转移 failover；1 仅 URI 中用户名用于 hash 计算；默认 0，username+hostname+port 用于 hash 计算

modparam("dispatcher", "dst_avp", "$avp(AVP_DST)") # 用 failover 时必须是设置，存储地址列表的变量
modparam("dispatcher", "grp_avp", "$avp(AVP_GRP)") # 用 failover 时必须是设置，存储分组列表的变量
modparam("dispatcher", "cnt_avp", "$avp(AVP_CNT)") # 用 failover 时必须是设置，存储地址个数的变量

modparam("dispatcher", "ds_ping_interval", 30)      # ping 时间间隔 30s（包含重传时间）
modparam("dispatcher", "ds_probing_mode", 1)        # ping 模式；1 所有地址均测试；0/2/3 略
modparam("dispatcher", "ds_probing_threshold", 3)   # 指定 3 次的 ping 失败后标记为 inactive
                                                    # 第一次 ping 超时后标记为 TP 状态
                                                    # 第 3 次 ping 超时后标记为 IP 状态
```

- `IP` 状态（`dispatcher.list` 看到）中 `I` 表示 `Inactive`，`P` 表示 `Probing`，另外 `A` 表示 `Active`，`T` 表示 `Trying`；
- 第一次 ping 失败之后就会变成 `T` 状态，这里 "ping 失败"是指从开始发 ping 到重传超时才认为是失败
- 指定 `ds_probing_threshold` 次 ping 失败后就标记为 `I` 状态（在这之前都是 `T` 状态）
- `IP` 状态下才不会负载，`TP` 状态下还是有可能负载的
- `ds_ping_interval` 只标记的是 ping 开始的时间，重传不会打乱这个时间。

## 调试集成

```sh
# 第一步：集成配置，注意按模块文档添加配置，变更项列如下
loadmodule "dispatcher.so"
loadmodule "db_sqlite.so"

modparam("rr", "enable_full_lr", 1)

## ----- debugger params -----
modparam("dispatcher", "db_url", DBURL)
modparam("dispatcher", "table_name", "dispatcher")
modparam("dispatcher", "flags", 2)
modparam("dispatcher", "dst_avp", "$avp(AVP_DST)")
modparam("dispatcher", "grp_avp", "$avp(AVP_GRP)")
modparam("dispatcher", "cnt_avp", "$avp(AVP_CNT)")
modparam("dispatcher", "sock_avp", "$avp(AVP_SOCK)")

## 在 route[REGISTRAR] 中，注释 if (!save("location")) 块，添加路由到 DISPATCH
route(DISPATCH);

## 添加路由块函数（注册 OK）
route[DISPATCH] {
	if(ds_select_dst("2", "0")) {
		route(RELAY);
		exit;
	}
	send_reply("404", "No destination");
	exit;
}

## 但是 BYE 的时候，服务端发来 Bye，Kaml 转发到了话机所在内网地址。
## 定位是因为注册的使用 Contact 地址没有更新成来源的公网地址，所以需要如下操作

## 开启 WITH_NAT 定义
#!define WITH_NAT
## 在 route[NATDETECT] 块中注册消息中去掉 fix_nated_register() 加入
fix_nated_contact();
```
