# 在javascript中的true，在coffeescript中有三种形式
# 但暂时还不知道他们有什么不同，但既然不一样，一定会有不同的

flag = true
console.log "flag is :"
console.log "  true" if flag is true
console.log "  yes" if flag is yes
console.log "  on" if flag is on
console.log "  false" if flag is false
console.log "  no" if flag is no
console.log "  off" if flag is off

flag2 = false
console.log "flag2 is :"
console.log "  true" if flag2 is true
console.log "  yes" if flag2 is yes
console.log "  on" if flag2 is on
console.log "  false" if flag2 is false
console.log "  no" if flag2 is no
console.log "  off" if flag2 is off

### =>
flag is :
  true
  yes
  on
flag2 is :
  false
  no
  off
###
