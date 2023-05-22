# date

```sh
date +%Y-%m-%d\ %H:%M:%S # 2023-04-25 11:02:31，man date 查看格式化
date -d last-day         # 输出昨天, -d, --date=STRING，STRING 描述日期
date -I           # 2023-04-25
date -Ihours      # 2023-04-25T11+08:00
date -Iminutes    # 2023-04-25T11:04+08:00
date -Iseconds    # 2023-04-25T11:05:06+08:00
date -Ins         # 2023-04-25T11:05:54,453587551+08:00
```
