## 命令

### 连接

```sh
mysql -hHOST -uUSERNAME -pPASSWORD DB_NAME                      # DB 名直接加即可
mysql -hHOST -uUSERNAME --password='WITH_SPECIAL_CHAR_PASSWORD' # 特殊符号的密码用参数名的全称，用单引号（双引号有时候不好）
mysql -hHOST -uUSERNAME -pPASSWORD DB_NAME -e 'MYSQL CMD'       # 执行命令用 -e

mysql -S /path/to/mysql.sock
```

### 用户管理

```sh
# mysql://USERNAME:PASSWORK@HOST:PORT/DB_NAME"
update user set host = '%' where user = 'root';
mysql -h localhost -uroot -pkamailio
select Host,User from user;
mysql -hlocalhost -ukamailio -pkamailio;
```

### 表管理

```sql
ALTER table tableName ADD INDEX indexName(columnName)
ALTER TABLE tableName ADD COLUMN column_name tinyint DEFAULT 0, ADD COLUMN column_name_2 tinyint DEFAULT 0;
ALTER TABLE tableName MODIFY COLUMN column_name TINYINT DEFAULT 0;

ALTER TABLE tiers MODIFY COLUMN `auto_login` tinyint(4) DEFAULT 1;

ALTER TABLE tableName CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE tableName CONVERT TO CHARACTER SET utf8mb4;

ALTER DATABASE db_name DEFAULT CHARACTER SET character_name

DROP TABLE table_name;
```

### 字符集

- DB 内表的字符集不同会导致无法关联查询（Error: 1267）（遇到的情况是：甚至从 A 表查出后字段赋值给 B 表一个字段用于查询）
- 字符集有 DB 的字符集、连接的字符集、还有个什么的字符集来着，要保持一致。

```sql
```

### 行管理


```sh
INSERT INTO table_name (column1, column2, column3, ...) VALUES (value1, value2, value3, ...);

INSERT INTO tenant_events (sub_id, `event`) VALUES (125, 'realtime_asr_result');

mysql -h192.168.1.108 -uroot -p123456 --default-character-set=utf8 udesk_phone_location -e "update phone_location set province = '重庆', city = '重庆' where id = 1081723 limit 1;"
```

### 导出

```sh
mysqldump -h 192.168.2.184 -u root -p password --databases db_name > db_name.sql             # 导出 db_name 数据库
mysqldump -h 192.168.2.184 -u root -p password --databases db_name users > db_name_users.sql # 导出 db_name 数据库 users 表
mysqldump --default-character-set=utf8 ... # 指定 utf8 字符集
# -s, silent, 只返回查询结果，不展示表头、分割线、行号等信息

mysql -h$host -u$user -p$password -D$db -B -e "$sql" > export.csv
```

### 索引

```sql
show index from phone_location;
DROP INDEX [indexName] ON mytable;
CREATE INDEX indexName ON table_name (column_name)
```

## 本地快速搭建

```sh
service docker start  # 启动 docker
docker pull mysql:5.6 # 下载 docker mysql 5.6
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 \
    -v $PWD/conf:/etc/mysql/conf.d \
    -v $PWD/data:/var/lib/mysql \
    -v $PWD/logs:/logs \
    --name test_mysql2 mysql:5.6 # 启动，注意创建本地 conf data logs 目录
mysql -uroot -p123456                          # 在 docker 内连接

mysql -h127.0.0.1 -u root -p

# 三种方法解决：Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock'
# 1. 一般自动生成 `/tmp/mysql.sock` 套接字，软链它（不可 copy）或使用 find / -name mysqld.sock 找到它后软链
# 2. 修改配置文件 my.cnf，不要绑定 IP，然后指定 IP 登录：mysql -h127.0.0.1 -u root -p

source /var/lib/mysql/udesk_phone_location.sql # 在 mysql 交互页中执行导入
```

mysql 操作

```sql
-- 创建 DB
CREATE DATABASE test_db;
CREATE DATABASE IF NOT EXISTS test_db;
CREATE DATABASE t1_freeswitch  DEFAULT CHARSET utf8;
CREATE DATABASE t1_freeswitch  DEFAULT CHARSET utf8;
CREATE DATABASE t1_freeswitch  DEFAULT CHARSET utf8mb4;

show create database t1_freeswitch;

-- 创建表
CREATE TABLE `kefu` (
  `sid` varchar(255) DEFAULT NULL,
  `name_from_kefu` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `audio_subers` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `app_id` varchar(191) NOT NULL,
  `sub_url` text,
  `enabled` tinyint(1) DEFAULT '1'
) DEFAULT CHARSET=utf8;

-- 导入 csv（注意表头和表字段一致）
-- shell 中将文件放到对应目录 cp train.csv /var/lib/mysql-files/
LOAD DATA INFILE '/var/lib/mysql-files/crm.csv'
    INTO TABLE crm
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
```

## 状态统计

```sql
-- 表状态统计
show table status where Name='apps'\G;
--
select
table_schema as '数据库',
table_name as '表名',
table_rows as '记录数',
truncate(data_length/1024/1024, 2) as '数据容量(MB)',
truncate(index_length/1024/1024, 2) as '索引容量(MB)'
from information_schema.tables
where TABLE_SCHEMA='test_novel'
order by table_rows desc, index_length desc;

```

## 高级

```sh
# 使用 prepare
PREPARE stmt1 from "select agent_id,id,ready_at from agents where ready_at> ? limit 1;";
SET @pc = '2023-05-10';
EXECUTE stmt1 USING @pc;
DEALLOCATE PREPARE stmt1;
# 查看当前状态：准备语句 的个数
SHOW GLOBAL STATUS LIKE 'Prepared_stmt_count';
# 查看 mysql 准备语句 最大配置数
SHOW VARIABLES LIKE 'max_prepared_stmt_count';

# 设置 max_prepared_stmt_count （默认 16382）
SET GLOBAL max_prepared_stmt_count = 16382;
```

## 运维

```sh
# MySQL数据库会以读取到的最后一个配置文件中的参数为准
 1. /etc/my.cnf
 2. /etc/mysql/my.cnf #
 3. /usr/local/mysql/etc/my.cnf
 4. ~/.my.cnf

# 查看数据目录
show global variables like "%datadir%" #  /var/lib/mysql

# 从配置文件中查看日志文件配置
log-error = /var/log/mysql/error.log
```
