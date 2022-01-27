/*
 * 在服务器上开 shell 执行任意客户端命令
 *
 * 这个号称是 netcat 的安全巨洞：nc -lp 13337 -e /bin/bash，但通过 nc 命令没试出来
 * 用代码实现了，将此程序运行在服务器上，可以通过客户端执行任意的命令文本来实现在服务器上执行此任意的命令，而在客户端得到结果
 *
 * 使用：
 *   通过命令 `telnet <server_ip> <port>` 连接到服务，然后发送任意命令
 *
 * 学到：
 *   Flusher.Write 相当于重写了 io.Write, 从而得到执行，函数内再自定义 bufio.Writer 的使用方法
 */
package main

import (
	"bufio"
	"io"
	"log"
	"net"
	"os/exec"
)

func main() {
	lis, err := net.Listen("tcp", ":80") // <server_ip>:<port>
	if err != nil {
		log.Fatalln(err.Error())
	}

	for {
		conn, err := lis.Accept()
		if err != nil {
			log.Println(err.Error())
			return
		}

		go handle(conn)
	}
}

func handle(conn net.Conn) {
	cmd := exec.Command("/bin/sh", "-i") // 在服务端用 shell 执行命令
	cmd.Stdin = conn                     // stdin 对接到客户端的输入
	cmd.Stdout = NewFlusher(conn)        // stdout 对接到客户端的输出
	if err := cmd.Run(); err != nil {    // 以上，就可以通过客户端 (telnet) 访问
		log.Fatalln(err.Error())
	}
}

type Flusher struct {
	w *bufio.Writer
}

func NewFlusher(w io.Writer) *Flusher {
	return &Flusher{
		w: bufio.NewWriter(w),
	}
}

func (foo *Flusher) Write(b []byte) (int, error) {
	count, err := foo.w.Write(b)
	if err != nil {
		return -1, nil
	}
	if err := foo.w.Flush(); err != nil {
		return -1, err
	}

	return count, nil
}
