```sh
#!/bin/bash

echo -e "\e[1;41mYou should use 'source' command to run this file.\e[0m"
# echo -e "\e[1;42m这些命令可以在命令行里实现，但在文件中是不可以的，我还不知道为什么\e[0m "
alias update='free'
update

echo ""
alias rm="cp $@ ~/backup; rm $@"
# There is an error about cp, but I don't know how to deal it.
touch a.txt
echo "I love you" > a.txt
rm a.txt

echo -e "There \e[1;42m\$@\e[0m means the follow file."

echo -e -n "Use command \e[1;42m"
echo -n "\\rm"
echo -e "\e[0m to execute the actual rm"
