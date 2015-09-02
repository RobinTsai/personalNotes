console.log "all the 'flag' should be 'true'"

# if
flag1 = "true" if true
console.log "flag1 = " + flag1

# ? :
flag2 = if true then "true" else "false"
console.log "flag2 = " + flag2

# ? :
flag3 = if false then "false" else "true"
console.log "flag3 = " + flag3

# if else if    # must not only one line.
flag4 = if false
    "false"
  else if false
    "false"
  else if true
   "true"
  else
    "false"
console.log "flag4 = " + flag4

# &&
if true and true
  console.log "in if-true-and-true"

# &&
if true and false
  console.log "Not there"
else
  console.log "in if-true-and-false"

# ||
if false or true
  console.log "in if-false-or-true"
else
  console.log "Not there"

