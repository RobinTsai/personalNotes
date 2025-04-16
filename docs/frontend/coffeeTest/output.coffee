yearsOld = Wang : 10, Cai : 9, Sun : 11

console.log "\nthe first method:"
ages = for name, age of yearsOld
  console.log "  #{name} is #{age}"

console.log "\nthe second method:"
ages = for name, age of yearsOld
  console.log "  " + name + " is " + age


# conlusion:
# see this, you can find
# in the first method, the variable is in the quotes
# in the second method, the variable is out of the quotes.

### =>

the first method:
  Wang is 10
  Cai is 9
  Sun is 11

the second method:
  Wang is 10
  Cai is 9
  Sun is 11
###
