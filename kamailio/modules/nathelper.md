# nathelper

[nathelper](https://www.kamailio.org/docs/modules/4.4.x/modules/nathelper.html)

帮助 NAT 穿越及重用 TCP 连接的模块。

|                                             |                                                          |
| ------------------------------------------- | -------------------------------------------------------- |
| Parameters                                  |                                                          |
| `force_socket (string)`                     |                                                          |
| `natping_interval (integer)`                | 向所有注册到 UA 发送 NAT ping 的间隔（保活）             |
| `ping_nated_only (integer)`                 | 仅 Contact 设置了 "behind_NAT" 的进行 ping               |
| `natping_processes (integer)`               |                                                          |
| `natping_socket (string)`                   | 假冒 NAT ping 的源 IP 为此地址                           |
| `received_avp (str)`                        | 用于存储 received IP/port/protocol  的变量               |
| `sipping_bflag (integer)`                   |                                                          |
| `sipping_from (string)`                     |                                                          |
| `sipping_method (string)`                   | 生成 SIP ping 请求 Request 的 方法名，默认 OPTIONS       |
| `natping_disable_bflag (integer)`           |                                                          |
| `nortpproxy_str (string)`                   |                                                          |
| `keepalive_timeout (int)`                   |                                                          |
| `udpping_from_path (int)`                   |                                                          |
| `append_sdp_oldmediaip (int)`               |                                                          |
| `filter_server_id (int)`                    |                                                          |
| Functions                                   |                                                          |
| `fix_nated_contact()`                       |                                                          |
| `fix_nated_sdp(flags [, ip_address])`       | 转换 SDP info 促进 NAT 穿越                              |
|                                             | - `0x01` 增加 `a=` 行，`0x02` 重写 `c=` 行，             |
|                                             | - `0x04` 增加 `a=nortpproxy:yes` 行，`0x08` 重写 `o=` 行 |
| `add_rcv_param([flag]),`                    | 在 Contact 中增加 `received` 参数                        |
| `fix_nated_register()`                      | 使用 src ip port 和 protocol 创建 URI，并存到 AVP 中     |
| `nat_uac_test(flags)`                       | guess Client 是否在 NAT 后面                             |
| `is_rfc1918(ip_address)`                    | rfc1918 规定了内网地址的范围，本函数判断是否是内网地址   |
| `add_contact_alias([ip_addr, port, proto])` |                                                          |
| `handle_ruri_alias()`                       |                                                          |
| `set_contact_alias()`                       |                                                          |
| Exported Pseudo Variables                   |                                                          |
| `$rr_count`                                 | SIP Record Route 的个数                                  |
| `$rr_top_count`                             |                                                          |
