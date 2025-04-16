# rtpproxy

[rtpproxy](https://www.kamailio.org/docs/modules/4.4.x/modules/rtpproxy.html)

|                                            |                                                     |
| ------------------------------------------ | --------------------------------------------------- |
| Parameters                                 |                                                     |
| `rtpproxy_sock (string)`                   | 定义 RTPProxy 的连接地址                            |
| `rtpproxy_disable_tout (integer)`          | 一旦 RTPProxy 连接超时，则标记为不可用状态          |
| `rtpproxy_tout (integer)`                  | 判断 RTPProxy 连接超时的时长                        |
| `rtpproxy_retr (integer)`                  | RTPProxy 超时后 retry 次数                          |
| `nortpproxy_str (string)`                  | 用于标记 SDP 已经被改变（必须包含 `\r\n`）          |
| `timeout_socket (string)`                  | 判断 RTPProxy 连接的超时时间                        |
| `ice_candidate_priority_avp (string)`      |                                                     |
| `extra_id_pv (string)`                     |                                                     |
| `db_url (string)`                          |                                                     |
| `table_name (string)`                      |                                                     |
| `rtp_inst_pvar (string)`                   | 存储 RTPProxy 地址的 PV                             |
| Functions                                  |                                                     |
| `set_rtp_proxy_set(setid)`                 | 设置用于 RTPProxy 的 setid                          |
| `rtpproxy_offer([flags [, ip_address]])`   | 重新 SDP 保证 media 经过 RTPProxy（INVITE/200/ACK） |
| `rtpproxy_answer([flags [, ip_address]])`  | 用于 `REQUEST_ROUTE, ONREPLY_ROUTE, FAILURE_ROUTE, BRANCH_ROUTE`                                                    |
| `rtpproxy_destroy([flags])`                |                                                     |
| `unforce_rtp_proxy()`                      |                                                     |
| `rtpproxy_manage([flags [, ip_address]])`  |                                                     |
| `rtpproxy_stream2uac(prompt_name, count),` |                                                     |
| `rtpproxy_stream2uas(prompt_name, count)`  |                                                     |
| `rtpproxy_stop_stream2uac(),`              |                                                     |
| `rtpproxy_stop_stream2uas()`               |                                                     |
| `start_recording()`                        |                                                     |
| Exported Pseudo Variables                  |                                                     |
| `rtpstat`                                  |                                                     |
