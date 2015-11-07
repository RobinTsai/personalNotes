// Book: P8
var connect = require('connect');
var serveStatic = require('serve-static');
var app = connect();
app.use(serveStatic("../angularJsPro"));
app.listen(5000);
// the code of book is NOT fitted the connect.js 3.x version
// From 3.x version, serve-static is extract from the connect module.
// So, you can only use this method.
// You need also as install connect to use 'npm install serve-static' prev.

// Codes Explain:
// This will listen the url: 127.0.0.1:5000,
// And this url point at the folder "../angularJsPro"
// So, when you input url with "127.0.0.1:5000/test.html"
// this will run the test.html under this folder.

// 在Line5用serveStatic("../angularJsPro"， {default: "test.html"})的话，url中可以不指定test.html文件

// 'require' used to use a module
// 'use' used to use a middleware(中间件)
