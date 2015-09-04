# 'splats...' means 变参, 是一种处理接受不定数量个参数的函数
# the three dot is the key.

gold = silver = rest = ""

awardMedals = (first, second, others...) ->
  gold = first
  silver = second
  rest = others

contenders = [
  "Michael Phelps"
  "Mike Wang"
  "Robin Cai"
  "Qill Li"
  "Garl Sun"
]

awardMedals contenders...

console.log "gold = " + gold
console.log "silver = " + silver
console.log "rest = " + rest
