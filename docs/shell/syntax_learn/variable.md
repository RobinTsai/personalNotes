```sh
#!/bin/bash

echo -e "\e[1;42mAttention: no space around '='.\e[0m"
var="Hello, I'm Robin."

echo $var
echo ${var}


var2=5
echo -e "\e[1;42mBoth of them can be used in double quote\e[0m" # \e 换成 \033 可以在 awk 脚本中用
echo -e "\e[1;42mBut can not in sigle quote\e[0m"
echo "$var2"    # => 5
echo "${var2}"  # => 5
echo '${var2}'  # => ${var2}
echo '$var2'    # => $var2

# VARIABLE=$(COMMAND) # attention no space between =
red_f="$(tput setaf 1)"  # setab->background color
green_b="$(tput setab 2)"
yellow_b="$(tput setab 3)"  # setaf->font color
blue="$(tput setaf 4)"
bold="$(tput bold)"
normal="$(tput sgr0)"

echo -e "\n${green_b}${bold}Slice String:${normal}\n"
string="This Is A String, This Is A Test"

echo "${red}${yellow_b}${string}${normal}"
# '#*...    %...*'
echo "${string#*s}"     # '#*reg' remove the FRONT str at the place that 'reg' FIRST show
echo "${string##*s}"    # '##*reg' remove the FRONT str at the place that 'reg' LAST show

echo "${string%s*}"     # '%reg*' remove the BACK str at the place that 'reg' FIRST show
echo "${string%%s*}"     # '%%reg*' remove the BACK str at the place that 'reg' LAST show

echo ${string:5:10}     # slice position 5, length 5
echo ${string/This/It}  # replace the first 'This' to 'It'
echo ${string//This/It}     # replace all 'This' to 'It'
