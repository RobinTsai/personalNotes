/* use `node fileName` run this service in one Terminal.
 * use `telnet 127.0.0.1 3000` run one client in another Termianls (users).
 * Write your name at the first time you log in as a user.
 * Then chat with another users.
*/

var net = require('net');
var count = 0, users = {};

var server = net.createServer(function(conn) {
  conn.setEncoding('utf8');
  var nickname;

  conn.write('\n Welcome to node tcp-chat: ');
  count++;
  console.log('\033[90m    You have %d visitor(s)\033[39m', count);

  function broadcastMsg(msg, exceptSelf) {
    for (var i in users) {
      if(!exceptSelf || i != nickname) {
        users[i].write(msg);
      }
    }
  }

  conn.on('data', function(data) {
    data = data.replace('\r\n', '');
    console.log(data);
    if(!nickname) {
      if (users[data]) {
        conn.write('\033[93m> nickname already in use, try again: \033[39m ');
        return;
      } else {
        nickname = data;
        users[nickname] = conn;
        broadcastMsg('\033[90m > ' + nickname + ' joined the room\033[39m\n', true);
      }
    } else {
      for (var i in users) {
        if (i != nickname) {
          users[i].write('\033[96m > ' + nickname + ': \033[39m ' + data + '\n');
        }
      }
    }
  });

  conn.on('close', function() {
    count--;
    delete users[nickname];
    broadcastMsg('\n ' + nickname + ' logged out', false);
  })
});

server.listen(3000, function() {
  console.log('\033[96m    server listening on *:3000\033[39m');
});
