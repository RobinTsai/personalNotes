# textops

[textops](https://www.kamailio.org/docs/modules/4.4.x/modules/textops.html)

操作 SIP 文本，提供了正则查询、替换、检查、插入等操作。

> SIP 中 Header 和 body 之间通过一个空行分割。

> 已知的限制，如果 Header 换行了，就查不到了。

 | func                                                        | desc                                                           |
 | ----------------------------------------------------------- | -------------------------------------------------------------- |
 | `search(re)`                                                |                                                                |
 | `search_body(re)`                                           | 查询 body 中是否包含 re                                                               |
 | `search_hf(hf, re, flags)`                                  | search header field                                            |
 | `search_append(re, txt)`                                    |                                                                |
 | `search_append_body(re, txt)`                               |                                                                |
 |                                                             |                                                                |
 | `replace(re, txt)`                                          |                                                                |
 | `replace_body(re, txt)`                                     |                                                                |
 | `replace_all(re, txt)`                                      |                                                                |
 | `replace_body_all(re, txt)`                                 | 将 body 中所有匹配向替换为 txt |
 | `replace_body_atonce(re, txt)`                              |                                                                |
 | `subst('/re/repl/flags')`                                   |                                                                |
 | `subst_uri('/re/repl/flags')`                               |                                                                |
 | `subst_user('/re/repl/flags')`                              |                                                                |
 | `subst_body('/re/repl/flags')`                              |                                                                |
 | `subst_hf(hf, subexp, flags)`                               |                                                                |
 | `set_body(txt,content_type)`                                |                                                                |
 | `set_reply_body(txt,content_type)`                          | 设置响应的 body 为 txt 文本，用 content_type                                                                |
 |                                                             |                                                                |
 | `filter_body(content_type)`                                 | 过滤出指定类型的 Content-Type header                           |
 | `append_to_reply(txt)`                                      | 追加 header 用于响应                                           |
 | `append_hf(txt[, hdr])`                                     | 追加 txt 的 header                                             |
 | `insert_hf(txt[, hdr])`                                     | 插入 txt 的 header                                             |
 | `append_urihf(prefix, suffix)`                              |                                                                |
 | `is_present_hf(hf_name)`                                    |                                                                |
 | `is_present_hf_re(hf_name_re)`                              |                                                                |
 | `append_time()`                                             |                                                                |
 | `append_time_to_request()`                                  |                                                                |
 | `is_method(name)`                                           | 判断 method  `invite, cancel, ack, bye, options, info, update` |
 |                                                             | - `register, message, subscribe, notify, refer, prack`         |
 |                                                             | - 用于 reply 时判断 CSeq 中的 method    |
 | `remove_hf(hname)`                                          |                                                                |
 | `remove_hf_re(re)`                                          |                                                                |
 | `has_body(), has_body(mime)`                                | 判断是否包含 `Content-Length`                                                              |
 | `is_audio_on_hold()`                                        |                                                                |
 | `is_privacy(privacy_type)`                                  | 判断是否有隐私 header 值（定义在 RFC3323 中）                                                               |
 | `in_list(subject, list, separator)`                         |                                                                |
 | `cmp_str(str1, str2)`                                       |                                                                |
 | `cmp_istr(str1, str2)`                                      |                                                                |
 | `starts_with(str1, str2)`                                   |                                                                |
 | `set_body_multipart([txt,content_type][,boundary])`         |                                                                |
 | `append_body_part(txt,content_type[, content_disposition])` |                                                                |
 | `get_body_part(content_type, opv)`                          |                                                                |
 | `get_body_part_raw(content_type, opv)`                      |                                                                |
 | `remove_body_part(content_type)`                            |                                                                |
