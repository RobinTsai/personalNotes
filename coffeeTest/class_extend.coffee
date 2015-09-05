# class_extend.coffee
# in class, you can use "@" instead of 'this'
# you also can use 'this'

# All will be object at coffeescript

class Animal
  constructor: -> @isHungry = true      # this is 构造函数
  eat: -> @isHungry = false       # 定义一个函数

class Dog extends Animal

dog = new Dog
console.log dog             # => { isHungry: true }
console.log dog.isHungry    # => true

dog.eat()         # call dog.eat function.
console.log dog.isHungry    # => false
