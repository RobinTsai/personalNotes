var fs = require('fs');

// var data = fs.readFileSync('input.txt');
var data = fs.readFile('input.txt', function (err, data) {
  if (err) return console.error(err);
  console.log(data.toString());
})

console.log('The End.');
