/*
 * 小工具：端口探测，tcp连接正常即为开启，timeout为防火墙，拒绝则为端口关闭
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
