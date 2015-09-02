outer = 10

changNumber = ->
  inner = 20
  console.log "In this function, outer=" + outer

changNumber()
console.log "out the function, outer=" + outer
# console.log "the function's params, inner=" + inner   # error
