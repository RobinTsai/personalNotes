# gitbook

- `git clone git@gitee.com:mirrors/nvm.git ~/.nvm` 或 `curl -fsSL https://gitee.com/sdq/nvm/raw/master/install.sh | bash`
- `echo '. ~/.nvm/nvm.sh' >> ~/.bashrc` 或 .zshrc
- `source ~/.bashrc` 或 .zshrc
- `nvm install v12.16.1`（其他版本可能不能用）
- `node -v; npm -v`
- `npm install -g gitbook-cli`
- 安装 gitbook  `gitbook -V`
- 下载代码库 `git clone git@gitee.com:robincai1992/wiki-ccps.git`
- `gitbook install` 会安装 book.json 中定义的依赖等
- `gitbook serve`

## docker 方式

使用线上版本：

- TODO

自己构建并运行：

- `docker build -t repository/gitbook:1.0 .`
- `docker run -d -p 4000:4000 repository/gitbook:1.0`

线上部署脚本：

```sh
/usr/bin/oss2mgr-linux -cmd down -obj ccps/robincai/wiki.zip -file wiki.zip
unzip -d /usr/local/ -o wiki.zip
docker build -t repository/gitbook  /usr/local/wiki-ccps/
docker stop wiki-ccps
docker run -d -p 4000:4000 --name wiki-ccps repository/gitbook
```
