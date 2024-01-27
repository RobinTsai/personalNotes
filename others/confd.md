# confd

下载很简单，就是个二进制文件，将其重命名放到可执行目录即可。

```sh
wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64
mv confd-0.16.0-linux-amd64 /usr/local/bin/confd
chmod +x /usr/local/bin/confd
confd --help
```

confd 通过读取存储的配置信息，动态更新到配置文件中。后端存储可以是 etcd 或 redis。
