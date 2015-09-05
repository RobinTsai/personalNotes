stdin = process.openStdin()           # let user to input.
stdin.setEncoding 'utf8'

stdin.on 'data', (input) ->             # maybe a event listen the view on
  num = input.trim()
  console.log "square = " + square(num)
  console.log "cube = " + cube(num)
  process.exit()                        # exit

square = (x) -> x * x
cube = (x) -> square(x) * x

# sigle line comment
###
  multi-line comment
###


### =>
4   // 这个是需要输入的
square = 16
cube = 64

###
