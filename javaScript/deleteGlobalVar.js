var a = 1;
b = 2;
this.c = 3;
this.d = 4;
console.log(delete a);      // false
console.log(delete b);      // true
console.log(delete this.b); // true
console.log(delete c);      // true
console.log(delete this.d); // true
