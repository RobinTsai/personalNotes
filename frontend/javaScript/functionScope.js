// 这个例子说明，函数是一个作用域，而if，for不是作用域
var test = function () {
  var i = 0;
  if (true) {
    var j = 1;
    for (var k = 2; k < 3; k++) {
      var l = 3;
      l++;
      console.log("i, j, k ,l = " + i + j + k + l);
    }
    console.log("i, j, k ,l = " + i + j + k + l);
  }
  console.log("i, j, k ,l = " + i + j + k + l);
  function test2 () {
    console.log(l);
  }
  test2();
}

test();
// => 全部都可以输出值
