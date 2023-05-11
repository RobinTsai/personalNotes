## 连接

```sh
mysql -hHOST -uUSERNAME -pPASSWORD DB_NAME                      # DB 名直接加即可
mysql -hHOST -uUSERNAME --password='WITH_SPECIAL_CHAR_PASSWORD' # 特殊符号的密码用参数名的全称，用单引号（双引号有时候不好）
mysql -hHOST -uUSERNAME -pPASSWORD DB_NAME -e 'MYSQL CMD'       # 执行命令用 -e
mysqldump -h 192.168.2.184 -u root -p password --databases db_name > db_name.sql             # 导出 db_name 数据库
mysqldump -h 192.168.2.184 -u root -p password --databases db_name users > db_name_users.sql # 导出 db_name 数据库 users 表
mysqldump --default-character-set=utf8 ... # 指定 utf8 字符集

# 索引
show index from phone_location;
DROP INDEX [indexName] ON mytable;
CREATE INDEX indexName ON table_name (column_name)
ALTER table tableName ADD INDEX indexName(columnName)
```

## 本地快速搭建

```sh
service docker start  # 启动 docker
docker pull mysql:5.6 # 下载 docker mysql 5.6
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 \
    -v $PWD/conf:/etc/mysql/conf.d \
    -v $PWD/data:/var/lib/mysql \
    -v $PWD/logs:/logs \
    --name test_mysql mysql:5.6 # 启动，注意创建本地 conf data logs 目录
mysql -uroot -p123456                          # 在 docker 内连接
source /var/lib/mysql/udesk_phone_location.sql # 在 mysql 交互页中执行导入
```
