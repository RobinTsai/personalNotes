```sh
#!/bin/bash

echo -e "\e[1;42mtrap 'commands' signals\e[0m "
echo "http://codingstandards.iteye.com/blog/836588"

echo "linux sigint, and terminal signals: EXIT, DEBUG, ERR, RETURN"

echo -e "\e[1;42mINT\e[0m \t Ctrl+C"
echo -e "\e[1;42mHUP\e[0m \t SIGHUP(网络断开)"
echo -e "\e[1;42mDEBUG\e[0m \t 在脚本打印信息时"
echo -e "\e[1;42mERR\e[0m \t 当退出码 != 0"
echo -e "\e[1;42mRETURN\e[0m \t retrun from shell, or source another shell."

echo "Will sleep 10s"
echo "Try to input Ctrl+C"
trap "" INT # when Ctrl+C run "", if you input sth in "", this sleep will end
sleep 10;

echo -e "\n\e[1;42m-p\e[0m type the signal"
trap -p INT # type out the signal

echo -e "\e[1;42m-l\e[0m list all signal"
trap -l     # type out all signals
