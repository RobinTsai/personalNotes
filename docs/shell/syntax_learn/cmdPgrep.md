```sh
#!/bin/bash

echo -e "\e[1;42mUse this to get process PID.\e[0m"

pgrep skype

echo -e "\e[1;42mUse 'cat proc/PID/environ' to get env params\e[0m"

cat /proc/4851/environ
echo -e "\n\e[1;42mTransform output '\ 0' to '\ n' \e[0m"
cat /proc/4851/environ | tr '\0' '\n'

# get process PID
