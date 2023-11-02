# group and count by match

```sh
# 按固定位置子字符串进行分组
input_file="monitor-chan-overflow-time.log"
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


# 按不同的匹配模式进行分组
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
        printf("%10s %s\n", group_total[group_key], group_key);
    }
}' tower-err-3w.log


# 按截取子字符串进行分组，注意使用变量不需要加 $ 符号
awk 'BEGIN {}
{
    if ($0 ~ /\/ccapi\/v2\/monitor/) {
        last=substr($0, index($0, "AppId="))
        appId=substr(last, 0, index(last, "&"))

        if (!group_total[appId]) {
            group_total[appId] = 0;
        }

        group_total[appId] += 1;
    }
}
END {
    for (group_key in group_total) {
        print group_key, group_total[group_key];
    }
}' access.log
```

思路：

1. 先筛选行
2. 切分每行的列，只剩下关键列


```sh
grep 'msglog/send_msg_acks' 413.log | grep '\[20/May/2023' | sed -e 's/.*\[20\/May\/2023://g' -e 's/\+0800\] "//g' -e 's/HTTP\/1.1".*$//g' -e 's/ \//_/g' -e 's/\//_/g'
```

截取某一子字符串

```sh
substr(string, start, length)
awk '{print substr($0, 1, index($0, ":")-1)}' /etc/passwd
```
