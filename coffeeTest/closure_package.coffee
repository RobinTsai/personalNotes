# closure_package
# 在网页中，window是一个全局变量
#

window =[0..20]
globals = (value for name, value of window)[1...11]
# You can use this instead:
# 1.  (name for name of window)
# 2.  (name for _, name of window)
# if 1, name only means the Key, not value. Output the key, it has 单引号
# if 2, name means the value.

globals2 = (name2 for name2 in window)[0...10]
# If there you use:
# (value for name2, value in window)
# (name2 for name2, value in window)
# the name2 also means the value. They are the same.
# It means the 'name2' and the 'value' all equal the value. there is no key.

console.log globals
console.log globals2

# See, 'in' & 'of' are different.
# you will know when you run it in the Terminal
# 'of' use for key:value
# and 'in' means variables
