```js
var http = require('http');
var fs = require('fs');
var url = require('url');

http.createServer(function (req, res) {
  var pathname = url.parse(req.url).pathname;

  console.log('request for ' + pathname + ' received.');

  fs.readFile(pathname.substr(1), function (err, data) {
    if (err) {
      console.log(err);
    } else {
      res.writeHead(200, {'Content-Type': 'text/html'});

      res.write(data.toString());
    }

    res.end();
  });
}).listen(8081);

console.log('Server running at 8081 port');
```
