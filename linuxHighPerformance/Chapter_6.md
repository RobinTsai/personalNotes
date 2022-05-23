# 第六章 高级IO函数

这些函数在特定条件下有优秀的性能。


**零拷贝**：在两个文件描述符之间直接传递数据（完全在内核中操作），从而可以避免内核缓冲区和用户缓冲区之间的数据拷贝，效率很高，这被成为零拷贝。

零拷贝操作有：

- sendfile(), 将某文件描述符指向的文件内容发送（必须是指向文件的文件描述符）到另一个文件描述符中
- splice(), 任意两个文件描述符之间移动数据
- tee(), 在两个管道文件描述符（必须是管道文件描述符）之间复制数据

## pipe()

用于创建一个管道，以实现进程间通信。

```c
int pipe(int fd[2]) // 返回成功或失败
```

输入为一个初始化的两 int 元素的数组，pipe 函数会填充他们，`fd[1]` 只用于写，`fd[0]` 只用于读，分别构成管道的两端形成单向通道。

如果要实现双向通道，需要用两个 pipe 函数。

pipe 的两个 fd 有默认 65536 字节的缓冲区（整体来说类似于 Go 语言中 channel 的读写）。

socket 的基础API 还有个方便创建双向管道的函数：
```c
int socketpair(int domain, int type, int protocol, int fd[2]) // domain 只可是本地的 AF_UNIX 协议族（本地文件用）
```

## dup()/dup2()

用于复制文件描述符。

```c
int dup(int fd) // 返回相同的 fd 指向
int dup2(int fd_one, int fd_two) // 返回相同的 fd 指向，且描述符>=fd_two
```

dup 返回相同的 fd 指向，可用于文件、管道或网络连接，且返回的 fd 总是取系统当前可用的最小值。

dup2 与 dup 类似，只不过它返回第一个不小于 fd_two 的整数值。

如当某函数中有以下一段代码：
```c
close( STDOUT_FILENO ); // 关闭标准输出
dup( connfd ); // dup 会返回 1，即重新创建出了 STDOUT，此时会将标准输出的内容都输入到 connfd
printf( "abcd\n" ); // 会将 abcd 输出到标准输出并输入到 connfd （客户端）
```

## readv()/writev()

readv() 将数据从文件描述符读到分散的内存块中，即分散读；
writev() 将多块分散的内存数据一并写入文件描述符中，即集中写。

```c
ssize_t readv(int fd, const struct iovec* vector, int count)
ssize_t writev(int fd, const struct iovec* vector, int count)
```

fd 是被操作的目标文件描述符。

vector 是 iovec 结构数组，iovec 描述一块内存区；count 参数是数组的长度，即多少个内存区。

## sendfile()

发送文件到另一个文件描述符。是个零拷贝操作。

```c
ssize_t sendfile(int out_fd, int in_fd, off_t* offset, size_t count)
```

- in_fd 是待读出的文件描述符，必须是一个指向文件的文件描述符，不能是 socket 或管道
- out_fd 是待写入的文件描述符
- offset 是指定从读入文件流的那个位置开始读
- count 传递的字节数

## mmap()/munmap()

mmap() 用于申请一段内存空间，将这段内存空间用作进程间通信的共享内存，也可以将文件映射到其中。

munmap() 用于释放这一块内存。

```c
void* mmap(void *start, size_t length, int prot, int flags, int fd, off_t offset) // 返回目标内存区域的指针
int munmap(void *start, size_t length)
```

- start 为内存的起始地址，若为 NULL，则自动分配一个地址
- length 为内存段的长度
- prot 为内存段的权限设置：可读、可写、可执行、不可被访问。
- flags 用于控制内存段内容被修改后程序的行为
- fd 为被映射的文件描述符，必须是文件（可以不映射文件）
- offset 为从文件的何处开始映射

## splice()

用于在**两个文件描述符**之间**移动**数据，也是零拷贝操作。

```c
ssize_t splice(int fd_in, loff_t* off_in, int fd_out, loff_t* off_out, size_t len, unsigned int flags)
```

- fd_in 源数据 fd，如果是管道文件描述符，那么 off_in 必须为 NULL，fd_in 和 fd_out 必须有一个是管道文件描述符
- off_in 源数据 offset
- fd_out 目的 fd，与 fd_in 含义一致。
- off_out 目的 offset
- len 指定移动数据的长度
- flags 控制数据如何移动

## tee()

在**两个管道文件描述符**之间**复制**数据（与 splice 类似，但此处为**复制**），是零拷贝操作。（可以用 tee 函数来实现 tee 程序）

```c
ssize_t tee(int fd_in, int fd_out, size_t len, unsigned int flags)
```

- fd_in、fd_out 必须都是管道文件描述符

## fcntl()

file control，用于对文件描述符的各种控制。

```C
int fcntl(int fd, int cmd, ...)
```