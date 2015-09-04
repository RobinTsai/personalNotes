# while.coffee
# 'while' & 'until'
# 'until' == while(!) 或者是 while not
# 用while来保存一个数组
# 'loop', 另外可能还有loop等同于 while true

print = (i) -> console.log i
i = 0

print(i++) while i < 5  # 当……时执行
console.log ""
print(i--) until i < 1  # 直到……时执行

console.log ""
num = 5
lyrics = while num -= 1
  "#{-num}"        # 这是个数组赋值的操作

console.log lyrics
