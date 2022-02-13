#include <stdio.h>
#include <sys/socket.h>
#include <string.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <unistd.h>

/*
 * 运行：
 *  - 先在本地 8080 启动 hello_server
 *  - `gcc hello_client.c -o hello_client` 编译并链接为可执行文件
 *  - 执行文件 `./hello_client 127.0.0.1 8080`
 * 效果：返回 hello world! 并退出 socket 连接。
 */

void err_handling(char *message);

int main(int argc, char *argv[]) {
    int sock;
    struct sockaddr_in serv_addr;
    char message[30];
    int str_len;

    if (argc != 3) {
        printf("Ussage: %s <IP> <port>\n", argv[0]);
        exit(1);
    }

    sock = socket(PF_INET, SOCK_STREAM, 0);
    if (sock == -1)
        err_handling("socket() error");

    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = inet_addr(argv[1]);
    serv_addr.sin_port = htons(atoi(argv[2]));

    printf("created socket \n");
    if (connect(sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) == -1)
        err_handling("connect() error");

    printf("connected \n");

    str_len = read(sock, message, sizeof(message) - 1);
    if (str_len == -1)
        err_handling("read() error");

    printf("Message from server : %s \n", message);
    close(sock);
    return 0;
}

void err_handling(char *message) {
    fputs(message, stderr);
    fputc('\n', stderr);
    exit(1);
}