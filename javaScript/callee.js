// callee 调用自身的函数
var factorial = function (x) {
  if (x <= 1) return 1;
  return x * arguments.callee(x-1);
}

console.log("5! = " + factorial(5));
