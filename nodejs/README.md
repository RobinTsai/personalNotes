# Node.js

## 1. http

- http = require('http')
- http.createServer(fun(req, res) {...}).listen(port);
- res.writeHead(statusCode, {'Content-Type': 'text/plain'});
- res.end('string');

## 2. callback Func

- fs = require('fs')
- var data = fs.readFileSync('filename.ext'); // sync
- fs.readFile('filename.ext', function(err, data) {...});  // asyn
- console.log(data.toString());

## 3. event emitter

- var event = require('events');
- var eventEmitter = new event.EventEmitter();  // attention the letter case.

- eventEmitter.emit('eventName');  // emit event
- eventEmitter.on('eventName', eventHandler); // eventHanlder is a function name.
