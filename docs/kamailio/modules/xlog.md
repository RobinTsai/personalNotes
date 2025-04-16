# xlog

[xlog](https://www.kamailio.org/docs/modules/5.0.x/modules/xlog.html)


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
