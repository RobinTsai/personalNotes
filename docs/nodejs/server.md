```js
var http = require('http');

http.createServer(function (request, response) {
  // http header
  // http status
  // http content type
  response.writeHead(200, {'Content-Type': 'text/plain'});
  // response
  response.end('Hello, World\n');
}).listen(8081);
