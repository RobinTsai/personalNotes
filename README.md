# 读书速查笔记 {ignore=true}

> “温故而知新”，“苟日新，日日新，又日新”。
> 书一遍一遍读，尚且会获取到新知识，更何况我在这里做的笔记。


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [Mastering Regex](#mastering-regex)
- [Shell](#shell)
- [goBlackHat](#goblackhat)
- [TCP/IP 网络编程](#tcpip-网络编程)
- [linux高性能服务器编程](#linux高性能服务器编程)
  - [第一篇 TCP/IP协议详解](#第一篇-tcpip协议详解)
  - [第二篇 深入解析高性能服务器编程](#第二篇-深入解析高性能服务器编程)
    - [第八章 高性能服务器程序框架](#第八章-高性能服务器程序框架)
  - [第三篇 高性能服务器优化与监测](#第三篇-高性能服务器优化与监测)
- [HowMySqlRun](#howmysqlrun)
- [RedisDevOps](#redisdevops)
- [ZooKeeper](#zookeeper)

<!-- /code_chunk_output -->

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

> 《linux高性能服务器编程》 ——游双（著）

TODO...

### 第一篇 TCP/IP协议详解

- [第一章 TCP/IP 协议族](./linuxHighPerformance/Chapter_1.md)
    - 四层模型
- [第二章 IP 协议详解](./linuxHighPerformance/Chapter_2.md)
- [第三章 TCP 协议详解](./linuxHighPerformance/Chapter_3.md)


### 第二篇 深入解析高性能服务器编程

- [第五章 Linux 网络编程基础 API](./linuxHighPerformance/Chapter_5.md)
    - 主机字节序和网络字节序
    - socket 相关基础函数（连接类、读写类）
- [第六章 高级I/O函数](./linuxHighPerformance/Chapter_6.md)
    - pipe/dup/dup2/readv/writev/sendfile/mmap/munmap/splice/tee/fcntl
- [第七章 Linux 服务器程序规范](./linuxHighPerformance/Chapter_7.md)

#### 第八章 高性能服务器程序框架

- [第八章 高性能服务器程序框架](./linuxHighPerformance/Chapter_8.md)
    - 服务器模型：C/S、P2P
    - IO 模型：阻塞 IO 和非阻塞 IO、IO 复用和信号 IO、同步 IO和异步 IO
    - 高效事件处理模型：Reactor、Proactor
    - 高效并发模式：半同步/半异步模式、领导者追随者模式
    - 其他建议：池、数据复制、上下文切换和锁
- [第九章 I/O 复用](./linuxHighPerformance/Chapter_9.md)
    - select / poll / epoll
- 第十章 信号
- [第十一章 定时器](./linuxHighPerformance/Chapter_11.md)
    - 时间轮 / 时间堆
- 第十二章 高性能 I/O 框架库 Libevent
- 第十三章 多进程编程
- 第十四章 多线程编程
- 第十五章 进程池和线程池

### 第三篇 高性能服务器优化与监测

## HowMySqlRun

《MySQL 是怎样运行的》

- [查询计划](./howMySqlRun/%E6%9F%A5%E8%AF%A2%E8%AE%A1%E5%88%92.md)
- [BufferPool缓存池](./howMySqlRun/BufferPool%E7%BC%93%E5%AD%98%E6%B1%A0.md)
- [join原理](./howMySqlRun/join%E5%8E%9F%E7%90%86.md)
- [redo日志](./howMySqlRun/redo%20%E6%97%A5%E5%BF%97.md)
- [undo日志](./howMySqlRun/undo%20%E6%97%A5%E5%BF%97.md)
- [事务](./howMySqlRun/%E4%BA%8B%E5%8A%A1.md)
- [事务的隔离级别和MVCC](./howMySqlRun/%E4%BA%8B%E5%8A%A1%E7%9A%84%E9%9A%94%E7%A6%BB%E7%BA%A7%E5%88%AB%E5%92%8CMVCC.md)
- [锁](./howMySqlRun/%E9%94%81.md)

## RedisDevOps

- [五大类型细讲](./redisDevOps/%E4%BA%94%E5%A4%A7%E7%B1%BB%E5%9E%8B%E7%BB%86%E8%AE%B2.md)
- [全局命令和五大类型命令表](./redisDevOps/%E5%85%A8%E5%B1%80%E5%91%BD%E4%BB%A4%E5%92%8C%E4%BA%94%E5%A4%A7%E7%B1%BB%E5%9E%8B%E5%91%BD%E4%BB%A4%E8%A1%A8.md)
- [内存优化](./redisDevOps/%E5%86%85%E5%AD%98%E4%BC%98%E5%8C%96.md)
- [内存回收策略](./redisDevOps/%E5%86%85%E5%AD%98%E5%9B%9E%E6%94%B6%E7%AD%96%E7%95%A5.md)
- [哨兵](./redisDevOps/%E5%93%A8%E5%85%B5.md)
- [复制](./redisDevOps/%E5%A4%8D%E5%88%B6.md)
- [小功能大作用](./redisDevOps/%E5%B0%8F%E5%8A%9F%E8%83%BD%E5%A4%A7%E4%BD%9C%E7%94%A8.md)
- [持久化-AOF](./redisDevOps/%E6%8C%81%E4%B9%85%E5%8C%96-AOF.md)
- [持久化-RDB](./redisDevOps/%E6%8C%81%E4%B9%85%E5%8C%96-RDB.md)
- [持久化-问题定位与优化](./redisDevOps/%E6%8C%81%E4%B9%85%E5%8C%96-%E9%97%AE%E9%A2%98%E5%AE%9A%E4%BD%8D%E4%B8%8E%E4%BC%98%E5%8C%96.md)
- [缓存设计](./redisDevOps/%E7%BC%93%E5%AD%98%E8%AE%BE%E8%AE%A1.md)
- [集群](./redisDevOps/%E9%9B%86%E7%BE%A4.md)

## ZooKeeper

- [README.md](./zookeeper/README.md)
- [分布式锁示例源码-Go](./zookeeper/src/main.go)