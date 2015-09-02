square = (x) -> x * x         # have param in

outFun = ->                   # not a param in
  console.log square 5        # unnecessary parentheses(括号). 有也不错

outFun()                      # necessary parentheses when call this function.
