# destructure_set.coffee
# 解构赋值，英文名是我自己起的，不是官方的
#

weatherReport = (location) ->
  [location, 'sunny', '20150905']

console.log [location, weather, date] = weatherReport("Shanghai")
# => [ 'Shanghai', 'sunny', '20150905' ]

# 当然你可以用一下打方式来执行
weather = {}
console.log weather = weatherReport("Shanghai")
# => [ 'Shanghai', 'sunny', '20150905' ]

###
# 这里主要说明了，
  在coffeescript中是可以 一一对应 赋值的
  你可以用 [a,b,c] = [c,b,a] 来操作
  这是可行的
# 还可以用于嵌套的赋值
  {a: {b, c:[d, e]}}   # {} 和 [] 的区别应该是 对象 和 数组 的区别
# 还可以和splats...搭配使用
  见split.coffee
###
