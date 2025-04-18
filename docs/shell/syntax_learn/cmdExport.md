```sh
#!/bin/bash

echo -e "\e[1;42mSet environment variable.\e[0m"

export VAR="abc" # there no '$'
echo $VAR

echo -e "\e[1;42mAttention: env variable only be used in current shell\e[0m"

echo -e "\e[1;43mSome env variable:\e[0m"
echo -e "\e[1;43mHOME, PWD, USER, UID, SHELL\e[0m"
