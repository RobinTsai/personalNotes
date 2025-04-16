# sdpops

[sdpops](https://www.kamailio.org/docs/modules/4.4.x/modules/sdpops.html)

提供了检查和操作 SDP 内容的方法。

| Functions                                 |                                                                                           |
| ----------------------------------------- | ----------------------------------------------------------------------------------------- |
| `sdp_remove_codecs_by_id(list)`           |                                                                                           |
| `sdp_remove_codecs_by_name(list)`         |                                                                                           |
| `sdp_remove_line_by_prefix(string)`       |                                                                                           |
| `sdp_keep_codecs_by_id(list [, mtype])`   |                                                                                           |
| `sdp_keep_codecs_by_name(list [, mtype])` |                                                                                           |
| `sdp_with_media(type)`                    | 判断 `media=type ...` 是否存在                                                            |
| `sdp_with_active_media(type)`             | 判断 `media=type ...` 是否存在，且是否是活动状态                                          |
| `sdp_remove_media(type)`                  | 判断 SDP 是否有 `media=media port type ...` 行                                            |
| `sdp_with_transport(type)`                |                                                                                           |
| `sdp_with_transport_like(type)`           |                                                                                           |
| `sdp_transport(pv)`                       |                                                                                           |
| `sdp_remove_transport(type)`              |                                                                                           |
| `sdp_with_codecs_by_id(list)`             |                                                                                           |
| `sdp_with_codecs_by_name(list)`           |                                                                                           |
| `sdp_print(level)`                        | 用 level 级别输出 SDP 的结构                                                              |
| `sdp_get(avpvar)`                         | 存储 SDP 到 AVP 中，成功返回 1，错误 -1，不存在 SDP -2                                    |
| `sdp_content([sloppy])`                   | 判断是否错在 SDP                                                                          |
| `sdp_with_ice()`                          |                                                                                           |
| `sdp_get_line_startswith(avpvar, string)` | 匹配 SDP 中以 string 开头的行，存储到 AVP 中，成功返回 1，错误返回 -1，不存在 SDP 返回 -2 |
