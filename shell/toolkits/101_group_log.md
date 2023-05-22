# group and count by match

```sh
awk '
{
    group_key=$1;

    # 如果尚未处理该分组，请将其初始化为 0
    if (!group_total[group_key]) {
        group_total[group_key] = 0;
    }

    # 将值添加到当前分组的总和中
    group_total[group_key] += 1;
}

END {
    # 遍历每个分组并输出结果
    for (group_key in group_total) {
        print group_key, group_total[group_key];
    }
}' input_file
```

思路：

1. 先筛选行
2. 切分每行的列，只剩下关键列


```sh
grep 'msglog/send_msg_acks' 413.log | grep '\[20/May/2023' | sed -e 's/.*\[20\/May\/2023://g' -e 's/\+0800\] "//g' -e 's/HTTP\/1.1".*$//g' -e 's/ \//_/g' -e 's/\//_/g'
```
