console.log(true==1); // true
console.log(1=="1"); // true

console.log(true===1); // false
console.log(1==="1"); // false

var d = new String("text");
var e = "text";

console.log(d==e);  // true
console.log(d===e); // false


var a = null;
var b = null;
console.log(a);     // null
console.log(b);     // null
console.log(a===b); // true
console.log(a == undefined) // true
console.log(a == null) // true
console.log(typeof a)  // object

var c, d;
console.log(c);     // undefined
console.log(d);     // undefined
console.log(c===d); // true
console.log(c === undefined) // true
console.log(c == null)       // true
console.log(typeof c)        // undefined

// e never defined
console.log(typeof e) // undefined
console.log(e == undefined) // Exception: e is not defined
