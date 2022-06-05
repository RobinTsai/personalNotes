package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"math/rand"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/samuel/go-zookeeper/zk"
)

const (
	LOG_LEVEL_DEBUG = 0
	LOG_LEVEL_INFO  = 1
	LOG_LEVEL_KEY   = 2 // 关键性日志
)

var ConnNilErr = errors.New("client conn nil")

var logLevel = LOG_LEVEL_KEY

// 辅助函数
func debug(in ...interface{}) {
	if logLevel > LOG_LEVEL_DEBUG {
		return
	}
	fmt.Println(in)
}
func info(in ...interface{}) {
	if logLevel > LOG_LEVEL_INFO {
		return
	}
	fmt.Println(in)
}
func keylog(in ...interface{}) {
	if logLevel > LOG_LEVEL_KEY {
		return
	}
	fmt.Println(in)
}

// 写一个分布式锁的逻辑
// 主要逻辑：
//  1. 在一个仅用于分布式锁的目录下（/lock）
//  2. 创建 临时 + 序列 子节点，会返回本节点 path
//  3. 获取子节点列表，排序
//  4. 判断当前节点是不是在最前，若是，即获取到锁，到第 6 步执行去逻辑，否则走第 5 步
//  5. watch 前者，添加回调，回调即从上面第 3~5 步开始递归。（只 watch 前者避免了惊群效应）
//  6. 表明获取到锁，执行业务逻辑
//  7. 执行完逻辑删除本节点 path（会触发在第 5 步中监听自己的线程）
func main() {
	start := time.Now()

	hosts := []string{"192.168.208.132:2181", "192.168.208.133:2181", "192.168.208.134:2181"}
	gcount := 100 // 可配置单节点最大连接数 maxClientCnxns=400，以满足自己并发要求（支持 n * 400，n 为节点数）
	lockPath := "/lock"
	wg := sync.WaitGroup{}

	{ // 保证有 /lock 目录，这块可以不关心
		conn, _, err := zk.Connect(hosts, time.Second*5)
		if err != nil {
			fmt.Println("[ERROR] init cli err", err.Error())
			return
		}
		conn.Create(lockPath, []byte("for one lock"), 0, zk.WorldACL(zk.PermAll)) // 成功或失败不验证
		defer func() {
			err = conn.Delete(lockPath, 0) // 由于有模拟节点直接断开连接，所以这里删除可能无效，不过不关心
			fmt.Println("delete pub lock res", err)
		}()
	}

	for i := 0; i < gcount; i++ {
		cli, err := newClient(hosts, i)
		if err != nil {
			fmt.Println("[ERROR] client", i, "create failed", err.Error())
			continue
		}
		wg.Add(1)
		// 模拟不同的 服务实例，取争抢 分布式 锁
		go func(cli *client, lockPath string) {
			defer func() {
				wg.Done()
				cli.Close()
			}()

			err = cli.createLock(lockPath)
			if err != nil {
				fmt.Println("[ERROR]", cli.id, "create lock failed", err.Error())
				return
			}

			err = cli.checkAndWait()
			if err != nil {
				fmt.Println("[ERROR]", cli.id, "check and wait failed", err.Error())
				return
			}
			sec := rand.Intn(1000)

			keylog(cli.id, "processing", sec, "milliseconds...")
			time.Sleep(time.Duration(sec) * time.Millisecond)
			keylog(cli.id, "process done ...")

			if cli.id%3 == 0 { // 模拟直接断开连接
				info(cli.id, cli.mylock, "disconnected without del key")
				return
			}

			err = cli.Delete(cli.mylock, 0)
			if err != nil {
				fmt.Println("[ERROR]", cli.id, cli.mylock, "delete failed", err.Error())
				return
			}
			info(cli.id, cli.mylock, "delete done.")

		}(cli, lockPath)
	}

	debug(time.Since(start), "all goroutine created")
	wg.Wait()
	debug(time.Since(start), "all goroutine done")
}

type client struct {
	*zk.Conn
	addrs  []string
	id     int // client id
	mylock string
	path   string
}

func newClient(hosts []string, id int) (*client, error) {
	// 连接zk
	conn, _, err := zk.Connect(hosts, time.Second*50, zk.WithLogInfo(false)) // 根据并发个数调整超时时间
	if err != nil {
		return nil, err
	}
	cli := &client{
		Conn:  conn,
		addrs: hosts,
		id:    id,
	}
	return cli, nil
}

func (c *client) createLock(path string) error {
	if c.Conn == nil {
		return ConnNilErr
	}

	c.path = path
	path = strings.TrimRight(path, "/")
	lockFullName := strings.Join([]string{path, "lock"}, "/")
	debug(c.id, "create lock", lockFullName)
	str, err := c.Conn.Create(lockFullName, []byte("create log"), zk.FlagSequence|zk.FlagEphemeral, zk.WorldACL(zk.PermAll))
	if err != nil {
		return err
	}
	c.mylock = str
	debug(c.id, "created lock done return", str)
	return nil
}

func (c *client) checkAndWait() error {
	cs, _, err := c.Children(c.path) // 可能有问题，先获取在加 watcher 可能前者会被删除
	if err != nil {
		return err
	}
	debug(c.id, c.mylock, "origin cs", cs) // 这里，不是按顺序获取到子节点的
	sort.Strings(cs)                       // 排序

	trimSlash := func(s string) string { // 避免是根节点
		return strings.TrimRight(s, "/")
	}

	{ // 模拟获取到子节点和在创建监听之间 有锁的变化的情况（会不会有问题呢？）
		if c.id%7 == 0 { // 离散一些，3 已经用过了，所以这里找了另一个质数
			time.Sleep(time.Duration(rand.Intn(30)) * time.Second) // 加大时长，出现监听了不存在的key
			// 但最终结果并不受影响，看了下逻辑，没问题，因为监听出错相当于没有比自己小的序列，
			// 如果 zk 确定自己总能获取到 xid 小于自己创建节点的话，那就没问题
			// 所幸的是，zk 有这样的保证：当自己创建了之后，获取子节点时候一定能获得到前面创建且未删除的
			// 因为当前 session 下既然写成功，那么在它这个 cZxid 之前的写入的一定也已经同步到这个节点
		}
	}
	// 判断当前序列的位置，并监听前者
	cur := 0
	for i := 0; i < len(cs); i++ {
		if c.path+"/"+cs[i] == c.mylock {
			cur = i
			break
		}
	}
	if cur == 0 {
		info(c.id, c.mylock, "got lock, cur cs:", cs)
		return nil
	}

	info(c.id, c.mylock, "will watch", cs[cur-1])
	_, _, ch, err := c.GetW(trimSlash(c.path) + "/" + cs[cur-1])
	if err != nil {
		return err
	}
	if ch == nil {
		return errors.New("empty watch chan")
	}

	select {
	case e := <-ch:
		b, _ := json.Marshal(e)
		debug("got event: ", string(b))
		switch e.State {
		case zk.StateDisconnected, zk.StateExpired, 3:
			return c.checkAndWait()
		default:
			return fmt.Errorf("uncovered state: %d", e.State)
		}
	}

	return nil
}
