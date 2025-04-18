# TCP/IP 网络编程 {ignore=true}

先按章节整理，随后整合按自己想的分节。

## 理解网络编程和套接字

> 第一章

网络编程，就是编写程序让两台联网的计算机进行进行交换数据（通信）。

套接字，是网络数据传输用的软件设备，所以网络编程又叫套接字编程。

服务端调用 socket 一般流程：

- socket() 创建一个套接字
- bind() 绑定地址
- listen() 监听 socket 信息，并设置缓冲（第二个参数为连接请求等待队列的大小）
- accept() 受理请求
- read/write() 向 socket 中读/写数据
- close() 关闭套接字

客户端调用 socket 的一般流程：

- socket() 创建一个套接字
- connect() 连接对端套接字
- read/write() 向 socket 中读/写数据
- close() 关闭套接字

### 套接字与协议设置

创建套接字的函数：

```c
#include <sys/socket.h>
int socket(int, int, int); // 参数分别为：协议族，套接字类型，协议名称（当某协议族下某套接字类型下只有一种套接字时，第三个参数可以为空值 0）

// 如，创建一个 tcp socket
int tcp_socket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
```

第一个参数为协议族（Protocol Family）；第二个参数为套接字类型（Type）；第三个参数为协议名称，若传输类型下只有一种协议则可以传递空值 0，否则必须填指定的协议名称（如：IPPROTO_TCP、IPPROTO_UDP）。

#### 协议族（Protocol Family）

一种协议的分类信息。C语言中你可能常会看到 `PF_` 前缀的常量，就表示一种协议族信息。如：

- PF_INET：IPv4 互联网协议族
- PF_INET6：IPv6 互联网协议族
- PF_LOCAL：本地通信的 UNIX 协议族
- PF_PACKET：底层套接字协议族
- ……


#### 套接字类型（Type）

套接字类型是套接字数据传输的方式。两种代表性的传输类型：

- SOCK_STREAM：面向连接的套接字，如 IPv4 协议族下的 TCP
- SOCK_DGRAM：面向消息的套接字，如 IPv4 协议族下的 UDP

##### 面向连接的传输方式

面向连接的传输方式，可以表述为 **“可靠的、按序传输的、基于字节的、面向连接的数据传输方式的套接字。”** 其有如下特征：

- 传输过程中数据不会丢失。
- 按序传输。
- 传输数据不存在数据边界（Boundary）。

> **数据边界**
>
> 是在传输过程中一次 write 函数必须和一次 read 函数相对应就是存在数据边界，反之就是不存在。这是由协议特性决定的。
>
> 如 UDP 的传输是存在数据边界的。在 UDP 传输过程中，客户端 socket write 一个数据报文，服务端必须使用一次 read 读取完整的报文。
>
> 而 TCP 在传输过程中就不存在数据边界。客户端可以多次调用 write 函数向流中写数据，服务端可以一次 read 读出所有的数据。（因此基于 TCP 的 http 协议要用 Content-Lenght 来标记数据的结束位置）
>
> 数据边界的特征是**协议要求套接字数据缓冲空间的大小限制**。为满足数据接收的完整性，基于报文的缓冲一定要规定一个报文上限，而基于流的不需要设定。

> **套接字缓冲满了后是否意味着数据丢失**
>
> 为了接收数据，套接字内有一个由字节数组构成的缓冲。另一端 write 和本端的 read 没有强相关关系，所以有可能 read 速度没有 write 速度快而导致 read 的缓冲区被填满。但这样也不会发生数据丢失，在这种情况下，传输端的套接字将停止传输。也就是说，面向连接的套接字会根据接收端的状态传输数据，如果传输出错还会提供重传服务。

##### 面向消息的套接字

面向消息的套接字，可以表述为 **不可靠的、不按序传递的、以数据高速传输为目的的套接字**。面向消息的套接字不存在连接的概念，其特征如下：

- 强调快速，不在乎顺序
- 传输过程中可能丢失或损毁
- 传输有数据边界
- 限制每次传输的大小

## 地址族与数据序列

> 第三章

