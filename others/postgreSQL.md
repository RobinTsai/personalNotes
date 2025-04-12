# postgreSql

## 安装

安装命令：

```sh
sudo apt-get update
sudo apt-get install postgresql postgresql-client
```

安装后，默认是启动的，可以通过如下方式启停服务：

```sh
sudo /etc/init.d/postgresql start   # 开启
sudo /etc/init.d/postgresql stop    # 关闭
sudo /etc/init.d/postgresql restart # 重启
```

安装后，会创建一个数据库超级用户 postgres，密码为空。使用如下方式切换到此用户：

```sh
sudo -i -u postgres
```

postgres 用户输入 `psql` 命令可直接访问数据库。

## 使用

```shell
# 连接 DB
psql -U username -h host -p port -d database

# 退出连接
\q

# 查询数据库
\l          # 列出所有数据库
\c DB_NAME  # 切换数据库
\d          # 列出所有表
\d TABLE_NAME # 列出表结构

# 增删改查基本和 MySQL 一样
INSERT INTO TABLE_NAME (column1, column2, column3,...columnN) VALUES (value1, value2, value3,...valueN);    # 插入数据
INSERT INTO alias ("alias", ip, port, mask, "captureID", status) VALUES ('sh-kl-c1', '10.12.154.148',  8891, 32, 'CAP101', true); # 用引号时，列名要用双引号，值要用单引号
SELECT column1, column2,...columnN FROM table_name LIMIT 1;
```
