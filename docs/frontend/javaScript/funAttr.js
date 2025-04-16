uniqueInteger.counter = 0;
function uniqueInteger() {
  var a = uniqueInteger.counter++;
  console.log(a);
}

uniqueInteger(); // 0

uniqueInteger(); // 1
/*
  这样的好处是只在此函数调用的时候，可以使用这个值
  而省去了全局变量的使用
*/
