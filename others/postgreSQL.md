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

# 数据库操作
CREATE DATABASE DB_NAME;                           # 用 sql 创建 DB
createdb [options...] [dbname [desc]]              # 用命令行 createdb 工具创建 DB
CREATE USER my_name WITH PASSWORD 'my_password';   # 创建用户
DROP USER my_name;                                 # 删除用户
GRANT ALL ON database my_db TO my_name;            # 授权
GRANT ALL PRIVILEGES ON DATABASE my_db TO my_name; # 授权
REVOKE ALL ON database my_db FROM my_name;         # 收回授权

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


## 授权和收回（GRANT/REVOKE）

```sh
GRANT {privilege} [, ...]
    ON {object} [, ...]
    TO { PUBLIC | GROUP group | username }

REVOKE privilege [, ...]
    ON object [, ...]
    FROM { PUBLIC | GROUP groupname | username }
```

- privilege − 值可以为：SELECT，INSERT，UPDATE，DELETE， RULE，ALL。
- object − 要授予访问权限的对象名称。可能的对象有：database, table， view，sequence。
- PUBLIC − 表示所有用户。
- GROUP group − 为用户组授予权限。
- username − 要授予权限的用户名。PUBLIC 是代表所有用户的简短形式。


## 登录遇到问题

```sh
# 通过 find . -name pg_hba.conf 命令找到了在下面目录中
➜ ll /etc/postgresql/10/main/
total 52K
-rw-r--r-- 1 postgres postgres  317 Apr 11 14:20 start.conf
-rw-r--r-- 1 postgres postgres  143 Apr 11 14:20 pg_ctl.conf
-rw-r----- 1 postgres postgres 1.6K Apr 11 14:20 pg_ident.conf
-rw-r----- 1 postgres postgres 4.6K Apr 11 14:20 pg_hba.conf
-rw-r--r-- 1 postgres postgres  315 Apr 11 14:20 environment
drwxr-xr-x 2 postgres postgres 4.0K Apr 11 14:20 conf.d
-rw-r--r-- 1 postgres postgres  23K Apr 11 14:20 postgresql.conf

# 编译 pg_hba.conf
host    my_db           my_name         192.168.1.112/32        md5
```
