var connect = require('connect');
var serveStatic = require('serve-static');
var app = connect();
app.use(serveStatic("../angularJsPro"));
app.listen(5000);
