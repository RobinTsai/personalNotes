###
# Use 'of', not 'in'. when 'in', no error to output, but can't output
###

yearsOld = Wang: 10, Cai: 9, Sun: 11

console.log ""
ages = for name, age of yearsOld
  console.log name + " is " + age
console.log ""

ages = for own name, age of yearsOld
  console.log "#{name} is #{age}"

# Use 'own' 来避免属性是继承过来的


for name, age in yearsOld
  console.log name + age
console.log "\nSee use 'in' can't output, but no error\n"

### =>

Wang is 10
Cai is 9
Sun is 11

Wang is 10
Cai is 9
Sun is 11

See use 'in' can't output, but no error

###
