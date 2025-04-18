# Black Hat GO: Go Programming for Hanckers and Pentesters

> 《Go黑帽子 渗透测试编程之道》的程序例子

- port_scan: 端口扫描示例
- echo: 回显服务的实现；代理服务转发 tcp 流的实现
- server_shell: 在服务器中开启一个 shell，执行客户端的任意输入命令（TCP）
- ws_xss: 脚本注入攻击，使用 websocket 收集用户输入
- reverse_proxy: http 反向代理，根据请求 Host 代理到其他服务
- ws_shell: 通过 websocket 与 server_shell 相交互，可以在服务器上执行任意 shell 命令
- TODO：DNS 利用
- TODO：lua 脚本
- TODO：gopacket 包，解码数据包，类似 tcpdump 功能
    - pcap 子包发现可用的网络接口
    - BPF 语法
    - 检查 TCP 标志位来透过 SYN 泛洪保护
        - SYN 泛洪保护：所有打开、关闭和过滤的端口都会产生相同的包交换，以表明该端口处于打开状态。主要为了应对端口探测，让其失去判断力。
        - 检查 TCP 标志位能透过 SYN 泛洪保护的原因：一般情况下 TCP 连接建立之后会立即进行数据交换，所以可以通过标志位来判断后方端口是否真的开启。
- TODO：plugin 的使用（局限：移植性）
- TODO：lua 脚本（gopher-lua）
- TODO：加密算法的技术点
- TODO：根据 PNG 格式特点，编写一个隐藏术程式
- TODO：实操一个 C2 远控木马


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
