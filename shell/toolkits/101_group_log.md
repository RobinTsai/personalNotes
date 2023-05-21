# group and count by match

```sh
#!/bin/bash
awk '
{
    field=$1;
    value=$2;

    # 如果尚未处理该分组，请将其初始化为 0
    if (!group_total[field]) {
        group_total[field] = 0;
    }

    # 将值添加到当前分组的总和中
    group_total[field] += value;
}

END {
    # 遍历每个分组并输出结果
    for (field in group_total) {
        print field, group_total[field];
    }
}' input_file
```

思路：

1. 先筛选行
2. 切分每行的列，只剩下关键列


```sh
grep 'msglog/send_msg_acks' 413.log | grep '\[20/May/2023' | sed ''
```
