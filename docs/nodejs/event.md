```js
var event = require('events');

var eventEmitter = new event.EventEmitter();

var connectHandler = function connected() {
  console.log('Connect succeed.');

  eventEmitter.emit('data_received');
}

eventEmitter.on('connection', connectHandler);

eventEmitter.on('data_received', function() {
  console.log('data receive succeed.');
});

console.log('Begin.');
eventEmitter.emit('connection');

console.log('The End.');
```
