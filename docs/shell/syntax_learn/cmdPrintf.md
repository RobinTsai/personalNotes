```sh
#!/bin/bash

# printf 可用于格式化输出，这是 echo 无法做到的
# 格式化操作的方式几乎和 C 语言一样
# 示例：

printf "%-5s %-10s %-4s\n" No Name Mark
echo "  5  |    10    | 4  |"
echo "-----+----------+----+"
printf "%-5s %-10s %-4.2f\n" 1 Cai 5.2343

# %-5s, 's' means 'string', '-' means align left
# %-4.2f, 'f' means 'float'
