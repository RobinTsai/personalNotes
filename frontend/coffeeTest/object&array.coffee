song = ['do', 're', 'mi', 'fa', 'so']

singers = {Jagger: "Rock", Elvis: "Roll"}

bitlist = [
  1, 0, 1
  0, 0, 1
  1, 1, 0
]

kids =
  brother:
    name: "Max"
    age: 11
  sister:
    name: "Ida"
    age: 9

console.log "song = " + song
console.log "singers = " + singers + ", singers.Jagger= " + singers.Jagger
console.log "bitlist =" + bitlist
console.log "kids =" + kids + ", kids.brother.name=" + kids.brother.name


### =>
song = do,re,mi,fa,so
singers = [object Object], singers.Jagger= Rock
bitlist =1,0,1,0,0,1,1,1,0
kids =[object Object], kids.brother.name=Max
###
