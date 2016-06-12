function say(word) {
  console.log(word);
}

function execute(func, val) {
  func(val);
}

execute(function(val) {console.log(val)}, 'hello');
