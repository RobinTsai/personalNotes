# dispatcher

[dispatcher](https://kamailio.org/docs/modules/4.4.x/modules/dispatcher.html#dispatcher.p.ds_ping_interval)

```sh
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
