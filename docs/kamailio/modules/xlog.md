# xlog

[xlog](https://www.kamailio.org/docs/modules/5.0.x/moaadules/xlog.html)

日志目录的配置参考 [一些配置项](../209_一些配置项.md)

提供了能力按用户指定格式输出日志，类似于 C 中的 printf 函数。

与早期 Kamailio 版本的不同：

- `%` 替换成 `$`
- 打印 header，使用 `$hdr(header_name[index])` 而不是 `%hdr(header_name[index]) `
- 打印 AVP，使用 `$avp([si]:avp_id[index])` 或 `$avp([$avp_alias[index])` 而不是 `%{[si]:avp_id[index]}` 或 `%{[$avp_alias[index]}`


- level 参数
    - L_ALERT - log level -5
    - L_BUG - log level -4
    - L_CRIT - log level -3
    - L_ERR - log level -1
    - L_WARN - log level 0
    - L_NOTICE - log level 1
    - L_INFO - log level 2
    - L_DBG - log level 3
    - $pv - any valid pseudo-variable, that has an integer value. See above options for valid log levels.

|                                       |     |
| ------------------------------------- | --- |
| `buf_size (integer)`                  |     |
| `force_color (integer)`               |     |
| `long_format (integer)`               |     |
| `prefix (str)`                        |     |
| `log_facility (string)`               |     |
| `log_colors (string)`                 |     |
| `methods_filter (int)`                |     |
| `Functions`                           |     |
| `xlog([ [facility,] level,] format)`  | 输出格式化的 log     |
| `xdbg(format)`                        |     |
| `xinfo(format)`                       |     |
| `xnotice(format)`                     |     |
| `xwarn(format)`                       |     |
| `xerr(format)`                        |     |
| `xbug(format)`                        |     |
| `xcrit(format)`                       |     |
| `xalert(format)`                      |     |
| `xlogl([ [facility,] level,] format)` |     |
| `xdbgl(format)`                       |     |
| `xlogm(level, format)`                |     |
