```sh
#!/bin/bash

echo -e "\e[1;42mGlobal Regular Expression Print\e[0m"

echo ''
echo $(grep)

echo -e '\e[1;43mgrep "PS1=\"" ~/.bashrc\e[0m'
grep "PS1=\"" ~/.bashrc

echo ''
echo -e "\e[1;42mIt also can use together with '|'\e[0m"
cat ~/.bashrc | grep "PS1=\""
