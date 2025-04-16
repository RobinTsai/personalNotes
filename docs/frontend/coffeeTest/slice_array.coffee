# use [..] to slice an array.
#

numbers = [0, 1,2,3,4,5,6,7,8,9]

start = numbers[0..2]
start2 = numbers[0...3]
start3 = numbers[...3]

middle = numbers[3..-2]
end = numbers[-2..]

numbers_copy = numbers[..]
copy_slice = numbers[5..8]

numbers[4..6] = [-4, -5, -6]

console.log "start:\n  " + start + "\n  " + start2 + "\n  " + start3
console.log "middle: " + middle
console.log "end:  " + end
console.log "copy  " + numbers_copy
console.log "copy_slice:  " + copy_slice
console.log "change_numbers: " + numbers
console.log ""


### =>
start:
  0,1,2
  0,1,2
  0,1,2
middle: 3,4,5,6,7,8
end:  8,9
copy  0,1,2,3,4,5,6,7,8,9
copy_slice:  5,6,7,8
change_numbers: 0,1,2,3,-4,-5,-6,7,8,9
###
