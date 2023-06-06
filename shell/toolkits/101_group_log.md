# group and count by match

```sh
input_file=""
awk '{
    group_key=substr($1,1,3);

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
}' $input_file | sort



awk 'BEGIN {
    group_total["InvalidChar"] = 0;
    group_total["TokenWrong"] = 0;
}

{
    if ($0 ~ /looking for beginning of value/) {
        group_total["InvalidChar"] += 1;
    } else if ($0 ~ /Connect Token Wrong/) {
        group_total["TokenWrong"] += 1;
    } else {
        group_total["else"] += 1;
    }
}

END {
    for (group_key in group_total) {
        print group_key, group_total[group_key];
    }
}' tower-err-3w.log
```

思路：

1. 先筛选行
2. 切分每行的列，只剩下关键列


```sh
grep 'msglog/send_msg_acks' 413.log | grep '\[20/May/2023' | sed -e 's/.*\[20\/May\/2023://g' -e 's/\+0800\] "//g' -e 's/HTTP\/1.1".*$//g' -e 's/ \//_/g' -e 's/\//_/g'
```
