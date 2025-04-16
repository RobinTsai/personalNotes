# split.coffee

# 1.
# To know split
# It means 用……来分隔字符串,
# 并选择前几个进行返回(可选参数)
#

str = "www.baidu.com"

str1 = str.split "."    # 以点号进行分隔
str2 = str.split ".", 2 # 以点号进行分隔，并返回前两个
str3 = str.split ""     # 每个char都进行分隔

console.log str1
console.log str2
console.log str3

# use splats //解构赋值的例子
console.log [first, ..., last] = str.split ""


### =>
[ 'www', 'baidu', 'com' ]
[ 'www', 'baidu' ]
[ 'w', 'w', 'w', '.', 'b', 'a', 'i', 'd', 'u', '.', 'c', 'o', 'm' ]
[ 'w', 'w', 'w', '.', 'b', 'a', 'i', 'd', 'u', '.', 'c', 'o', 'm' ]
###
