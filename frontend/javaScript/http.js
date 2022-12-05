var sys = require('util');
var http = require('http');
http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello world');
}).listen(1337, "127.0.0.1");
console.log('Server running at http:127.0.0.1:1337/');
// 用node 运行此文件后
// 在浏览器中输入“127.0.0.1：1337”可以看到”Hello world“字样
// 还不明白为什么

// 网页回答： http模块提供了Http的服务端
// sys模块提供了输出数据到命令行。我用时系统提示我现在sys模块已经改名为util模块
// 不过用不用都能在命令行输出

// req：request; res: respond.
// res.writeHead是返回头信息，200代表成功
// end是关闭这个respond， 以前是close函数
