# 变量

## 自定义全局变量

自定义全局变量是可以通过 RPC 命令在运行时更改值的。

```sh
# define
group.variable = value desc "description"
# use
$sel(cfg_get.group.variable)

# example define
pstn.gw_ip = "1.2.3.4" desc "PSTN GW Address"
# example use
$ru = "sip:" + $rU + "@" + $sel(cfg_get.pstn.gw_ip)
```
