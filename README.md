# personalAugPro

## goBlackHat

《Go黑帽子 渗透测试编程之道》的读书笔记

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