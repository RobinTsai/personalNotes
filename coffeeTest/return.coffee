# return
# you can choose to use 'return' or not
# it will use the last * as the return

six = (one = 1) + (two = 2) + (three = 3)

console.log "\none = " + one + "\nsix = " + six

grade = ->
  if false
    "false"
  else if true
    return "true"
  else
    "none"

# funny, see this, it can output the content of this function
console.log "\nthe grade function contents:\n" + grade

console.log "\ngrade = " + grade()

### =>

one = 1
six = 6

the grade function contents:
function () {
    if (false) {
      return "false";
    } else if (true) {
      return "true";
    } else {
      return "none";
    }
  }

grade = true
###
