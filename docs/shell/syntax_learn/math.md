```sh
#!/bin/bash

var1=9
echo var1=$var1
var2=10
echo var2=$var2
let var3=$var1+$var2
echo var3=$var3
echo ""

echo -e "\e[1;42mWhen use 'let', '$' can be left out\e[0m"
let result2=var1+var2  # no '$'
echo var1+var2=$result2

echo -e "\e[1;42mYou can use '++' or '--'\e[0m"
let var1++
echo "(var1++)=$var1"

let var1--
echo "(var1--)=$var1"

let --var1
echo "(--var1)=$var1"

let ++var1
echo "(++var1)=$var1"

# echo -e "\e[1;42mWhen use '()', quote is necessary.\e[0m"

echo ""
echo -e "\e[1;42mUse '\$[]' rather than 'let'\e[0m"
echo result=$[var1+var2]

echo ""
echo -e "\e[1;42mUse '\$(())' rather than 'let'\e[0m"
echo result=$((var1+var2))

echo ""
echo -e "\e[1;42mUse 'expr' to calculate.\e[0m"
echo "Attention: must have every space."
result=`expr 3 + 4` # Attention every space.
echo $result

result=$(expr $var1 + 3) # Attention: every space.
echo $result

echo ""
echo -e "\e[1;42mUse 'bc' for float and output numerical.\e[0m"
echo -n "4 * 0.56 = "
echo "4 * 0.56" | bc

echo ''
echo -e "\e[1;42mSet float accuracy(精度): scale\e[0m"
echo -n "3 / 9 = "
echo "scale=2; 3/9" | bc

echo ""
echo -e "\e[1;42m进制转换: obase, ibase \e[0m"
echo "ibase, 按几进制输入数值"
echo "obase, 按几进制输出数值"
echo ""
no=100
echo no=100
echo -n "as(in) base 10, out base 2: "
echo "obase=2;$no" | bc
echo -n "as(in) base 10, out base 8: "
echo "obase=8;$no" | bc
echo -n "as(in) base 2, out base 10: "
echo "obase=10;ibase=2;$no" | bc

echo ""
echo -e "\e[1;42mSquare root: sqrt()\e[0m"
echo -n 'sqrt(100) = '
echo "sqrt(100)" | bc      # Don't use '-n'

echo ""
echo -e "\e[1;42mSquare: ^\e[0m"
echo -n "10^2 = "
echo "10^2" | bc
