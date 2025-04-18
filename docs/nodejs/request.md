```js
var http = require('http');
var url = require('url');
var util = require('util');

function start () {
  function onRequest(request, response) {
    var pathname = url.parse(request.url).pathname;
    console.log('url1 = ' + request.url + ', pathname = ' + pathname);
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.write('url2 = ' + request.url + ', pathname = ' + pathname);
    response.end(util.inspect(url.parse(request.url, true)));
  }

  http.createServer(onRequest).listen(8888);
  console.log('Server started.');
}

exports.start = start;
