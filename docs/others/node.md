# node

## nvm

```sh
# 安装
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
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
