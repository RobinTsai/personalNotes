```sh
#!/bin/bash

echo -e "\e[1;43mSHELL\e[0m, check current shell"
echo $SHELL
echo $0
echo ""

echo -e "\e[1;43mUID\e[0m, check super user or common user"
echo -e "root: 0"
echo UID = $UID
