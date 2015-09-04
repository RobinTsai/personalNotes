# 'unless'
# opposite with 'if'

volume = 10 if "true" isnt "false"
console.log volume

volume2 = 10 unless "true" is "false"
console.log volume2

volume3 = 10 if "true" is not "false"
console.log volume3    # => undefined  // so it means there is not "is not"

volume4 = 10 unless "true" is "true"
console.log volume4     # => so 'unless' means "if not"

# so, 这有点拗口的
# unless 不能翻译成”除非“,这样说不通
# 它应该翻译成”除……外“,或者不按英语的来，翻译成“如果……is非,则”
# 不过注意,省略的部分是一个boolean型的
volume5 = 10 unless false
console.log volume5
