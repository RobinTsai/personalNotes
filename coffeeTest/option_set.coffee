# option_set.coffee
# 选择性地去赋值,
# 这是解构赋值中的一种特性


class Person
  constructor: (options) ->
    {@name, @age, @height} = options

Tim = new Person age: 4   # must ":", can't "="

console.log Tim     # => { name: undefined, age: 4, height: undefined }
