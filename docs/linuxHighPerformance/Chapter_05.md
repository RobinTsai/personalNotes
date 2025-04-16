# 第五章 Linux 网络编程基础 API {ignore=true}

要点：
1. 字节序（主机字节序、网络字节序、大端字节序、小端字节序）
2. socket 连接类函数
3. accept 函数内部实现

---

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [主机字节序和网络字节序](#主机字节序和网络字节序)
- [IP地址转换函数](#ip地址转换函数)
- [socket 连接类函数](#socket-连接类函数)
- [socket 的读写](#socket-的读写)

<!-- /code_chunk_output -->


## 主机字节序和网络字节序

> 友链： [TCP/IP网络编程#字节序与网络字节序](../tcpIpNetProgramming/README.md#字节序与网络字节序)

在 32位机中，CPU 的累加器一次能装载 4 字节。那么这 4 字节在内存中的排序将影响它被累加器装在成的证书值。这就是字节序问题。

- **大端字节序**（big endian），高位字节（23-31 bit）存在内存的低地址处。
- **小端字节序**（little endian），低位字节（0-7 bit）存在内存的低地址处。

因网络总是以大端字节序进行传输，因此大端字节序又被成为**网络字节序**。
因现代 PC 大多采用小端字节序，因此小端字节序又被称为**主机字节序**。

linux 字节序转换函数
```C
#include <netinet/in.h>
unsigned long int htonl()   // h: host, to, n: network, l: long 32bit，主机字节序转换成网络字节序的长整型
unsigned short int htons()  // host to network short 16bit
unsigned long int ntohl()   // network to host long
unsigned short int ntohs()  // network to host short
```

## IP地址转换函数

点分十进制字符串表示的 IP 地址对人可读性好，但机器更喜欢网络字节序整数表示的值。

linux 提供 IPv4 地址点分十进制字符串与网络字节序整数转换的函数：
```c
in_addr_t inet_addr( const char* strptr ) // 字符串转数值
int inet_aton( const char* cp, struct in_addr* inp ) // 字符串转数值，转换后放到 inp 中
char* inet_ntoa( struct in_addr in ) // 数值转字符串
```

## socket 连接类函数

```C
int socket( int domain, int type, int protocol) // 创建 socket，传入分别为 协议族、类型（流式/报文式）、具体协议
int bind( int sockfd, const struct sockaddr* my_addr, socklen_t addrlen ) // 将 socket 绑定到 地址
int listen(int sockfd, int backlog) // 创建监听，传入 fd 和监听队列大小，返回成功或失败
int accept( int sockfd, struct sockaddr *addr, socklen_t *addrlen) // 接受连接，同时获取远端地址放到 *addr 中，返回一个新的 socket
int connect(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen) // 客户端发起连接，传入客户端fd，服务端地址信息和长度
int close(int fd) // 优雅关闭连接
int shutdown(int sockfd, int howto) // 立即关闭连接，howto 控制关闭读、写、读写
```

> backlog 意思为积压的工作，储备。上方在 listen() 函数中表示内核创建多大的 socket 监听队列。内核版本 2.2 之后只表示出于完全连接状态的 socket 上限；处于半连接状态的 socket 上限由 `/proc/sys/net/ipv4/tcp_max_syn_backlog` 内核参数定义。
>
> accept() 成功时会返回一个新的 socket fd
>
> close() 不会真正关闭一个连接，而是将 fd 的引用计数减一（在 fork 时会使父进程中引用计数加一），为 0 时才真正被关闭。（所以子进程父进程都需要调用 close）
>
> shutdown() 可以立即终止连接（而不是引用计数减一），第二个参数可控制只关闭读、只关闭写、关闭读和写。

## socket 的读写

TCP 的读写：
```C
read()  // 对于文件的读写同样适用于这里
write() // 文件的写
ssize_t recv(int sockfd, void *buf, size_t len, int flags) // 更方便控制的读写，可控制缓冲区地址和长度
ssize_t send(int sockfd, void *buf, size_t len, int flags) //
```

UDP 的读写：
```C
ssize_t recvfrom(int sockfd, void* buf, size_t len, int flags, struct sockaddr* src_addr, socklen_t* addrlen)
ssize_t sendto(int sockfd,const void* buf, size_t len, int flags, const struct sockaddr* src_addr, socklen_t* addrlen)
```

通用数据的读写，适用于 TCP/UDP：
```C
ssize_t recvmsg(int sockfd, struct msghdr* msg, int flags)
ssize_t sendmsg(int sockfd, struct msghdr* msg, int flags)
```