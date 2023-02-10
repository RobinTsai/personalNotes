# Black Hat GO: Go Programming for Hanckers and Pentesters

- [Black Hat GO: Go Programming for Hanckers and Pentesters](#black-hat-go-go-programming-for-hanckers-and-pentesters)
  - [2. TCP、端口扫描和代理](#2-tcp端口扫描和代理)
    - [查询端口状态（打开、关闭、过滤/防火墙）](#查询端口状态打开关闭过滤防火墙)
    - [端口转发绕过防火墙](#端口转发绕过防火墙)
    - [端口扫描器](#端口扫描器)


## 2. TCP、端口扫描和代理

关键知识：
- TCP 误判（syn-flood 防护）
- 端口转发
- 端口扫描器
- TCP 代理
- Netcat 安全巨洞

### 查询端口状态（打开、关闭、过滤/防火墙）

服务端在应对 TCP 三次握手的首个 SYN 时，不同状态的端口会有不同的反应：

- 端口开放：返回 syn-ack；现象：TCP 可以连接成功。
- 端口关闭：返回 rst；现象：TCP 连接立即错误。
- 防火墙过滤：服务端无响应；现象：连接卡住直至超时。

### 端口转发绕过防火墙

### 端口扫描器

使用 `net.Dial(network, address string)`。

> 小知识
> linux 命令 `time <command>` 可是统计 command 执行的运行时间、内存、IO 等使用情况。
> 安全巨洞： `nc -lp 8080 -e '/bin/sh -i'`（不知为什么现在不能用了，总是报错 No such file or directory）
> 注意 nc 默认版本是没有 -e 选项的，需要执行 `sudo update-alternatives --config nc` 后选择 traditional 版本
> 或者使用 `apt-get install -y netcat-traditional` 安装
