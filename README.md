# 读书速查笔记 {ignore=true}

> 温故而知新
>
> 苟日新，日日新，又日新

## 哪些看过的书

- [精通正则表达式](/docs/others/noteOfProfessionalRegex.md)
- [Linux命令行与shell脚本编程大全(第3版)](./shell/noteFromBook.md)
- [TCP/IP 网络编程](/docs/tcpIp/tcpIpNetProgramming.md)
- [linux高性能服务器编程——游双（著）](/docs/linuxHighPerformance/README.md)
- [MySQL 是怎样运行的：从根儿上理解 MySQL](/docs/mysql/howMySqlRun/README.md)
- [MongoDB 核心原理与实践](/docs/mongoDB/README.md)

## goBlackHat

> 《Go黑帽子 渗透测试编程之道》的程序例子

- port_scan: 端口扫描示例
- echo: 回显服务的实现；代理服务转发 tcp 流的实现
- server_shell: 在服务器中开启一个 shell，执行客户端的任意输入命令（TCP）
- ws_xss: 脚本注入攻击，使用 websocket 收集用户输入
- reverse_proxy: http 反向代理，根据请求 Host 代理到其他服务
- ws_shell: 通过 websocket 与 server_shell 相交互，可以在服务器上执行任意 shell 命令
- TODO：DNS 利用
- TODO：lua 脚本
- TODO：gopacket 包，解码数据包，类似 tcpdump 功能
    - pcap 子包发现可用的网络接口
    - BPF 语法
    - 检查 TCP 标志位来透过 SYN 泛洪保护
        - SYN 泛洪保护：所有打开、关闭和过滤的端口都会产生相同的包交换，以表明该端口处于打开状态。主要为了应对端口探测，让其失去判断力。
        - 检查 TCP 标志位能透过 SYN 泛洪保护的原因：一般情况下 TCP 连接建立之后会立即进行数据交换，所以可以通过标志位来判断后方端口是否真的开启。
- TODO：plugin 的使用（局限：移植性）
- TODO：lua 脚本（gopher-lua）
- TODO：加密算法的技术点
- TODO：根据 PNG 格式特点，编写一个隐藏术程式
- TODO：实操一个 C2 远控木马


## linux高性能服务器编程


TODO...

## HowMySqlRun

> 《MySQL 是怎样运行的》

- [查询计划](./howMySqlRun/%E6%9F%A5%E8%AF%A2%E8%AE%A1%E5%88%92.md)
- [BufferPool缓存池](./howMySqlRun/BufferPool%E7%BC%93%E5%AD%98%E6%B1%A0.md)
- [join原理](./howMySqlRun/join%E5%8E%9F%E7%90%86.md)
- [redo日志](./howMySqlRun/redo%20%E6%97%A5%E5%BF%97.md)
- [undo日志](./howMySqlRun/undo%20%E6%97%A5%E5%BF%97.md)
- [事务](./howMySqlRun/%E4%BA%8B%E5%8A%A1.md)
- [事务的隔离级别和MVCC](./howMySqlRun/%E4%BA%8B%E5%8A%A1%E7%9A%84%E9%9A%94%E7%A6%BB%E7%BA%A7%E5%88%AB%E5%92%8CMVCC.md)
- [锁](./howMySqlRun/%E9%94%81.md)

## RedisDevOps

- [五大类型细讲](./redisDevOps/%E4%BA%94%E5%A4%A7%E7%B1%BB%E5%9E%8B%E7%BB%86%E8%AE%B2.md)
- [全局命令和五大类型命令表](./redisDevOps/%E5%85%A8%E5%B1%80%E5%91%BD%E4%BB%A4%E5%92%8C%E4%BA%94%E5%A4%A7%E7%B1%BB%E5%9E%8B%E5%91%BD%E4%BB%A4%E8%A1%A8.md)
- [内存优化](./redisDevOps/%E5%86%85%E5%AD%98%E4%BC%98%E5%8C%96.md)
- [内存回收策略](./redisDevOps/%E5%86%85%E5%AD%98%E5%9B%9E%E6%94%B6%E7%AD%96%E7%95%A5.md)
- [哨兵](./redisDevOps/%E5%93%A8%E5%85%B5.md)
- [复制](./redisDevOps/%E5%A4%8D%E5%88%B6.md)
- [小功能大作用](./redisDevOps/%E5%B0%8F%E5%8A%9F%E8%83%BD%E5%A4%A7%E4%BD%9C%E7%94%A8.md)
- [持久化-AOF](./redisDevOps/%E6%8C%81%E4%B9%85%E5%8C%96-AOF.md)
- [持久化-RDB](./redisDevOps/%E6%8C%81%E4%B9%85%E5%8C%96-RDB.md)
- [持久化-问题定位与优化](./redisDevOps/%E6%8C%81%E4%B9%85%E5%8C%96-%E9%97%AE%E9%A2%98%E5%AE%9A%E4%BD%8D%E4%B8%8E%E4%BC%98%E5%8C%96.md)
- [缓存设计](./redisDevOps/%E7%BC%93%E5%AD%98%E8%AE%BE%E8%AE%A1.md)
- [集群](./redisDevOps/%E9%9B%86%E7%BE%A4.md)

## ZooKeeper

- [README.md](./zookeeper/README.md)
- [分布式锁示例源码-Go](./zookeeper/src/main.go)

## Go语言设计与实现

- [Go语言设计与实现（上）](./goDesignAndImpl/go%E8%AF%AD%E8%A8%80%E8%AE%BE%E8%AE%A1%E4%B8%8E%E5%AE%9E%E7%8E%B0%EF%BC%88%E4%B8%8A%EF%BC%89.md)

## highPerformanceMySql

## MongoDB

- [MongoDB](./MongoDB/)

---

Markdown 中引入图片的示例

<img src='https://g.gravizo.com/svg?digraph G {label = "";labelloc = "t";Start -> Start [label="EC_Create (EC=ChannelEvt)"];Start -> UserAnswer [label=EC_Answer];Start -> FailEnd [label=EC_Hangup];UserAnswer -> UserAnswer [label=EC_Create];UserAnswer -> Talking [label=EC_Answer];UserAnswer -> FailEnd [label=EC_Hangup];Talking -> SuccEnd [label=FsEvtChannelHangup];}'/>
