# lsof

List Open File，主要是用来获取被进程打开文件的信息。如：普通文件、目录、特殊块文件、管道、socket、设备、Unix域套接字等。

```sh
lsof # 所有活跃进程的所有打开文件
lsof | more # 使用 more 分块查看
lsof -u root  # 过滤 root 用户
lsof -u ^root # 过滤非 root 用户
lsof -i       # 所有网络文件
lsof -i 4     # 所有 ipv4 网络文件
lsof -i:端口号      # 在端口号上打开的文件
lsof -i TCP/UDP    # 所有 TCP 或 UDP 文件
lsof -i TCP:3306   # 使用 TCP 3306 端口的文件
lsof -i TCP:1-1024 # 使用 TCP 1-1024 端口的文件
lsof -p 1053,1054,^1055       # 指定进程 1053,1054 排除进程 1055
```

## 输出解释

```sh
# lsof 输出示例
COMMAND     PID   TID       USER   FD      TYPE             DEVICE   SIZE/OFF       NODE NAME
systemd       1             root  cwd       DIR              253,1       4096          2 /
systemd       1             root  rtd       DIR              253,1       4096          2 /
systemd       1             root  txt       REG              253,1    1577232    1185326 /lib/systemd/systemd
systemd       1             root   20u     unix 0xffff880230f51000        0t0  600026951 /run/systemd/journal/stdout type=STREAM
vim       27813   tt          4u  REG     253                    1      12288     131167 /home/tt/.p.txt.swp(deleted)
```

列头（部分有多个含义）：进程名、进程ID、TaskID、所属用户、FD号或枚举值、FD类型、文件大小或文件偏移量、node号或网络协议类型等、路径或连接等

- TYPE:
    - DIR	目录
    - REG	普通文件
    - CHR	字符
    - a_inode	Inode文件
    - FIFO	管道或者socket文件
    - netlink	网络
    - unknown	未知
- FD：
    - cwd	当前目录
    - txt	txt文件
    - rtd	root目录
    - mem	内存映射文件
