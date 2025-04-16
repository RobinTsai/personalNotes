# string.coffee

# 1.
# 双引号和单引号是有区别的
sentence = "#{15 / 3} is 5"
console.log sentence        # => 5 is 5

sentence2 = '#{15 / 3} is 5'
console.log sentence2       # => #{15 / 3} is 5
### =>
5 is 5
#{15 / 3} is 5
###



# 2. multi string
# 支持多行的字符串，并默认用空格分隔
# you can use '\n'
introduction = "Hi, I'm Robin.
  I'm from China and 24 years.
  Today is a nice day, isn't it?
  \n\n\nHave fun and enjoy it.\n"
console.log introduction
### =>
Hi, I'm Robin. I'm from China and 24 years. Today is a nice day, isn't it?


Have fun and enjoy it.

###



# 3. html format
html = """
  <html>
    <body>
      <p>Today is a nice day</p>
      <p>Isn't is?</p>
    </body>
  </html>
"""
console.log html
### =>
<html>
  <body>
    <p>Today is a nice day</p>
    <p>Isn't is?</p>
  </body>
</html>
###
