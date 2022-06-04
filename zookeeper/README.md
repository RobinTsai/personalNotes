# zookeeper 总结

## 特性

zk 是个分布式协调服务。

- 易扩展。易扩展在于有 Observer 的角色。
- 可靠性。可靠性在于快速恢复（官方数字 200ms）和数据的一致性。


Observer 角色：工作中分有三个角色，Leader、Follower、Observer，其中 F 和 O 都可以提供查询工作，但只有 Follower 参与选举。这样的话可以增加 O 的数量，做降压的同时又不增加选主的速度（参与选主的一员越多，选主的时间越长）。

快速恢复。故障发现后，用单独的线程做恢复，届时完全拒绝对外提供服务。

数据一致性。zk 只有写成功过半的节点之后才会返回成功响应，而且有 sync 机制支持开发者主动做一次一致性同步。

### 一致性保证的原理 - ZAB协议

zk 中所有的 follower 都可以接收写请求，但会转发到 leader 由 leader 进行提议、所有的 follower 参与“评议”，过半同意后才真正写成功。

ZAB，zookeeper 的原子广播协议。A 原子，B 广播。

流程：
- follower 收到写请求
- 转发到 leader
- leader 记录 事务ID 
- leader 用队列发送消息到各个 follower
- 各个 follower 用日志记录变更，当还不会写入内存
- 各个 follower “评议”后对 leader 响应是否成功（假设都成功）
- leader 收到各个 follower 的响应后，过半成功后进行广播成功
- leader 响应客户端写请求

实现：zk 内部在向 follower 分发消息时是用的 队列 实现的，从而保证了 顺序上的一致性，通过过半机制广播立即写入内存实现原子性（不成功不写入）。（两阶段提交模式）

redis 比不上 zk 的可靠性（命令广播 vs ZAB 协议），但 redis 比 zk 快（全内存 vs 队列 + 磁盘 + 过半 + 内存）。

leader 的作用，处理“活锁”（大家都在努力，但总是发生冲突解决不了问题），让消息顺序化执行。可以从自己设计的角度去想象一下这里整体的设计，如果自己设计该怎么实现。

