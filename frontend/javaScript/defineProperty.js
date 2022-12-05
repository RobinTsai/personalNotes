// p135 <<javascript权威指南>>
var o = {
  name: "robin",
  age: 8,
  sex: "male"
}

console.log(Object.getOwnPropertyDescriptor(o, "name"));
// getOwnPropertyDescriptor 获取自身某个属性的特性描述
/* 用 node defineProperty.js
  输出:
  { value: 'robin',
    writable: true,
    enumerable: true,
    configurable: true }
*/

console.log(o.name);  // => robin
console.log(Object.keys(o));       // => [ 'name', 'age', 'sex' ]

Object.defineProperty(o, "sex", {enumerable: false});
// 设置其可枚举的属性为false，可以访问，但不能通过枚举访问
// 注意不能修改继承的属性
console.log(o.name);  // => robin
console.log(o.sex);   // => male
console.log(Object.keys(o));      // => ['name', 'age']
// 另有defineProperties()可设置一个对象的多个属性
