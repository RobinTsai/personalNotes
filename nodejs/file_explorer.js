var fs = require('fs'),
  stdout = process.stdout,
  stdin = process.stdin,
  stats = [];

fs.readdir(process.cwd(), function(err, files) {
  if (!files.length) {
    return console.log('    \033[31m No files to show!\033[39m\n');
  }

  console.log('    Select which file or directory you want to see\n');
  file(0);

  function file (i) {
    var filename = files[i];
    fs.stat(__dirname + '/' + filename, function (err, stat) {
      stats[i] = stat;
      if (stat.isDirectory()) {
        console.log('     ' + i + '  \033[36m' + filename + '/\033[39m');
      } else {
        console.log('     ' + i + '  \033[90m' + filename + '\033[39m');
      }

      if (++i == files.length) {
        read();
      } else {
        file(i);
      }
    });
  }

  function read() {
    console.log('');
    stdout.write('   \033[33m Enter your choice: \033[39m');
    stdin.resume();
    stdin.on('data', option);
  }

  function option (data) {
    if (!files[Number(data)]) {
      stdout.write('   \033[33m Enter your choice: \033[39m');
    } else if (stats[Number(data)].isDirectory()) {
      stdin.pause();
      console.log('This is a directory');
      fs.readdir(__dirname + '/' + files[Number(data)], function(err, files) {
        console.log('');
        console.log('    (' + files.length + ' files)');
        files.forEach(function (file) {
          console.log('    -  ' + file);
        });
        console.log('');
      })
    } else {
      stdin.pause();
      fs.readFile(__dirname + '/' + files[Number(data)], 'utf8', function (err, content) {
        console.log('');
        // console.log(content);
        console.log('\033[90m' + content.replace(/(.*)/g, '    $1') + '\033[39m');
      });
    }
  }
});

console.log(process.argv);
console.log(process.argv.slice(2));