关于特性，这篇文章写的不错，一定要看下：[ZooKeeper ZAB协议](https://www.jianshu.com/p/3fec1f8bfc5f)

## 单机安装

（已经安装了，略写一下。）

ZK 是用 java 编写的，首先需要安装 JDK，才可以使用。

```yaml
zkServer.sh start  # 启动
zkServer.sh start-foreground # 前台启动，方便看日志，后台时日志记录在 logs 文件夹下
zkServer.sh status # 查看启动状态
zkCli.sh           # 连接到 zk 服务
```

若启动失败报错 类似错误是 没找到某个 java 相关的类，有可能是自己下载的版本是需要编译的，编译还需要安装 mvn（maven）比较麻烦，可以在官网上找对应 xxx-bin-xxx 版本的可直接解压使用。

启动发现报错有 8080 端口做 admin 服务的端口被占用，我本地用了 K8S 使用了此端口，网查可以加配置 `admin.serverPort=8887` 改变端口号。

安装后需要将 `conf/zoo-sample.cfg` 改为 `zoo.cfg` 默认会用此配置文件。

单机模式启动后用 `zkServer.sh status` 最终输出 `Mode: standalone`。

## 集群部署

zk 的集群需要配置所有的机器列表，而不像 redis 是通过 订阅发布 获取到集群内部信息的。

```
// 格式：server.id=ip:port:port[:observer]
server.1=192.168.208.132:2888:3888
server.2=192.168.208.133:2888:3888
server.3=192.168.208.134:2888:3888
```

其中 id 是需要写入到文件 `{dataDir}/myid` 中的数值。

zookeeper 用了三个端口：

- 2181 : 对 client 端提供服务（客户端连接端口）
- 2888 : 集群内机器通信使用（leader 接收并分发命令使用）
- 3888 : 选举 leader 投票使用（投票专用）
- （使用中发现还有一共 admin 用的端口，可配，许多博客上都没看到介绍）

> 集群中各节点是通过一端的 3888 相互连接的，按启动顺序，后启动者会用随机端口连接到已启动节点的 3888 端口。用于 leader 选举。

注意，有三个节点时启动第一个后执行 status 会显示失败，因为 3 个节点下至少 2 个节点启动后才能提供服务（当集群中节点数不满足过半时都会停止服务）。启动两个节点后，执行 status 后一个显示 leader 一个显示 follower。依次启动就好。

> 当前使用的版本（cli 和 server 是一起下载的） `ZooKeeper CLI version: 3.8.0-5a02a05eddb59aee6ac762f7ea82e92a68eb9c0f, built on 2022-02-25 08:49 UTC`

## 节点信息

zookeeper 中，存储结构是目录树，像 linux 目录一样的树，节点称为 znode，节点是以 key/value 形式存储数据的。

可以像操作目录一样执行命令，基础命令有 

```
ls /
set /abc "abc"
ls /abc
get /abc    // 通过 -s 查看统计信息
stat /abc   // 查看统计信息
delete /abc // 仅当此节点没有子节点时可删除
``` 

通过 `get -s PATH` 可以查看本节点值及统计信息：

```C
[zk: localhost:2181(CONNECTED) 17] get -s /abc // 执行的命令，通过 -s 查询序列信息
abc           // 存储的值
cZxid = 0x5   // create 的事务 ID
ctime = Sat Jun 04 20:23:25 CST 2022 // create time
mZxid = 0x100000003                  // modify 的事务 ID
mtime = Sat Jun 04 21:22:38 CST 2022 // modify time
pZxid = 0x5      // 当前节点及子节点中事务 ID 最大的值（不包含孙子等）
cversion = 0     // 本目录下子节点创建或删除的版本，在创建和删除子节点的时候加一，修改节点内容不加一
dataVersion = 1  // 当前节点数据的版本号，每修改一次加一
aclVersion = 0
ephemeralOwner = 0x0 // 临时节点的所有者（session id）
dataLength = 3       // 数据长度
numChildren = 0      // 当前节点的子节点个数（不包含孙子等）
[zk: localhost:2181(CONNECTED) 18] 
```

## SESSION

客户端每次连接到服务器时，服务器就默认为其创建一个唯一信息 session id。并在退出时自动删除此 session id。

```
// 用 zkCli.sh 连接成功后有日志
2022-06-04 22:02:36,479 [myid:localhost:2181] - INFO ... Session establishment complete on server localhost/0:0:0:0:0:0:0:1:2181, session id = 0x100001d8c540002, negotiated timeout = 30000
// 在执行 quit 退出时删除此 session
2022-06-04 22:03:02,037 [myid:] - INFO  ... Session: 0x100001d8c540002 closed
2022-06-04 22:03:02,048 [myid:] - INFO  ... EventThread shut down for session: 0x100001d8c540002
```

## 基础特性的命令使用

### 序列节点

> 注，这里的节点是说目录树结构中的一个 node 点（znode）

```yml
# ---- 在 zk-master 中操作
[zk: localhost:2181(CONNECTED) 9] create -s /seq "abc"
Created /seq0000000013
[zk: localhost:2181(CONNECTED) 10] ls /
[seq0000000013, zookeeper]
[zk: localhost:2181(CONNECTED) 11] create -s /next 
Created /next0000000014
[zk: localhost:2181(CONNECTED) 12] ls /
[next0000000014, seq0000000013, zookeeper]
[zk: localhost:2181(CONNECTED) 13] 
# --- 紧接着，在 zk-node1 中操作
[zk: localhost:2181(CONNECTED) 10] create -s /node1 # 可见 seq 是在集群下递增的
Created /node10000000015
[zk: localhost:2181(CONNECTED) 11] ls /
[next0000000014, node10000000015, seq0000000013, zookeeper]
[zk: localhost:2181(CONNECTED) 12] 
# --- ...
[zk: localhost:2181(CONNECTED) 14] create -s /seq
Created /seq0000000016
[zk: localhost:2181(CONNECTED) 15] 
```

### 临时性节点

```yaml
# --- 在 zk-master 上操作
[zk: localhost:2181(CONNECTED) 14] create -e /lock
Created /lock
[zk: localhost:2181(CONNECTED) 15] get -s /lock 
null
cZxid = 0x600000037
ctime = Sun Jun 05 01:27:03 CST 2022
mZxid = 0x600000037
mtime = Sun Jun 05 01:27:03 CST 2022
pZxid = 0x600000037
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x10000ee29dd0002 # 本 ID 为本 session 的 ID
dataLength = 0
numChildren = 0
[zk: localhost:2181(CONNECTED) 16] create -e /lock # 再次创建不成功
Node already exists: /lock
[zk: localhost:2181(CONNECTED) 17] 
# --- 紧接着，在 zk-node1 上创建 ephemeral 锁
[zk: localhost:2181(CONNECTED) 15] create -e /lock
Node already exists: /lock
[zk: localhost:2181(CONNECTED) 16] 
# --- ctrl+c 关闭 zk-master 的客户端后，大约 30s 在 zk-node1 上看到 /lock 消失

# 另外，在另一个 session 中可以对非此 session 创建的 e 节点随意删除、修改，这样不冲突。
# 所以 e 节点的特别之处似乎只是在于 生命周期上和 session 相绑定。
```

### 临时节点和序列节点一起使用

```YAML
# --- 在 zk-master 上创建 /lockes 临时 序列 节点
[zk: localhost:2181(CONNECTED) 2] ls /
[zookeeper]
[zk: localhost:2181(CONNECTED) 3] create -e -s /lockes
Created /lockes0000000018
[zk: localhost:2181(CONNECTED) 4] ls /
[lockes0000000018, zookeeper]
[zk: localhost:2181(CONNECTED) 5] 

# --- 紧接着，在 zk-node1 上创建，并查看
[zk: localhost:2181(CONNECTED) 44] ls /
[lockes0000000018, zookeeper]
[zk: localhost:2181(CONNECTED) 45] create -e -s /lockes
Created /lockes0000000019
[zk: localhost:2181(CONNECTED) 46] get -s /lockes0000000018 
null
cZxid = 0x600000041
ctime = Sun Jun 05 01:48:16 CST 2022
mZxid = 0x600000041
mtime = Sun Jun 05 01:48:16 CST 2022
pZxid = 0x600000041
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x10000ee29dd0003 # zk-master 中 session ID
dataLength = 0
numChildren = 0
[zk: localhost:2181(CONNECTED) 47] get -s /lockes0000000019 
null
cZxid = 0x600000042
ctime = Sun Jun 05 01:48:49 CST 2022
mZxid = 0x600000042
mtime = Sun Jun 05 01:48:49 CST 2022
pZxid = 0x600000042
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x20000ee1d900002 # zk-node1 中 sessionID
dataLength = 0
numChildren = 0
[zk: localhost:2181(CONNECTED) 48] 

# --- ctrl+c zk-master 中的客户端后，在 zk-node1 上查看 xxx18 消失
[zk: localhost:2181(CONNECTED) 48] ls /
[lockes0000000018, lockes0000000019, zookeeper]
[zk: localhost:2181(CONNECTED) 49] ls
ls [-s] [-w] [-R] path
[zk: localhost:2181(CONNECTED) 50] ls /
[lockes0000000019, zookeeper]

# --- 新开 session，在此 session 删除 zk-node1 用 -e -s 创建的节点
[zk: localhost:2181(CONNECTED) 1] delete /lockes0000000019 # 成功！可以删除
[zk: localhost:2181(CONNECTED) 2] 

# --- ephemeral 节点下是不可以有子节点的
[zk: localhost:2181(CONNECTED) 66] create /lockes0000000019/a
Ephemerals cannot have children: /lockes0000000019/a
```

### watch 的使用

```YML
[zk: localhost:2181(CONNECTED) 39] ls /
[zookeeper]
[zk: localhost:2181(CONNECTED) 40] create /lockes # 创建一个节点用于监听
Created /lockes
[zk: localhost:2181(CONNECTED) 41] add
addWatch   addauth    
[zk: localhost:2181(CONNECTED) 41] addWatch /lockes # 添加监听器
[zk: localhost:2181(CONNECTED) 42] set /lockes "abc" # 更新值触发事件

WATCHER::

WatchedEvent state:SyncConnected type:NodeDataChanged path:/lockes #
[zk: localhost:2181(CONNECTED) 43] create /lockes/sub "sub info"

WATCHER::

WatchedEvent state:SyncConnected type:NodeCreated path:/lockes/sub
Created /lockes/sub
[zk: localhost:2181(CONNECTED) 44] set /lockes/sub "refine sub info" # 新增子节点触发事件

WATCHER::

WatchedEvent state:SyncConnected type:NodeDataChanged path:/lockes/sub
[zk: localhost:2181(CONNECTED) 45] create /lockes/sub/sub2 "abc" # 新增孙子节点触发事件

WATCHER::

WatchedEvent state:SyncConnected type:NodeCreated path:/lockes/sub/sub2
Created /lockes/sub/sub2
[zk: localhost:2181(CONNECTED) 46] set /lockes/sub/sub2 "refine" # 修改孙子节点触发事件

WATCHER::

WatchedEvent state:SyncConnected type:NodeDataChanged path:/lockes/sub/sub2
[zk: localhost:2181(CONNECTED) 47] delete /lockes/sub/sub2 # 删除孙子节点触发事件

WATCHER::

WatchedEvent state:SyncConnected type:NodeDeleted path:/lockes/sub/sub2
[zk: localhost:2181(CONNECTED) 48] delete /lockes/sub # 删除子节点触发事件

WATCHER::

WatchedEvent state:SyncConnected type:NodeDeleted path:/lockes/sub
[zk: localhost:2181(CONNECTED) 49] delete /lockes # 删除本节点触发事件

WATCHER::

WatchedEvent state:SyncConnected type:NodeDeleted path:/lockes
[zk: localhost:2181(CONNECTED) 50] ls /
[zookeeper]
[zk: localhost:2181(CONNECTED) 51] create /lockes "new one" # 重新创建节点仍能触发事件（删除节点后，事件不会消失）

WATCHER::

WatchedEvent state:SyncConnected type:NodeCreated path:/lockes
Created /lockes
[zk: localhost:2181(CONNECTED) 52] 
```

### 完整命令支持列表

随意在 zkCli 中输入不存在的命令能看到完整的命令支持列表

```
ZooKeeper -server host:port -client-configuration properties-file cmd args
	addWatch [-m mode] path # optional mode is one of [PERSISTENT, PERSISTENT_RECURSIVE] - default is PERSISTENT_RECURSIVE
	addauth scheme auth
	close 
	config [-c] [-w] [-s]
	connect host:port
	create [-s] [-e] [-c] [-t ttl] path [data] [acl]
	delete [-v version] path
	deleteall path [-b batch size]
	delquota [-n|-b|-N|-B] path
	get [-s] [-w] path
	getAcl [-s] path
	getAllChildrenNumber path
	getEphemerals path
	history 
	listquota path
	ls [-s] [-w] [-R] path
	printwatches on|off
	quit 
	reconfig [-s] [-v version] [[-file path] | [-members serverID=host:port1:port2;port3[,...]*]] | [-add serverId=host:port1:port2;port3[,...]]* [-remove serverId[,...]*]
	redo cmdno
	removewatches path [-c|-d|-a] [-l]
	set [-s] [-v version] path data
	setAcl [-s] [-v version] [-R] path acl
	setquota -n|-b|-N|-B val path
	stat [-w] path
	sync path
	version 
	whoami 
Command not found: Command not found help
```

## 选举过程

过程和 redis 主从中选主操作几乎是一样的，优先级：
- 数据最多的最优先（zk 中是 事务ID，redis 中是复制偏移量）
- redis 特有的按通信最好的
- 然后按 id 排序（zk 按 id 大的，redis 是按 id 小的）

> 投票过程中会先推荐自己，然后传输数据中携带 事务ID，由此按最大 事务ID 选举。 
> redis 有两个选举过程，一个是 哨兵 在做故障转移之前选举一个领导者；一个是主从状态下，主节点宕机，从从节点中选举主节点的过程。

> 3888 是选举过程中的通信端口，zk 是两两连接的；
> 在 redis 中故障转移选主节点时是通过 发布订阅 中进行选举的；哨兵的选举是通过……

## 分布式锁

- 1. 只能由一个获得锁（zk 一致性能保证）
- 2. 获得锁的人如果挂了，需要释放锁，所以用 临时节点（ephemeral 节点）
- 3. 获得锁的人如何释放锁，
- 4. 其他抢锁者如何知道锁的释放
    - 4.1 方案一：主动轮询，弊端：延迟、压力
    - 4.2 方案二：watch 
        - 4.2.1 watch 节点进行回调，可以解决延时问题，但可能造成“惊群”问题造成压力（watch 者很多，都在进行争抢锁）
        - 4.2.2 sequence 节点 + watch 子节点的前一个 seq，可以保证队列式获得锁（前者释放锁后只会发起后一个 seq 者的回调，避免“惊群”）
