# postgreSql

```shell
# 连接 DB
psql -U username -h host -p port -d database

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