IP 是 Internet Protocol （网络协议）的简写。IPv4 标准的 4 字节 IP 分为网络地址和主机地址，且分为 A、B、C、D、E 五类，E 类地址已被预约一般不会用到。

网络地址（网络 ID）是为 **区分网络** 而设置的一部分 IP 地址。当向某一主机上传输数据时，实际上是向构成网络的路由器或交换机上传递数据，由接收数据的路由器根据数据中的主机地址向目标主机传递数据。（如下图 A～C 类中蓝色段既为网络地址）

![IPv4地址族](/assets/tcpip_address.jpeg)

端口号是在同一操作系统内为区分不同套接字而设置的。
端口号由 16 位构成，范围为 0～65535，但 0～1023 是分配给特定应用程序的知名端口号。
虽然端口号不能重复，但 TCP 套接字和 UDP 套接字不会共用端口号，所以允许重复（数据接收时时根据五元组{传输协议，源IP，目的IP，源端口，目的端口}判断接受者的）。

### 字节序与网络字节序

> [Linux高性能服务器编程#主机字节序和网络字节序](../linuxHighPerformance/Chapter_5.md#主机字节序和网络字节序)

CPU 向内存保存数据的方式有 2 种，这意味着 CPU 解析数据的方式也分两种。

- 大端序（Big Endian）：高位字节存放在低位地址。
- 小端序（Little Endian）：高位字节存放在高位地址。

如大端序 0x1234 转换为小端序为 0x3412.

在 CPU 保存数据的字节序被称为**主机字节序**（Host Byte Order），目前主流的 Intel 系列 CPU 都是用**小端序**方式保存数据。
在网络上使用的字节序称为**网络字节序**（Network Byte Order）是按**大端序**方式传输的。
一般来说，主机和网络在数据交换的时候最好都进行一次字节序转换。

C 中转换字节序的方法：
```c
unsigned short htons(unsigned short); // (byte order) host to network with short
unsigned short ntohs(unsigned short); // network to host with short
unsigned long htonl(unsigned long);
unsigned long ntohl(unsigned long);
```

> 程序员在传输数据时都要考虑字节序转换吗？
>
> 如果所有数据都要进行字节序转换，那是很大的工作量。实际上没必要，这个过程是自动的。除了向 sockaddr_in 结构体变量填充数据外，其他情况无需考虑（C 语言）。
> sockaddr_in 保存的是 32 位整数型的地址信息。我们使用 IP 常常用便于读写的**点分十进制表示法**（Dotted Decimal Notation）表示，转换为 32 位整型并非易事，所幸 `arpa/inet.h` 头文件中提供了方法 `in_addr_t inet_addr(const char * string)` 转成四字节整型，同时考虑了字节序的转换。

> 实际 IP 和虚拟 IP
>
> 同一个计算机中可以分配多个 IP 地址，但 NIC 设备的数量决定了实际 IP 地址的数据。`INADDR_ANY` 常量可自动获取计算机 IP。
> 创建套接字需要决定应该接收那个 IP 上的数据，当只有一个 NIC 时，绑定的地址可以直接使用 `INADDR_ANY` 常量。
> 实际 IP 是运营商分配的，虚拟 IP 可以自己设置。（可以查看一下使用场景、如何设置等更多信息）

## 基于 TCP 的服务端和客户端

> 第四章

TCP（Transmission Control Protocol，传输控制协议）套接字是面向连接的，因此又称**基于流的套接字**。

TCP/IP协议栈共分为 4 层。由下向上依次为链路层（又叫网络接口层）、IP层（网络层）、TCP/UDP层（传输层）、应用层。

- 链路层可以认为就是物理连接，链路层就是负责这些标准。其对应 OSI 七层中的物理层和数据链路层。
- IP 层主要负责寻找网络、选择路径。IP 本身是 **面向消息的、不可靠的协议**，它只在作寻路功能。
- TCP/UDP 层负责数据传输，所以又称传输层。TCP 可以保证可靠的数据传输。
- 应用层。在 TCP/UDP 的上层再定义规则就是应用层协议。

> TCP 可靠，但它依据的 IP 协议不可靠，这该如何理解呢？
>
> IP 层只关注单个数据包的传输过程，其不管它在网络中是否损坏或丢失，所以是不可靠的。
> TCP 是在 IP 层的基础上添加了许多功能，如添加序列号、消息重传、拥塞控制等等，这些传输方式的规定赋予了其可靠性。
> TODO: 补充 UDP

### 调用顺序

如开头所述，第一步调用 socket() 函数创建套接字；第二步调用 bind() 函数分配地址。

第三步通过 listen 函数进入**等待连接请求状态**。只有在这种状态下，客户端才可以发出连接请求进入**连接请求状态**（客户端的 connect 函数正常返回）。

> **连接请求状态** 是指在连接加入到服务端 socket 的等待队列，但还没有受到 accept 处理的状态。
> listen 函数中的第二个参数就是设置等待队列的大小。当连接队列已满的时候，新建的连接会卡在 connect() 函数处。（已测试确认）
> 频繁接收请求的 Web 服务器端至少应该是 15（书中说的，理由尚且未知）。

```c
#include <sys/socket.h>
int listen(int sock, int backlog); // backlog 是连接请求等待队列的大小
```

第四步调用 accept 函数**受理客户端连接的请求**。
在没有客户端连接时 accept 函数会阻塞，直到有连接到来，它会创建另一个 socket 连接到请求的客户端并返回此 socket。
这个过程是内部自动创建的。

> 受理请求的是 accept 创建的 socket，那最初用 socket 函数创建的是做什么用呢？
>
> 最初创建的 socket 相当于是一个门卫，他的目的是序列化请求的连接进入排队。
> 要理解 socket 对应的是一对 IO 数据流，而不是只用于网络。
> 所以，网络连接的时候会用到一个 socket，处理请求的时候通过其他 socket 是很有必要的。

正如上文所述，客户端可以正常调用 connect 的时机是在服务端调用 listen 函数之后就可以了，只是此时服务端并未受理此时连接的 socket，而是加入了等待队列中。在服务器运行了 accept 函数后会开始处理队列中的 socket。

### 扩展 TCP

> 扩展内容源自 《深入理解 Nginx》 9.10 TCP 协议与 Nginx

#### 三次握手的内部实现

TCP 建立连接的过程是在内核完成的

1. 在我们调用 listen 方法时，内核会建立 SYN 队列和 ACCEPT 队列两个队列
2. 当客户端调用 connect 方法时向服务端发起 TCP 连接，SYN 包达到服务器后会把这一信息放到 SYN 队列，同时返回一个 SYN+ACK 包
3. 客户端发来针对于服务器 SYN 的 ACK 时，内核把连接从 SYN 队列取出放到 ACCEPT 队列（完成握手）
4. 服务端调用 accept 方法其实就是直接从 ACCEPT 队列中取出已经建立好的连接而已

#### recv 方法内部实现

在调用 send 和 recv 方法前后只是发生内核态到用户态的数据拷贝。TCP 底层的逻辑是在内核中完成的。

TCP 的可靠性可以简单概括为：
- send 方法发送任意大的数据，当超过 MTU 时会被切分成小报文（可变的 MSS）
- 每个报文都必须收到“回执”ACK
- 报文在网络上会失序，TCP 收到后需要排序并去重
- 当连接两端处理速度不一致时，需要由流量控制防止缓冲区溢出

TCP 收到数据后是如何进行排序的？

linux 内核为 TCP 接收信息准备了两个队列：receive 队列和 out_of_order 队列。
receive 队列存放已经接收到的 TCP 报文并且去除了 TCP 头、已经排好序，用户可以通过 recv 方法直接从此队列中读取数据；
out_of_order 队列存放乱序的报文。

> Nginx 是事件驱动的，它不会在 send/recv 上阻塞时通过事件驱动实现的，就是通过 epoll 注册收到网络报文的事件，当有事件产生时才去调用 recv 方法（非阻塞式）

### TCP 的 IO 缓冲

> 第五章 三次握手、四次挥手讲得不细致，略

TCP 套接字的数据收发是无边界的，即可以一次发送对端分多次接收（反之亦可）。这是由输入/输出缓冲区实现。

- 每个 TCP 套接字中都单独存在一份 IO 缓冲区
- 关闭套接字，输出缓冲区仍会保证发出去
- 关闭套接字，输入缓冲区的数据将丢失，且不再允许输入

因此 write 函数在将数据发送到输出缓冲区的时候就会返回，它并不保证发送到网络，更不保证对端已经接收。

## 基于 UDP 的服务器端/客户端

UDP 最重要的作用就是根据端口将传到主机的数据包交付到最终的 UDP 套接字。（数据包是依靠 IP 协议过来的）

UDP 中只有创建套接字的过程和数据交换过程。
不同于 TCP 在接收 10 个客户端连接的时候要用 11 个套接字，UDP 用一个套接字接收所有的信息。
UDP 在某种意义上来说无法区分服务器端还是客户端（因为没有请求连接和受理连接的过程）。

```c
ssize_t sentto(int sock, void *buff, size_t ntytes, int flags, struct sockaddr *to, socklen_t addrlen);
ssize_t recvfrom(int sock, void *buff, size_t nbytes, int flags, struct sockaddr *from, socklen_t *addrlen);
```

> 端口分配问题
>
> TCP 在客户端调用 connect 函数时会自动分配 IP 地址和端口号。
> UDP 可以用 bind 进行绑定也可以不用（bind 不区分 UDP 还是 TCP）；不用时它会在首次 sentto 时自动分配 IP 和端口号，并在后序中一直使用此IP+端口。

**已连接与未连接的 UDP 套接字**

TCP 必须要调用 connect 函数注册目的 IP 和端口进行连接；而 UDP 是可选的，注册后可以优化效率（不会每次发数据都有下方的 1、3 过程了）。
未连接的套接字（不调用 connect 函数）发送数据会有以下三个阶段：

- 1. 向 UDP 套接字注册目标 IP 和端口（注意，是注册，而不是连接）
- 2. 传输数据
- 3. 删除 UDP 套接字中注册的 IP 和端口

> 注意 bind 和 connect 函数的区别：
>
> bind 函数用于 socket 与本地 IP+端口 进行绑定。
> connect 函数用于注册目标IP+端口。


流控制是区分 UDP 和 TCP 的重要标志。
TCP 的速度无法超过 UDP，但在手法某些类型的数据时有可能接近 UDP。例如每次交换的数据量越大，TCP 的传输速率就越接近 UDP 的传输速率。

TCP 比 UDP 慢的原因通常有以下两点：

- 收发数据前后的连接设置和清除设置（三次握手、四次挥手）
- 手法数据中保证可靠性的流控制

## 优雅地断开套接字连接-半关闭

> 第七章

socket 是进行双向通信的，linux 的 close 函数会单方面地断开连接，即停止接收又停止对端输入，会造成对端发送的数据发送不过来。
因此引入半关闭：只关闭一部分数据交换中使用的流。

shutdown 函数可以控制只关闭 socket 的部分流。
```c
int shutdown(int sock, int howto);
```

由参数二 howto 来控制：

- SHUT_RD：只关闭输入流（读）
- SHUT_WR：只关闭输出流（写）
- SHUT_RDWR：同时关闭输入和输出

> 如何收到对端的输出的关闭信息
>
> 对端断开输出流的时候最后会发送 EOF。EOF 同样也是用于文件发送结束的标志。

## 域名与网络地址

> 第八章

DNS 是 IP 地址与域名相互转换的系统，核心是 DNS 服务器。
DNS 是一种分布式数据库系统。

> 可通过 `nslookup` 命令查询对应 server 的 DNS 服务器地址。（不携带参数时会进入交互模式）

利用域名获取 IP
```c
struct hostent * gethostbyname(const char* hostname);

struct hostent {
    char * h_name;       // 官方名
    char ** h_aliases;   // 别名列表
    int h_addrtype;      // 地址类型，ipv4 或 ipv6
    int h_length;        // IP 地址个数
    char ** h_addr_list; // IP 地址列表
}
```

利用 IP 获取域名：

```c
struct hostent * gethostbyaddr(const char * addr, socklen_t len, int family);
```

扩展：

go 中是用
```go
net.LookupAddr("8.8.8.8") // 地址查对应的域名
net.LookupNS("baidu.com") // 查域名对应的地址信息
```

## 套接字中的多种可选项

> 第九章 [参考](https://blog.csdn.net/amoscykl/article/details/80261754)

![选项列表1](https://leanote.com/api/file/getImage?fileId=5af32319ab64413fc1002d0f)
![选项列表2](https://leanote.com/api/file/getImage?fileId=5af3231aab64413fc1002d19)

套接字选项按层分三类：
- IPPROTO_IP，
- IPPROTO_TCP
- SOL_SOCKET

设置方法
```c
int getsockopt(int sock, int level, int optname, void *optval, socklen_t *optlen); // 获取信息，通过 optval 获取
int setsockopt(int sock, int level, int optname, void *optval, socklen_t optlen);  // 设置信息
```

```
// socket 类
SO_TYPE 是套接字类型（流/报文），只读，不可修改
SO_SNDBUF 输出缓冲区大小
SO_RCVBUF 输入缓冲区大小
SO_REUSEADDR 应对 time-wait 状态
// tcp 类
TCP_NODELAY 控制禁用 Nagle 算法
// IP 类（略）
```

### Time-wait 状态的理解与解决

在客户端与服务器已经建立连接的情况下，直接 Ctrl+C 关闭服务器端，会由服务器端向客户端发送 FIN 消息断开 TCP 连接。这时立刻重启服务器将输出 `bind() error`。约 3 分钟后才可成功启动。
注意，在 Client 端主动断开连接不会发生这种情况。

这是因为在四次挥手过程中，先发起 FIN 的一方在最后一次通信后会进入 **Time-wait 状态**。
此状态的目的是为了应对最后的 ACK 可能的重传。当 TCP 在此状态时，端口仍被占用。

![TCP四次挥手状态变化](/assets/tcpip_wavehands.png)

解决 Time-wait 导致的地址被占用需要用到 SO_REUSEADDR 选项，此选项用于可将 Time-wait 状态的套接字端口号重新分配给新的套接字。

> 为什么是 2MSL？
> MSL，Maximum Segment Lifetime，报文最大生存时间。一个报文消息在网络上传播最长经过 1MSL 就会消失，这里设置为 2MSL 是为了等待对端的重传消息，2MSL 的时间正好是一来一往的时间。设置的再长的话副作用会大于正作用，有异常可以通过 RST 状态来应答。

### Nagle 算法

TCP 默认使用了 Nagle 算法。Nagle 是为了防止因数据包过多而发生网络过载而存在的。

在不使用 Nagle 算法的时候，发送小块数据时每写入一段数据，数据进入输出缓冲区后将立即被发送出去，此时也会为每一块数据返回一个 ACK。
启用 Nagle 算法时，会在第一次数据被写入输出缓冲区时发送出去，在等待 ACK 的过程中余下数据一直在输出缓冲区中被收集，直到收到 ACK 才将余下的多块数据一次发送出去。

可见，在启用 Nagle 算法后，发送网络数据的次数变少了，由于每次数据中都会包含底层协议的头信息等，所以更节省网络流量。
但 Nagle 算法不是在什么时候都适用，如上，条件中是传输的很多的小块数据，如果传输的是大文件数据，那输出缓冲区会很快填满被发送出去，不使用 Nagle 算法依然很高效。

由上：Nagle 算法启用后，会提高传输效率，但不是传输速度，能降低传输的次数，但传输时长可能会增加。

## 多进程服务器端

> 第十章

- 多进程服务器：通过创建多个进程提供服务
- 多路复用服务器：通过捆绑并统一管理 I/O 对象提供服务
- 多线程服务器：通过生成与客户端等量的线程提供服务

进程是占用内存空间的正在运行的程序。

fork 函数会在此行代码处创建进程的副本，父进程和子进程返回不同的 pid（父进程返回 pid 为 0），然后两个进程共享后面的代码。（因此后面的代码需要在逻辑上判断父进程和子进程分别处理）

### 僵尸进程

在子进程中 main 函数 return 或调用 exit 函数后可以终止子进程，此时这两个调用会将返回信息传递给操作系统，此时操作系统并不会被销毁子进程。在这种状态下的进程就是僵尸进程。
销毁的时机是在父进程主动将这些返回信息从操作系统中获取后才会被销毁。（简言之是为了传递信息）
另外，如果父进程结束，僵尸进程也会结束。

> `ps au` 命令下 `STAT` 列为 `Z+` 的就是僵尸进程。

因此，在编程中使用子进程，父进程应当有责任主动请求子进程的返回值，返回值是保存在函数参数所指向的内存空间。

- 方式一： 使用 wait 函数。可以使用 wait 函数结束子进程（一个 wait 函数对应一个子进程的结束，否则阻塞）
- 方式二： 使用 waitpid 函数。可以不阻塞，且可指定等待子进程的 pid，并加入一些控制参数
```c
pid_t wait(int * statloc); // wait 函数，通过 status 变量收集子进程退出的信息
pid_t waitpid(pid_t pid, int * statloc, int options); // 可以用不阻塞的方式
```

### 信号处理及利用信号消灭僵尸进程

signal 函数，可以注册一个信号并绑定一个回调函数。

```c
void (*signal(int signo, void (*func)(int)))(int);
// 函数名： signal
// 参数: int signo, void (*func)(int)
// 返回类型：void 型函数指针
```

> sigaction 函数可完全替代 signal 函数（相当于弃用版）。

子进程终止将产生一个 SIGCHLD 信号，可通过注册方法当事件到达时获取子进程信息达到销毁子进程的目的。

## 进程间通信

> 第十一章（此处讲的过于简单，还是看其他文章了解更详细的使用吧）

管道 PIPE

```c
int pipe(int filedes[2]); // 创建管道 filedes[0] 为出口， filedes[1] 为入口
```

## 多播与广播

多播和广播都是通过 UDP 实现的，注意不要混淆两者。

多播是向加入（注册）到特定组的主机发送数据；（多播有注册到组的过程）
广播是向同一网络中的主机传输数据。（广播直接按同一个网络分组）

多播由路由器完成数据包的复制工作并发给多个主机，路由器负责，减轻网络压力。如传输文件只需要发送 1 次，由关系到多播组中的路由器负责复制文件并传入到主机，由于这种特性，多播主要用于“多媒体数据的实时传输”。（如果路由器不支持多播，可以使用隧道 Tunneling 技术实现）。

实现：

```c
// Sender
int time_live=64; // 设置多播的 TTL（路由器最大跳转次数，属于 IP 协议的控制字段）
setsockopt(send_sock, IPPROTO_IP, IP_MULTICAST_TTL, (void*) &time_live, sizeof(time_live)); // 设置选项
// Receiver 代码实现
struct ip_mreq join_adr;
join_adr.imr_multiaddr.s_addr=inet_addr(argv[1]); // 设置多播地址（Sender的地址，注意端口号一致）
join_adr.imr_interface.s_addr=htonl(INADDR_ANY);
setsockopt(recv_sock, IPPROTO_IP, IP_ADD_MEMBERSHIP, (void*)&join_adr, sizeof(join_adr)); // 设置选项加入多播组
```

本地广播使用的 IP 地址限定为 255.255.255.255；向其他网络广播需要将 IP 地址中除了网络地址外，其余主机地址全部设置为 1。

实现：
```c
// Sender 部分
int bcast = 1; // 对变量进行初始化以将 SO_BROADCAST 选项信息设置为 1.
setsockopt(send_sock, SOL_SOCKET, SO_BROADCAST, (void*) &bcast, sizeof(bcast));
// Recevier 部分没有特别的代码
```

---

接下来的章节，因为看的浅或讲得不深就不再整理了

12 IO 复用，主要讲了 select
13 多种 IO 函数 send/recv，readv/writev（多个套接字的缓冲区同时读/写），中间穿插了 TCP 的紧急消息“带外数据”
14 多播和广播
15 套接字和标准 IO
16 关于 IO 分离的其他内容
17 epoll
18 多线程服务器端的实现（`phtread_create`），包含了线程同步的互斥量、信号量
21 异步通知 IO 模型
22 重叠 IO 模型
23 IOCP
