# NAT

Network Address Translation，网络地址转换。

三种实现方式：

- 静态转换（Static Nat），指内部本地 IP 和外部公网 IP 之间的 **一一对应** 的转换。
- 动态转换（Dynamic Nat），公网 IP 随机，内网 IP 随机转成公网 IP。
- NAPT，端口多路复用/端口地址转换/地址超载（Port address Translation，PAT，Address Overloading），指内部网络所有主机均共享一个公网 IP，使用端口。
- Easy IP
- NAT Server，

## 静态 NAT

- 每个内网 IP 对应一个公网 IP。
- NAT 自动修改 IP 报文的 源IP 和 目的IP，将出网包的源 IP 修改为 NAT 公网 IP，入网包的目的 IP 修改为 NAT 内网 IP。

## 动态 NAT

- 地址池（Address group），从中选取未使用的进行使用
- 实际在用时仍是一一对应
- ACL 设置，允许那些 source IP/PORT，no-pat 还是 pat

## NAPT

- Network Address Port Translation
- 网络地址端口转换，内部 IP 可映射多个公网 IP，但不同的协议端口号使用不同的公网 IP 端口。
- 在 动态 NAT 中不加 no-pat 时候就是用了 NAPT

## Easy IP

- 原理与 NAPT 相同，同时转换 IP 和端口
- 但 Easy IP 没有地址池的概念，使用接口地址做 NAT 转换的公网地址
- > 接口地址就是网卡地址，接口地址变了出网 IP 就自动变
- 适用于不具备固定公网 IP 的场景，自动获取公网地址进行转换


## NAT Server

- 内网 IP 端口一一对应到公网 IP 端口，并常驻
- 外网可通过此公网 IP 端口访问内网 IP 端口提供的服务
- 类似于 SLB

### NAT 打洞

有一种解释是：私网 A 向外网 B 发送消息，一旦 A 和 B 呼叫发送了数据包，就打开了 A 与 B 之间的“洞”。

### 全锥形 NAT

- 内网 A 首次向外网主机发送包时创建映射关系，并为 A 分配一个公网端口
- 此时，内网 A （同样端口）再次向另一外网主机 S2 发送数据包时，同样使用此公网端口
- 此时，**任何外部主机** 只要向此公网端口发送数据包，都会被映射到 A 的内网 IP
- 总结： <font color=red>内 IP+PORT = NAT Pub IP+Port = 外部 ***任何*** 主机+ ***任何*** 端口</font> （这里 `=` 表示对应关系）

### IP 受限型 NAT

- 又叫，限制锥形 NAT
- 内网首次向外部主机发送数据包创建映射关系，并为 A 分配一个公网端口
- **此外网 IP**（任意端口）能向此公网端口发送数据包；**其他外部主机**均不能被通过
- 总结： <font color=red>内 IP+PORT = NAT Pub IP+Port = ***指定*** 外部主机+ ***任意*** 端口</font>

### 端口受限型 NAT

- 内网 A 首次向外部主机发送数据包创建映射关系，并为 A 分配一个公网端口
- 此时，仅 **此外网主机 IP+端口** 能向此公网端口发送数据包可以被通过，**其他端口**过来的均不会被通过
- 总结： <font color=red>内 IP+PORT = NAT Pub IP+Port = ***指定*** 外部主机 + ***指定*** 端口</font>

### 对称型 NAT

- 内网 A 首次向外部主机 S1 发送数据包创建映射关系，并为 A 分配一个公网端口 X
- 此时，A **同样源端口** 又向外部主机 S2 发送数据包，此时 NAT 又为其分配一个地址映射端口 Y
- 如果外部主机想要发送数据给 A，必须是收到 A 数据包的外部主机+端口，向映射地址 X/Y 均可通过
- 总结： <font color=red>内 IP + PORT = ***N*** 个 NAT Pub IP+Port = ***N*** 个 ***指定*** 外网主机+***指定***端口 </font>

> 一个内网 IP+port 向 N 个外部主机发送数据包，NAT 设备会为每个 pair 创建一个映射（N 个）；
> 而端口限制型 NAT 内网 IP+PORT 和 NAT IP+PORT 还是一一对应的。

### SNAT

- 源地址转换
- 内网要访问公网时，内网主动发起连接，此时 源地址 内网地址会被转换成公网地址。

### DNAT

- 目的地址转换
- 外网访问内网时，DNAT 会转换目的地址为内网地址。对于响应会将源地址转换为外网公网地址。
- 主要用于内部服务对外发布（这类似于 DNS Server）
