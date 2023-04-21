## 连接

```sh
mysql -uUSERNAME -pPASSWORD -hHOST DB_NAME                      # DB 名直接加即可
mysql -uUSERNAME --password='WITH_SPECIAL_CHAR_PASSWORD' -hHOST # 特殊符号的密码用参数名的全称，用单引号（双引号有时候不好）
mysql -uUSERNAME -pPASSWORD -hHOST DB_NAME -e 'MYSQL CMD'       # 执行命令用 -e
```
