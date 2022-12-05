// 理解声明提前

var a = 2;
(function test() {
  console.log("Funciton test:")
  console.log(a);
})();
// 这种形式是声明完就直接调用
// 给function(){}加上括号是因为括号的优先级。

var b = 3;
(function test2() {
  console.log("\nFunciton test2:")
  console.log(b);
  var b = 4;
  console.log(b);
})();

// test2 相当于test3
var c = 4;
(function test3() {
  var c;        // 这里只声明，但没有赋值
  console.log("\nFunction test3:")
  console.log(c);
  c = 4;        // 赋值还是在(test2的)原处
  console.log(c);
})();

// 看看test3 的注释，以理解“声明提前”
