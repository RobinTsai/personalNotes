// arguments 是可以获取函数传入列表, 然后转换成数组
// 转换之后用的是0,1...重新作为键, 而不再是字符键名
// 下面两个arr1和arr2不能一起使用
var a = 'aaa';
var b = 'bbb';
var c = 'ccc';
var test = function() {         // 注意: 函数定义的时候没有参数
	console.log('test:');
  var arr1 = Array.prototype.slice.apply(arguments)
  // var arr2 = [].slice.apply(arguments).slice(1);
  console.log(arr1)
}
test(a, b, c);        // 在调用函数的时候加了参数, 这就是arguments的用法
