// function_apply.js

// 和Function.prototype.call类似
// .apply的调用方式也是把上下文变量this设置为输入参数序列中的第一个参数的值
// 在和arguments一起使用的时候是最能体现它的功能的时候
//
/* Function.apply(obj, args)
 * 是一个function对象的调用
 * 能接受两个参数
 * 第一个参数代替Function中的this对象
 * 第二个参数是个数组, 将作为参数传递给Function(args-->arguments)
 */
var numbers = [3, 5, 2, 1, 15];
console.log('Output:')
console.log('When use max(4,3,6,8) => ' + Math.max(4,3,6,8)) // 为了说明max支持多个变量
console.log('When use max([4,3,6,8]) => ' + Math.max([4,3,6,8])) // 为了说明max支持多个变量
console.log('When use max.apply(null, args) => ' + Math.max.apply(null, numbers))
// max函数本身是不支持数组的, 它现在支持了

console.log()
function person(gender, age) {
  this.gender = gender;
  this.age = age;
  console.log("'this' is a 'gender' and 'age' years old.");
  console.log(this + " is a " + this.gender + " and " + this.age + " years old.");
}
person.apply('mike', ['male', 5]);

console.log();
function toArray(args) {
  return Array.prototype.slice.call(args);
}
var example = function () {
  console.log(arguments);
  console.log(toArray(arguments));
}
example('a', 'b', 'c');
