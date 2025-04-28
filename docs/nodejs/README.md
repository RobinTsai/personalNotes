# Node.js

## nvm

```sh
# 安装
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# 或手动安装
git clone git@gitee.com:mirrors/nvm.git ~/.nvm
# 添加如下到 .bashrc 中
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# 列出远程版本
nvm ls-remote
# 安装指定版本
nvm install v23.11.0
# 当前安装列表
nvm ls
# 使用
nvm use v23.11.0
```

## npm

```sh
# npm 设置镜像源
npm config set registry https://registry.npmmirror.com # 淘宝
npm config get registry
```

---

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
