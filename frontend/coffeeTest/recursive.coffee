# recursive: 递归
# how to use 'by'

# cycle to save the num into an array.
arrs = (num for num in [5..1])   # the parentheses can't be erased
# cycle to output the array.
console.log arrs

arrs2 = (num for num in [10..1] when num % 2 == 0)
console.log arrs2

arrs3 = (num for num in [0..10] by 2)     # +2
arrs4 = (num for num in [10..0] by -2)    # -2
console.log arrs3
console.log arrs4


### =>
[ 5, 4, 3, 2, 1 ]
[ 10, 8, 6, 4, 2 ]
[ 0, 2, 4, 6, 8, 10 ]
[ 10, 8, 6, 4, 2, 0 ]
###
