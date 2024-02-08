# confd

下载很简单，就是个二进制文件，将其重命名放到可执行目录即可。

```sh
wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64
mv confd-0.16.0-linux-amd64 /usr/local/bin/confd
chmod +x /usr/local/bin/confd
confd --help
```

confd 通过读取存储的配置信息，动态更新到配置文件中。后端存储可以是 etcd 或 redis。

## 线上案例使用 redis

目录：

```sh
- . # 安装目录
- conf.d.toml # 配置文件，配置中 confdir 是根配置目录
- bin/
- conf.d/     # 配置文件目录，根配置目录下的存放配置文件的目录
    - vars.xml.toml  # 配置文件，配置了模板源和目的位置，及根据什么值进行变更，变更后的操作
    - ...
- templates/  # 模板目录
    - vars.xml.tpl   # 配置文件对应的模板文件
    - ...
```
