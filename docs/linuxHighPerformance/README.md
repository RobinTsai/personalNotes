# Linux高性能服务器编程

### 第一篇 TCP/IP协议详解

- [第一章 TCP/IP 协议族](./Chapter_01.md)
    - 四层模型
- [第二章 IP 协议详解](./Chapter_02.md)
- [第三章 TCP 协议详解](./Chapter_03.md)


### 第二篇 深入解析高性能服务器编程

- [第五章 Linux 网络编程基础 API](./Chapter_05.md)
    - 主机字节序和网络字节序
    - socket 相关基础函数（连接类、读写类）
- [第六章 高级I/O函数](./Chapter_06.md)
    - pipe/dup/dup2/readv/writev/sendfile/mmap/munmap/splice/tee/fcntl
- [第七章 Linux 服务器程序规范](./Chapter_07.md)

#### 第八章 高性能服务器程序框架

- [第八章 高性能服务器程序框架](./Chapter_08.md)
    - 服务器模型：C/S、P2P
    - IO 模型：阻塞 IO 和非阻塞 IO、IO 复用和信号 IO、同步 IO和异步 IO
    - 高效事件处理模型：Reactor、Proactor
    - 高效并发模式：半同步/半异步模式、领导者追随者模式
    - 其他建议：池、数据复制、上下文切换和锁
- [第九章 I/O 复用](./Chapter_09.md)
    - select / poll / epoll
- 第十章 信号
- [第十一章 定时器](./Chapter_11.md)
    - 时间轮 / 时间堆
- 第十二章 高性能 I/O 框架库 Libevent
- 第十三章 多进程编程
- 第十四章 多线程编程
- 第十五章 进程池和线程池
- 扩展
    - [事件驱动架构](./Extension.md#事件驱动架构)

### 第三篇 高性能服务器优化与监测
