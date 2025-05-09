package main

import (
	"fmt"
	"sync"
)

/*
 * 三个协程循环打印 "dog" "cat" "fish"（不考虑优化版）
 * 用三个 channel 依次传递信息，注意死锁，注意退出的条件，注意读 channel 的判断
 */
func main() {
	ch1 := make(chan string, 0)
	ch2 := make(chan string, 0)
	ch3 := make(chan string, 0)
	done := make(chan struct{}, 0)

	wg := &sync.WaitGroup{}
	wg.Add(3)

	go goPrint(wg, 2, ch1, ch2, "dog", done)
	go goPrint(wg, 1, ch2, ch3, "cat", done)
	go goPrint(wg, 0, ch3, ch1, "fish", done)


	ch1 <- "fish"
	wg.Wait()
}

func goPrint(wg *sync.WaitGroup, id int, rec, send chan string, data string, done chan struct{}) {
	defer wg.Done()

	count := 100
	for count > -1 {
		select {
		case a, ok := <-rec:
			if !ok { // 注意检查关闭
				return
			}
			fmt.Println(id, count, a)

			if id == 0 && count == 1 { // 注意条件位置
				close(done) // 注意及时关闭和关闭的次数
				close(send)
				return
			}

			select {
			case send <- data:
			case <-done: // 所有读写 channel 的地方都应该附加 done 的验证
				close(send)
				return
			}
		case <-done:
			return
		}
		count--
	}
}
