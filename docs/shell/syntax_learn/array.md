
```sh
#!/bin/bash

echo -e "\e[1;42mDefine & use like normal variable\e[0m "
array_var=(0 1 2 3 4 5)           # 括号用于初始化数组
echo ${array_var[*]}              # $arr[*] 用于输出所有元素

echo "length: ${#array_var[*]}"   # ${#var} 用于输出 var 的 length

echo -e "\e[1;42mdeclare\e[0m Set associate array"
declare -A ass_arr
ass_arr=([index1]="val1" [index2]="val2")
ass_arr[index3]="var3"
echo ${ass_arr[*]}

echo -e "\e[1;42m\${!arr[*]}\e[0m List index"
echo "Use * or @, both is ok"
echo ${!ass_arr[*]}   # * or @ is ok
echo ${!ass_arr[@]}
