# mix_js.coffee
# Use 反引号 来实现加入javaScript代码

hi = `function() {
  console.log("Hello.");
}`

hi()      # => hello.
