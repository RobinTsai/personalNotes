#include <stdio.h>
#include <sys/socket.h>
#include <string.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <unistd.h>

/*
 * 运行：
 *  - `gcc hello_server.c -o hello_server` 编译并链接为可执行文件
 *  - 执行文件 `./hello_server 8080`
 * 使用：输入 `telnet <IP> 8080` 或通过 hello_client.c 来访问
 * 效果：返回 hello world! 并退出 socket 连接。
 */

void err_handling(char *message);

int main(int argc, char *argv[]) {
    int serv_sock;
    int clit_sock;

    struct sockaddr_in serv_addr;
    struct sockaddr_in clit_addr;
    socklen_t clit_addr_size;

    char message[] = "hello world!\n";
    if (argc != 2) {
        printf("Usage: %s <port>\n", argv[0]);
        exit(1);
    }

    serv_sock = socket(PF_INET, SOCK_STREAM, 0);
    if (serv_sock == -1)
        err_handling("socket() error");

    memset(&serv_addr, 0, sizeof(serv_addr)); // 结构体所有数据初始化为 0
    serv_addr.sin_family = AF_INET; // 设置 socket 接口协议族，AF_INET
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY); // 设置 socket 接口地址，host 字节序改为 network 字节序，long 型
    serv_addr.sin_port = htons(atoi(argv[1])); // 设置 socket 接口端口，host 字节序改为 network 字节序，short 型

    if (bind(serv_sock, (struct sockaddr*) &serv_addr, sizeof(serv_addr)) == -1)
        err_handling("bind() error");

    if (listen(serv_sock, 5) == -1)
        err_handling("listen() error");

    sleep(300);

    clit_addr_size =sizeof(clit_addr);
    clit_sock = accept(serv_sock, (struct  sockaddr*) &clit_addr, &clit_addr_size);
    if (clit_sock == -1)
        err_handling("accept() error");

    write(clit_sock, message, sizeof(message));
    close(clit_sock);
    close(serv_sock);
    return 0;
}

void err_handling(char *message) {
    fputs(message, stderr);
    fputc('\n', stderr);
    exit(1);
}

/*
 * memset(&serv_addr, 0, sizeof(serv_addr)) 结构体所有字节设置为 0
 * 服务端调用 socket 一般流程：
 *  socket() 创建一个套接字
 *  bind() 绑定地址
 *  listen() 监听 socket 信息，并设置缓冲
 *  accept() 受理请求
 *  write/read() 向 socket 中写/读数据
 *  close() 关闭套接字
 *
 * int socket(int, int, int); // 参数：协议族，套接字类型，协议信息
 *  属于 <sys/socket.h> 库下
 *  第一个参数为协议族，如
 *      PF_INET：IPv4 互联网协议族
 *      PF_INET6：IPv6 互联网协议族
 *      PF_LOCAL：本地通信的 UNIX 协议族
 *      PF_PACKET：底层套接字协议族
 *  第二个参数为套接字类型，如
 *      SOCK_STREAM：面向连接的套接字
 *      SOCK_DGRAM：面向消息的套接字
 *  第三个参数为协议名称，若套接字类型下只有一种协议则可以传递 0，否则必须填指定的协议名称，如
 *      IPPROTO_TCP，属于 SOCK_STREAM 类型下的协议
 *      IPPROTO_UDP，属于 SOCK_DGRAM 类型下的协议
 *
 */