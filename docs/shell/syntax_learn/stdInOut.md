```sh
#!/bin/bash

echo -e "\e[1;42mUse >, >> to input and append at the end.\e[0m"
echo "This is a sample text 1" > temp.txt
echo "This is sample text 2" >> temp.txt
echo "=============cat temp.txt============>"
cat ./temp.txt
echo "<================end=================="

rm ./temp.txt

echo -e "\e[1;42m'0' -- stdin \e[0m"
echo -e "\e[1;42m'1' -- stdout \e[0m"
echo -e "\e[1;42m'2' -- stderr \e[0m"

echo -e "\e[1;32mcmd 2>2.txt \e[0m"
echo -e "\e[1;32magain 2>>2.txt \e[0m"
cmd 2> 2.txt
again 2>> 2.txt
echo ""
echo "You can see the error info in 2.txt"
echo "===============cat 2.txt==================>"
cat 2.txt
echo "<===================end===================="

echo -e "\e[1;32mrm 2.txt \e[0m"
rm 2.txt

echo ""
echo -e "\e[1;42m2>&1\e[0m or \e[1;42m&>\e[0m stderr as stdout "

echo ""
echo -e "\e[1;42m/dev/null\e[0m A special direction"
echo "It means drop out these info"

echo ""
echo -e "\e[1;43mMore:\e[0m "
echo -e "\e[1;42mtee\e[0m Get data from stdin"
echo -e "\e[1;42mexec\e[0m DIY file describe symbol"
echo -e "\e[1;42mcat -n\e[0m To add lines number"
