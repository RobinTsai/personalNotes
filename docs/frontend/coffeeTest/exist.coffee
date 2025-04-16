# exist.coffee
# use "?" to 表示 'have defined' && 'is not null'
# "?=" 表示 " == null"
# "not * ?" 来表示非        => flag6
# "?." 来链式地调用是否为空   => flag7


flag = true if var1?    # var1 undefined, if 不成立

var2 = null             # var2 is null, if 不成立
flag2 = true if var2?

# flag3 ?= true     # flag3 undefined, 不成立, 报错

flag4 = null        # flag4 = null, ?= 成立
flag4 ?= true       # 只有定义过，且值为null，才会成立

flag5 = 1           # flag != null, ?= 不成立
flag5 ?= 5          # 仅当 flag === null, ?= 才成立

flag6 = true if not var3?

a = {
  b : {
    c : 14
  }
}
flag7 = a?.b?.c     # 链式地去问：如果a存在，如果b存在
flag8 = a?.c?.b

console.log "flag = " + flag
console.log "flag2 = " + flag2
# console.log "flag3 = " + flag3  # error
console.log "flag3 会报错"
console.log "flag4 = " + flag4
console.log "flag5 = " + flag5
console.log "flag6 = " + flag6
console.log "flag7 = " + flag7
console.log "flag8 = " + flag8

# conlusion:
# ? 表示存在时，指的是已经定义了，且不为null
#
# ?= 的用法，只能是当变量是null时使用.
#   如果变量未定义，报错。
#   如果变量已经有值，那么不执行赋值
# ?. 存在的意义:
#   因为在Script中,如果前置的变量没有定义，那么会抛出TypeError
#   用这种方式的话，它只会返回undefined，而不是抛出Error


### =>
flag = undefined
flag2 = undefined
flag3 会报错
flag4 = true
flag5 = 1
flag6 = true
flag7 = 14
flag8 = undefined
###
