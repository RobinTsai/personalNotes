# confd

[官方文档 confd/docs - github.com](https://github.com/kelseyhightower/confd/tree/master/docs)

## 简介

- 是什么：
  - Go 代码写的，一个小工具
  - 一个轻量级配置管理工具
  - 实现了从某个后端存储中拉取配置信息，使用某规则，应用到模板生成对应配置文件，并最终执行配置生效的命令。
- 支持的后端存储：
  - file / etcd / consul / dynamodb / zookeeper / redis / vault / 环境变量 / aws_ssm_parameter_store 等等

## 安装

它是用就是一个 Go 库，线上有直接可用的二进制文件，也可以自己用 go 进行编译安装。

下载对应系统版本的二进制文件，重命名放到可执行目录即可。

```sh
wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64
mv confd-0.16.0-linux-amd64 /usr/local/bin/confd
chmod +x /usr/local/bin/confd
confd --help
```

confd 通过读取存储的配置信息，动态更新到配置文件中。后端存储可以是 etcd 或 redis。

## 线上案例使用 redis

目录：

```sh
- . # 安装目录
- confd.toml # 配置文件，confd 进程的配置信息
- bin/       # 放置 confd 运行的脚本的目录
- conf.d/    # 配置文件目录，这里每个配置文件配置一个从监听到生成配置再到生效配置的一个过程
    - vars.xml.toml  # 过程配置文件：一个从监听到生成配置再到生效配置的一个过程
    - ...
- templates/  # 模板目录，存放模板配置文件
    - vars.xml.tpl   # 模板赔偿文件：用于填充配置信息生成配置文件
    - ...
```

举例：如下为 confd 进程配置，及一个过程配置-根据 ipWhiteList 配置文件生成配置文件，并执行命令。

```sh
# confd.toml                # confd 配置文件
backend = "redis"           # 使用 redis 作为后端（backend）存储
confdir = "/usr/local/confd"  # confd 配置文件所在目录。内部要有 conf.d/ 和 templates/ 两个子目录
nodes = ["10.13.119.92:6747/1"]  # backend 节点列表
client_key = "GyhKzK3CRXKmA7vD"  # 授权信息
interval = 6                     # 检查间隔
log-level = "info"               # 日志级别

# conf.d/ipwl.lua.toml # 过程配置文件
[template]
prefix = "/uSbc:v1:/uSbc"
src = "ipwl.lua.tpl"      # 指 templates/ipwl.lua.tpl 模板文件
dest = "/usr/local/freeswitch/scripts/ipwl.lua" # 生成到这个位置
keys = [                                        # 监听的 keys
        "/ipWhiteList/external",
        "/ipWhiteList/internal",
]
reload_cmd = "/usr/local/confd/bin/donothing.sh ipwl.lua" # 重载命令

# templates/ipwl.lua.tpl  # 语法参考 Go 模板语法
IPWL = {}
IPWL.internal = {
  {{range jsonArray (getv "/ipWhiteList/internal") -}}
  {"{{.sipProfileName}}", "{{.srcIp}}", {{.srcPort}}, "{{toLower .protocolStr}}"},
  {{end -}}
}
IPWL.external = {
  {{range jsonArray (getv "/ipWhiteList/external") -}}
  {"{{.sipProfileName}}", "{{.srcIp}}", {{.srcPort}}, "{{toLower .protocolStr}}"},
  {{end -}}
}
return IPWL
```

## 源码剖析

- 监听方式有两种，
  - （默认）一种是周期性主动获取的方式实现
  - 另一种是使用 backend 自带的 watch 监听
- redis 获取配置看配置的 key，内部会判断 TYPE（注一）
  - 如果是 string，直接获取值
  - 如果是 hash，会 `HSCAN` key 下所有 field，获取所有 key/field => value
  - 其他情况，会 `SCAN key*`，获取所有 key => value
- redis 的 watch 监听是通过 PubSub 实现的
  - PubSub 监听通过订阅 **键空间通知** （`__keyspace@<db>__:<key_pattern>`）实现
  - PubSub 收到事件后，还是会通过 注一 位置的方式获取一遍数据
  - 疑问：这里 confd 没有检查 notify-keyspace-events 的配置，也没看到文档提？
- confd 内存中存有所有获取的信息，先清空然后再建，建立之后生成临时文件，比较源文件和临时文件是否变动，变动则更新。
