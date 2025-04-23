```sh
#!/bin/bash

echo -e "\e[1;31m This is red text \e[0m color return back"
echo -e "\e[1;30m This is black text"
echo -e " also black"
echo -e "\e[0m This is normal color"
echo -e "set color use this: \e[1;32m green"
echo -e "reset color use this: \e[0m normal"
echo -e "\e[1;41m The same method. \e[0m reset"
echo ""
echo "font color:       0, 30, 31, 32, 33, 34, 35,  36, 37"
echo "background color: 0, 40, 41, 42, 43, 44, 45,  46, 47"
echo "对应分别是:     重置, 黑, 红, 绿, 黄，蓝,洋红, 青, 白"

echo -n "This is one echo."
echo " But remove \\n."
echo ""

# -e 表示包含 转义序列 的字符串  => ???
# -n 可以去除末尾的换行符
