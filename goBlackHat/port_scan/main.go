/*
 * 端口探测
 *
 * 学到：
 *   tcp 连接正常即为开启，timeout 为防火墙，拒绝则为端口关闭
 *   （当前并不是最优的处理方式，应该考虑本地端口的占用而使用池化技术做）
 */

package main

import (
	"fmt"
	"net"
	"sync"
	"time"
)

func main() {
	host := "scanme.nmap.org"

	wg := sync.WaitGroup{}
	wg.Add(1024)
	for i := 0; i < 1024; i++ {
		go func(i int) {
			defer wg.Done()
			conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:%d", host, i), 3*time.Second)
			if err != nil {
				fmt.Println(err.Error())
				return
			}
			fmt.Println("opend port: ", i)

			defer conn.Close()
		}(i)
	}

	wg.Wait()

	fmt.Println("done")
}
