# only for, no 'while', but use for instead of while.
console.log " "


# 1.
# cycle to output the data.
for food in ['toast', 'cheese', 'wine']
  console.log food
console.log " "

# 2.
# define a function.
eat = (food) -> console.log food
  # attention: 当使用传入参数时，必须要有括号。
  # 而且必须不能换行。
  # 但在调用的时候不需要加括号（加也不错）

# the first 'food' is the parameters in
eat food for food in ['a', 'b', 'c']
console.log " "


# 3.
# Define arrs
arrs = ['a', 'b', 'c']

# Define Function.
menu = (i, bread) -> console.log i + ':' + bread

# run function.
menu i + 1, food for food, i in arrs
# Attention this:
  # At there, "for food, i in arrs"
  # 'food' 表示arrs中的值
  # 'i' 表示从0开始的计数. 但到底是计数,还是arrs的键,还需要进一步确认
  # 比如arrs=['a' = 'tom', 'b' = 'mike']时,i到底是谁????

# conclusion
# 在coffeescript中，逗号表示并列元素
# 而空格的意思就变了
# 空格代表了 分号 有时也代表里逗号（分隔）
console.log " "


# 4.
# Key char 'isnt'
eat food for food in arrs when food isnt 'b'
console.log " "


### =>

toast
cheese
wine

a
b
c

1:a
2:b
3:c

a
c

###
