# Core Functions

[Core Functions](https://www.kamailio.org/wikidocs/cookbooks/4.4.x/core/#core-functions)

一般函数

[flag operators]:https://www.kamailio.org/wikidocs/tutorials/kamailio-flag-operations/
[Debug syslog msg]:https://www.kamailio.org/dokuwiki/doku.php/tutorials:debug-syslog-messages

|                                         |                                                                                               |
| --------------------------------------- | --------------------------------------------------------------------------------------------- |
| `add_local_rport`                       |                                                                                               |
| `avpflags`                              |                                                                                               |
| `break`                                 | ...                                                                                           |
| `error`                                 | ...                                                                                           |
| `exec`                                  | ...                                                                                           |
| `drop`                                  | 丢弃包，不处理                                                                                |
| `exit`                                  | 停止脚本的执行，和 `return(0)` 效果一样，不影响后面的脚本的隐式操作                 |
| `force_rport()`                         | 增加 rport 信息到首个 Via 头，用于 NAT 穿越                                                   |
| `add_rport()`                           | 等同于 `force_rport()`                                                                        |
| `force_send_socket([protocal:]ip:port)` | 强制使用指定 socket 发送包，这个 Socket 一定要 `listen`                                       |
| `force_tcp_alias([port])`               | 在 tcp 通信下，增加 tcp port alias，这样会使用相同的连接进行交互，不传 port 默认使用 via port |
| `add_tcp_alias()`                       | 等同于 `force_tcp_alias()`                                                                    |
| `forward`                               | 使用 `$du` 中的值发送 SIP 请求                                                                |
| `isavpflagset`                          | ...                                                                                           |
| `isflagset`                             | [flag operators] 0-31 共 32 个标志位                                                          |
| `is_int`                                | 检查是否 *?包含?* 数字                                                                        |
| `log([level,] msg)`                     | [Debug syslog msg] 输出日志到 stderr 或 syslog                                                |
| `prefix(str)`                           | 在 R-URI 前增加 str                                                                           |
| `resetavpflag`                          | ...                                                                                           |
| `resetflag`                             | ...                                                                                           |
| `return`                                |                                                                                               |
| `revert_uri`                            | 回滚对 R-URI 的所有修改                                                                       |
| `rewritehostport(str)`                  | 使用 str 重写 R-URI 的 hostport 部分                                                          |
| `sethostport`/ `sethp`                  | 同上                                                                                          |
| `rewritehostporttrans`                  |                                                                                               |
| `rewritehost(host)`                     | Host of R-URI, alias `sethost, seth`                                                          |
| `rewriteport(port)`                     | Port of R-URI, alias `setport, setp`                                                          |
| `rewriteuri(uri)`                       | R-URI, alias `seturi`                                                                         |
| `rewriteuserpass`                       | alias `setuserpass, setup`                                                                    |
| `rewriteuser`                           | User part of R-URI, alias `setuser, setu`                                                     |
| `route(name)`                           | 路由到块                                                                                      |
| `set_advertised_address`                |                                                                                               |
| `set_advertised_port`                   |                                                                                               |
| `set_forward_no_connect`                | 当且仅当存在 TCP/TLS 连接到时候，使用现有连接进行转发                                         |
| `set_forward_close`                     | 发出当前 msg 后关闭连接                                                                       |
| `set_reply_no_connect`                  | 用于响应                                                                                      |
| `set_reply_close`                       | 用于响应                                                                                      |
| `setavpflag`                            |                                                                                               |
| `setflag`                               | 支持 0-31 数值                                                                                |
| `strip(N)`                              | strip fisrt N-th characters  from username of R-URI                                           |
| `strip_tail`                            | lath N-th                                                                                     |
| `udp_mtu_try_proto(proto)`              |                                                                                               |
| `userphone`                             | ...                                                                                           |
