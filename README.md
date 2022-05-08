> 读书笔记目录

- [Mastering Regex](#mastering-regex)
- [Shell](#shell)
- [goBlackHat](#goblackhat)
- [TCP/IP 网络编程](#tcpip-网络编程)
- [linux高性能服务器编程](#linux高性能服务器编程)
  - [第一篇 TCP/IP协议详解](#第一篇-tcpip协议详解)
  - [第二篇 深入解析高性能服务器编程](#第二篇-深入解析高性能服务器编程)
  - [第三篇 高性能服务器优化与监测](#第三篇-高性能服务器优化与监测)

---

## Mastering Regex

[精通正则表达式](./Regex/noteOfProfessionalRegex.md)

## Shell

[Linux命令行与shell脚本编程大全(第3版)](./shell/noteFromBook.md)

## goBlackHat

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

## TCP/IP 网络编程

[TCP/IP 网络编程](./tcpIpNetProgramming/README.md)

## linux高性能服务器编程

> 《High Performance Linux Server Programming》 ——游双（著）

TODO...

### 第一篇 TCP/IP协议详解 
### 第二篇 深入解析高性能服务器编程

- [第五章 Linux 网络编程基础 API](./linuxHighPerformance/Chapter_5.md)
- [第六章 高级I/O函数](./linuxHighPerformance/Chapter_6.md)
- [第七章 Linux 服务器程序规范](./linuxHighPerformance/Chapter_7.md)
- 第八章 高性能服务器程序框架
- 第九章 I/O 复用
- 第十章 信号
- 第十一章 定时器
- 第十二章 高性能 I/O 框架库 Libevent
- 第十三章 多进程编程
- 第十四章 多线程编程
- 第十五章 进程池和线程池

### 第三篇 高性能服务器优化与监测