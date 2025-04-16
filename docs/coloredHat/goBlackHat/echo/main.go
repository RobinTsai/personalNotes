/*
 * 1. 创建一个回显服务器
 * 2. 创建一个代理，代理 tcp 信息流到另一个服务 => 端口转发绕过防火墙的应用
 *
 * 使用：
 *   通过命令 `telnet <server_ip> <port>` 连接到此服务，然后进行任意对话
 *
 * 学到：
 *   io.Reader/Writer 的使用
 *   bufio.Reader/Writer 带缓冲的 Reader/Writer 的使用
 */
package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"strconv"
	"sync"
)

func main() {
	host := ""
	lis, err := net.Listen("tcp", host+":8082") // 在 80 端口上实现回显服务器
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	for {
		conn, err := lis.Accept()
		if err != nil {
			fmt.Println(err.Error())
			continue
		}

		var cases = []func(net.Conn){
			0: echo1,
			1: echo2,
			2: echo3,
			3: proxy1,
			4: proxy2,
		}

		idx := 0
		if len(os.Args) > 1 {
			idx, _ = strconv.Atoi(os.Args[1])
			idx %= len(cases)
		}

		handleFn := cases[idx]

		go handleFn(conn)
	}
}

// echo1 使用 io.Copy 直接连接的输出直接再写回到连接中
func echo1(conn net.Conn) {
	fmt.Println("use echo1...")
	defer conn.Close()

	// 这种形式下，io.Copy 一直是自循环的
	// 因为 conn 在没接收到数据时候是阻塞的，直到客户端发过来一次数据后，conn 就会读出一次，然后再由 io.Copy 写回到 conn，而后 conn 继续阻塞
	// 直到客户端主动断开
	if _, err := io.Copy(conn, conn); err != nil {
		fmt.Println(err.Error())
		return
	}
	fmt.Println("----")
}

// echo2 读出输入，原样写回到连接（client）
func echo2(conn net.Conn) {
	fmt.Println("use echo2...")
	defer conn.Close()

	b := make([]byte, 5) // 缓冲区大小固定，其效果是每次达到缓冲空间后，就会触发一次 flush，就自动写回.
	// 如果请求输入 20 个字符后回车，则会返回 4 次数据 + 1 次 \r\n（共22个字符）
	for { // 这里就不同于 io.Copy 了，需要自行加 for 进行循环，直到客户端断开链接
		size, err := conn.Read(b[0:])
		if err == io.EOF {
			log.Println("client disconnected")
			return
		}
		if err != nil {
			log.Println("unexpected err:", err.Error())
			return
		}

		fmt.Println("-> size", size, "cap", cap(b))
		if _, err := conn.Write(b[0:size]); err != nil {
			log.Println("unexpected err:", err.Error())
			return
		}
		fmt.Println()

		// continue
	}
}

// echo3 使用 bufio 的 Reader/Writer，可自定义输入数据的分隔符进行返回
// 这样的形式是自带了缓冲区，直到主动触发 writer.Flush 才会强制写一次到 conn，否则不会写
func echo3(conn net.Conn) {
	fmt.Println("use echo3...")
	defer conn.Close()

	for {
		reader := bufio.NewReader(conn)
		s, err := reader.ReadBytes('\n') // 以回车为分隔符分割数据
		if err != nil {
			fmt.Println(err.Error())
			break
		}

		writer := bufio.NewWriter(conn)
		_, err = writer.Write(s)
		if err != nil {
			fmt.Println(err.Error())
			break
		}
		writer.Flush()
	}

	fmt.Println("------- done")
}

var once = &sync.Once{}

// start dest server，启动目的服务器，用于被代理服务器
func startDstServer(host string, done chan struct{}) func() {
	return func() {
		lis, err := net.Listen("tcp", host) // 目的服务地址
		if err != nil {
			fmt.Println(err.Error())
			return
		}
		fmt.Println("---- dst server:", host)
		close(done)
		for { // 收到请求后返回 原数据并加上一个标识符前缀
			conn, err := lis.Accept()
			if err != nil {
				fmt.Println(err.Error())
				continue
			}

			fmt.Println("dst server got req")
			go func(conn net.Conn) {
				defer conn.Close()
				defer fmt.Println("dst server closed conn")

				for {
					data := make([]byte, 512)
					size, err := conn.Read(data[0:])
					if err == io.EOF {
						break
					}
					if err != nil {
						fmt.Println("start dest server err:", err.Error())
						return
					}
					if _, err = conn.Write(append([]byte("dest server "+host+" received: "), data[0:size]...)); err != nil {
						fmt.Println("write conn err:", err.Error())
						return
					}
				}
			}(conn)
		}
	}
}

// 代理服务
func proxy1(conn net.Conn) {
	host := ":8084" // 本代理服务代理此 host
	done := make(chan struct{})
	fmt.Println("proxy ", host)

	go once.Do(startDstServer(host, done)) // 异步模拟一个目的服务器
	<-done                                 // 得用 channel 确定先开启服务

	dstConn, err := net.Dial("tcp", host) // 连接到目的服务器
	if err != nil {
		fmt.Println("unable to connect", host, err.Error())
		return
	}
	fmt.Println("--- connect to", host)
	defer dstConn.Close()

	go func() {
		// 代理收到数据后，写入到 dst 中
		for {
			if _, err := io.Copy(dstConn, conn); err != nil {
				fmt.Println("----- ", err.Error())
			}
		}
	}()

	for {
		if _, err := io.Copy(conn, dstConn); err != nil {
			fmt.Println("----", err.Error())
		}
	}
}

// 代理服务
func proxy2(conn net.Conn) {
	host := ":8084" // 本代理服务代理此 host
	done := make(chan struct{})
	fmt.Println("proxy ", host)

	go once.Do(startDstServer(host, done)) // 异步模拟一个目的服务器
	<-done                                 // 得用 channel 确定先开启服务

	dstConn, err := net.Dial("tcp", host) // 连接到目的服务器
	if err != nil {
		fmt.Println("unable to connect", host, err.Error())
		return
	}
	fmt.Println("--- connect to", host)
	defer dstConn.Close()

	go func() {
		// 代理收到数据后，写入到 dst 中
		for {
			reader := bufio.NewReader(conn)
			writer := bufio.NewWriter(dstConn)
			byts, err := reader.ReadBytes('\n')
			if err != nil {
				fmt.Println("--- 1")
				break
			}
			byts = append([]byte("<proxy->dst>"), byts...)
			if _, err = writer.Write(byts); err != nil {
				fmt.Println("--- 2")
				break
			}
			writer.Flush()
		}
	}()

	for {
		reader := bufio.NewReader(dstConn)
		writer := bufio.NewWriter(conn)
		byts, err := reader.ReadBytes('\n')
		if err != nil {
			fmt.Println("--- 3")
			break
		}
		byts = append([]byte("<dst->proxy>"), byts...)
		if _, err = writer.Write(byts); err != nil {
			fmt.Println("--- 4")
			break
		}
		writer.Flush()
	}
	fmt.Println(" dst to conn done")
}
