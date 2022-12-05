# class_super.coffee
# 注意本例中的 参数定义,传入参数方法,
# You can use '::' to visit a function too.
# 当然，用"::"也是可以做一些操作的

class Animal
  constructor: (@name) ->       # 构造器，传入参数作为 类中的变量name

  move: (meters) ->       # 类中函数定义，传入参数
    console.log @name + " move " + meters

  say: -> console.log "test '::'"


class Snake extends Animal
  move: ->
    super 5               # 用super传入参数

class Horse extends Animal
  move: ->
    super 50

snake = new Snake "snake one"
horse = new Horse "horse one"

snake.move()        # => snake one move 5
horse.move()        # => horse one move 50
Animal::say()       # => test '::'


###
  另外，教程里还说道了
    因为在 class 定义的上下文当中,
    this 是类对象本身(构造函数),
    可以用 @property: value 赋值静态的属性,
    也可以调用父类的方法: @attr 'title', type: 'text'.
  不知道这些是什么意思
###
