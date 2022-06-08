# go语言设计与实现（上）

为原书从开头到 6.2 章内容的笔记，同时同步到 [简书：go语言设计与实现（上）](https://www.jianshu.com/p/275b6f3ba7b0)

## 编译原理

![编译原理](https://upload-images.jianshu.io/upload_images/3491218-84bef2a41536d56e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/480)


- 静态单赋值，SSA，代码优化方式的一种，主要是在编译期间确保变量只赋值一次。
- 默认类型转换有三种场景：传值、返回值、赋值定义时。

## 数据结构

### 数组

- 连续的内存空间；
- 同一类型：元素类型相同且长度相同；
- `[...]int{1,2,3}` 编译期间推导出大小；
- 对于字面量数组，当 `len<=4` 时，在栈上分配；`len>4`时在 **静态区** 分配，运行时取出；
- 编译期间可检查出简单的越界问题，但仅限于简单的越界；

 ![内存分配模型](https://upload-images.jianshu.io/upload_images/3491218-fc641de8c61d6ba3.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/480)

### 切片

- 数据结构：一个指向数组的指针、Len、Cap；

```go
// 内部实现结构
// 转换方法： (*reflect.SliceHeader)(unsafe.Pointer(&A))
type SliceHeader struct { 
    Data uintptr
    Len int 
    Cap int
}
```

- 创建方式：1. 切一段数组；2. 字面量初始化；3. make关键字；
- 使用字面量初始化时：先创建数组，然后赋值，然后创建指针指向数组，然后取切片[:]；
- 使用 make 创建切片时：
    - 先创建数组，然后取切片；
    - 大切片（>32K）或会发生内存逃逸时，在堆上初始化；
- 扩容 = 新申请内存 + 拷贝（memmove）；
    - 大切片的拷贝会有性能问题。
    - `oldLen < 1024，newCap = 2 * oldCap`
    - `oldLen >= 1024, newCap = oldCap + 1/4 * oldCap`；
    - `expectedCap > 2 * oldCap, newCap = expectedCap`
    - 若 newCap < 0（int 越界时），则 newCap = expectedCap（这是内部代码的逻辑，不要想太多）
- 一般使用 `a = append(b, c)`中，若没有 a 参数接收，编译器会自动优化为将 c 只对底层数组进行操作（但不会改变 b 的 cap）。

> 所以将切片+两个通道设计为弹性伸缩的通道队列不会有内存泄漏的问题，弹性通道的设计有以下三步：
> - `buf = append(buf, <-inChan)` （入队）
> - `outCh <- buf[0]` 首个被使用（弹出）
> - `buf = buf[1:]` （更新队列）
>
> 但由于扩容会发生拷贝，所以在 buf 写入速度大于读取速度且量很大时，还是会有性能问题。

> memmove：是将内存块中的内存拷贝到目标内存区。内置 copy 函数用到了它，虽然说相比于一个个拷贝性能更好，但仍然避免不了大切片拷贝的性能问题。

### 哈希表

先独自思考一下基本的设计思路：
- 哈希函数取余 + 数组
- 由于哈希碰撞，数组 => 数组（桶） + 链表
- 由于效率期望 O(1) 问题，链表尽可能短 => 扩容，时机 => 计算装载率

> 预备内容：
> - 哈希碰撞：哈希函数对不同内容哈希取模后可能映射到相同的索引上，这种问题在哈希表中就叫哈希碰撞。
> - 解决哈希碰撞的一般方法：1. 开放寻址法；2. 拉链法。
> - 装载率：`装载率 = 元素数量 / 数组大小 * 100%`
> - 哈希的读写性能关键：1. 哈希函数；2. 定位桶的效率；3. 遍历链表。
 
 ![Map数据结构](https://upload-images.jianshu.io/upload_images/3491218-04cb1a07ac463baa.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 对应到上方“基本设计思路”：
    - 哈希种子 hash0，在创建时就确定
    - 连续的桶：正常桶 + 溢出桶，正常桶内有 8 个空间，溢出桶是“桶级的链表”
    - 渐进扩容和整理：buckets、oldbuckets、nevacuate，新桶起始地址、旧桶起始地址、迁移数量
- 扩容时机：
    - 装载因子 > 6.5，触发正常扩容（增量扩容，容量会增加）；
    - 溢出桶太多，触发等量扩容（只整理，容量不增加，会提高查询效率）。
- 增量扩容是渐进式，当删除遇上扩容，会等扩容分流结束后才做删除工作；
- 逻辑删除，溢出桶的设计相当于“整理”，可以加速查询，但大量删除后元素所占用的内存并不会被释放。
- B<4时无溢出桶；B>4时分配 2^B 个正常桶，2^(B-4) 个溢出桶；
- map 不可取址，map中的元素也不可取址。这是因为 map 本身是引用类型，对它取址无意义；map 中的元素的地址是在扩容中会变化的，取址也没意义，所以在设计上就设计为不可取址（静态检查不过）。

### 字符串

- C语言是字符数组 `char[]`，Go中是只读的字节数组。（在编译期间标记成只读数据 `SRODATA`）。不支持直接修改 string 类型变量的内存空间。
- 结构 `reflect.StringHeader`：一个 Data 指针和一个 Len 字段（共 16 字节）。
- 所有在字符串上的写操作都是通过拷贝实现的。主要损耗就是拷贝。
- 大量字符串拼接对性能有损耗，不可频繁拼，且大字符串莫拼。
- 字符串与 `[]byte` 的相互类型转换对性能也有损耗，不要大量使用。

> 火焰图查看性能损耗时，`runtime.slicebytetostring` 和 `runtime.stringtoslicebyte` 就是 byte、string 互相转换的损耗。性能损耗随着长度的增长而增长。

## 语言基础

### 函数调用

- C 语言在传值时前 6 个参数用寄存器，多余的部分用栈传递，返回值用寄存器传递。Go统一用栈传递。统一后虽然性能跟不上用寄存器，但更易维护，跨平台设计也更简单。（用寄存器更快）
- 函数的入参（从右向左依次入栈）和返回值都需要在栈上分配。
- Go语言只有值传递。所以任何类型都会被拷贝。注意大内存数据的值传递带来的性能损耗，最好用指针。

> 其实这里没讲闭包的使用。一个函数 A 返回了另一个函数 B（B 函数用了 A 函数中定义的变量），假设 `b1 = A(), b2 = A()`，则 b1、b2 函数各自拥有 A 中声明的变量。

### 接口

类型转换、类型断言、动态派发。iface，eface。

- Go的接口是一组方法的签名。
- 接口作用：解耦；隐藏底层实现。
- Go中的 interface{} 不能包含成员变量，这点与Java不同。
- 编译时接口类型自动检查的三种：赋值、传参、返参。接收器也算是一种传参的方式。
- interface{} 不是任意类型！不是任意类型！不是任意类型！（看似任意，实际是隐式转换），验证：“nil” 不等于 nil（“nil” 中有类型信息）。
- interface{} 类型断言（具体类型的断言）的内部实现是用一个名为 hash 的属性来判断的（更快）。
- 动态派发：就是在运行期间判断接口的实现者确定对应的函数调用。
- 动态派发有性能开销。用结构体实现有125%的开销（相比于直接调用），用指针实现的接口有18%的开销，开启编译器优化后后者开销约5%。
- 即：定义接口类型最好是用指针做实现。
- 又即：避免用结构体实现接口：1. 值拷贝的开销；2. 动态派发的开销；3. 使用也方便（许多涉及锁的地方避免锁的拷贝）

### 反射

三个对象：具体对象、接口对象、反射对象。

![接口对象与反射对象](https://upload-images.jianshu.io/upload_images/3491218-9df504084aaf7f57.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/480)

- 三大法则：
    - 接口对象可以转换为反射对象（reflect.TypeOf/ValueOf）；
    - 反射对象可以转换为接口对象（reflect.Value.Interface）；
    - 修改反射对象，值必须是可设置的（指针的 `reflect.Value.Elem.SetInt()`）；
- `reflect.Value.Elem()` 是得到可以被设置的变量（指针指向的变量）。

> 没有 `VALUE.(interface{})` 这样类型转换的语句。
> 但有这样的类型断言语句，如 `VALUE.(interface{ Error() string })` ，其中 VALUE 必须是 interface{} 类型。

反射对象具有的方法：

```go
type Type interface {
  Align() int
  FieldAlign() int 
  Method(int) Method                 // 通过下标返回方法
  MethodByName(string) (Method, int) // 通过String找方法
  NumMethod() int                    // 方法个数
  Implement(u Type) bool             // 判断是否实现了某 reflect.Type 类型
  NumIn() int                        // 返回入参个数
  // ...
}

type Value struct {/* ... */}
func (v Value) Addr() Value
func (v Value) Bool() bool
func (v Value) Bytes() []byte
// ...
```

## 常用关键字

### for range

- 无论 for range 什么类型，都会转换成三段式普通 for 循环；
- 值拷贝，循环中修改值不会成为永动机；
- `for _, v := range arr` v 总是一个地址，一直被覆盖；
- for 中很多编译优化：
    - for 循环去设置元素零值，会优化为直接清空这片内存；
    - `for range a {}`（只关心元素个数）优化为 `i:=0; i<len(a); i++`
    - `for i := range a {}` 优化和上一步一样，只是在内部取了 i 的值；
- for range map 时，故意引入随机性，随机找一个桶作为开始（但也不是环形有序的）。
-  for range channel 时，也转换成三段式，结束条件是channel被关闭
- for range 字符串时内部对其进行 rune 解码后返回。

### select

- 当多个 case 同时触发时，会随机选一个；
- 可以有重复的 case。这很 tricky（可以用它来验证随机性）。
- 随机的引入是为了避免饥饿问题的发生。

编译优化：
- 不存在任何 case 时直接阻塞
- 只存在一个为 nil 的 case 时直接阻塞
- 只存在一个正常 case 时改为正常 if 语句

内部实现：
- 内部实现用了 goto 标签，将 Default、Recv、Send 三种分成共七种 case 进行跳转
- 这里还是省略很多内容，需要后面细看

### defer

- 调用时机是在函数返回的时候调用，调用顺序按先进后出的栈式（实质是链表结构）原则
- 预计算参数：在 defer 函数定义时就计算好参数值。另外参考文章[《defer 和闭包》](https://www.jianshu.com/p/b4fb3d361d87)
- 数据结构：
```go
type _defer struct {
	started bool
	heap    bool
	sp        uintptr // sp at time of defer，栈指针
	pc        uintptr // pc at time of defer，程序计数器
	fn        func()  // can be nil for open-coded defers
	_panic    *_panic // panic that is running defer
	link      *_defer // next defer on G; can point to either heap or stack! // 组成链表
	// ...
}
```
- 编译过程：……
- 运行过程：
    - 创建。会优先从缓存池中创建，依次为：调度器的缓存池、Goroutine 的缓存池、新建一个结构体。创建后会加入到链表的最前端。
    - 执行。执行是在链表上从前向后执行，由插入是插到最前，所以看起来是“栈”式的调用过程。

### panic 和 recover

- panic 只能让本 goroutine 下的 defer 触发（所以 recover 也只能在本协程）；
- recover 只能放在 defer 中才有效；
- panic 允许在 defer 中使用，且嵌套多次也可以；
- panic 日志一直在收集，直到所有的 defer 执行完毕才输出到 stderr 中；
- panic 结构：

```GO
type _panic struct {
	argp      unsafe.Pointer
	arg       interface{} // panic 传入的参数
	link      *_panic // panic 函数链表，指向上一次（因为只能在 defer 中才能有两个 panic）调用的 panic
	recovered bool // 是否被 recover 恢复
	aborted   bool // 当前的 panic 是否被强行终止（需要更详细解释）
	pc        uintptr
	sp        unsafe.Pointer
	goexit    bool // 是否调用了 runtime.Goexit （recover 不恢复  runtime.Goexit 的退出）（runtime.Goexit 也只退出当前 goroutine）
}
```

- panic 函数是如何终止程序的（假设没遇到 recover）：
    - 创建新的 runtime._panic 结构并添加在所在 goroutine 的 _panic 链表最前面；
    - 循环从当前 goroutine 的 _defer 链表中获取函数并调用；
    - 最终调用 `runtime.fatalpanic` 终止程序，fatalpanic 会先打印 panic 消息，然后通过 runtime.exit 退出程序并返回错误码 2。
- 崩溃恢复（逻辑在上述过程的循环中的 _defer 函数内）：
    - recover 函数中没多少逻辑：
        1. 如果当前 Goroutine 没调用 _panic （_panic 链表为 nil）或已经被 recover 或使用了 runtime.Goexit，则会直接返回 nil；
        2. 否则返回 panic 函数的参数 p.argp（即 recover 的返回参数），并设置 _panic.recoverd = true
    - panic 在执行 defer 链表过程中判断 _panic.recovered 字段为 true 时恢复程序运行。（恢复是由 panic 相关的 gopanic 函数负责的）

> 问：recover 之后的逻辑该怎么执行呢？
> 答：会跳转到 _defer 函数链表的 recover 后（会恢复 _defer 中存的程序计数器 pc 和栈指针 sp 及返回值）去执行。
>
> 追问：不是本来就是这样吗，为什么要特殊说明呢？
> 答：本来不是这样，要知道这个过程是在 panic 过程中的，是由 panic 函数调起 _defer 链表的执行的，正常的话是调完 _defer 链表后会走到下面的 fatalpanic，而这里相当于是 goto **跳转** 过去的。

### make 和 new

- make 只用在切片、哈希表和 channel 上，初始化的是**内置的结构**，返回的是值；
- new 是**在堆上**申请空间，然后返回对象的**指针**；（即指向零值的指针）

## 并发编程

### Context

- Context 让多个协程的终止时间归一。

```go
type Context interface {
  Deadline() (deadline time.Time, ok bool) // 返回截止时间
  Done() <-chan struct{}                   // 返回关闭的channel指针，用于获取关闭的信息
  Err() error                              // 获取Context结束的原因
  Value(key interface{}) interface{}       // 获取键对应的值
}
```
```go
// 返回 Context 的几种方法：
func Background() Context {} // 空的接口实现
func TODO() Context {}       // 空的接口实现
// 下面三个的返回值都是一个 ctx 和一个取消函数
func WithCancel(p Context) (Context, CancelFunc) {}                   // 可取消的ctx, cancelCtx
func WithDeadline(p Context, d time.Time) (Context, CancelFunc) {}    // 带超时的cancelCtx
func WithTimeout(p Context, t time.Duration) (Context, CancelFunc) {} // 调用了WithDeadline
// 设置 value 用的，链式存的
func WithValue(p Context, key, val interface{}) Context {} // 可设置值的ctx
``` 

实现 Context 接口有以下几个类型（空实现就忽略了）：
- cancelCtx，通过 WithCancel 创建；
- valueCtx，通过 WithValue 创建；
- timerCtx，通过 WithDeadline 和 WithTimeout 创建。

---

- 他们都是通过 Context 字段组成指向父节点形成链表。
- 一个 valueCtx 节点只能存储一个 key-value 对，查询键值对时会在链表上查。结构如下：

```go
type valueCtx struct {
	Context
	key, val interface{}
}
```

- timerCtx 结构中嵌入了 cancelCtx，只不过是多了一个 `time.After()` 来调用 cancelCtx 的取消函数。结构如下：
```go
type timerCtx struct {
	cancelCtx
	timer *time.Timer // Under cancelCtx.mu.
	deadline time.Time
}
```

- cancelCtx 的结构和设计模型如下图示。（timerCtx 底层也是 cancelCtx 所以不展开它的设计原则了）

 ![cancelCtx的设计模型](https://upload-images.jianshu.io/upload_images/3491218-2db8330a19e17d9b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- 如上可知，cancelCtx 是通过多叉树的方式进行存储的，多叉树中不包含 valueCtx。（timerCtx 也会创建 cancelCtx 所以是包含的）
- cancelCtx 的 *传递取消关系* 函数的逻辑：    
    > propagateCancel 应该理解为 传递取消关系 的意思
    ```go
    // propagateCancel arranges for child to be canceled when parent is.
    func propagateCancel(parent Context, child canceler) {
        done := parent.Done()
        // ...
        select {
        case <-done:
            child.cancel(false, parent.Err()) // parent 已经取消
            return
        default:
        }

        if p, ok := parentCancelCtx(parent); ok { // 此函数会找到上层最近的 cancelCtx
            // ...
            p.children[child] = struct{}{} // 加入扁平多叉树结构中
        } else {
            go func() {
                select { // 阻塞判断
                case <-parent.Done():
                    child.cancel(false, parent.Err())
                case <-child.Done():
                }
            }()
        }
    }
    ```

- `parentCancelCtx()` 方法值得注意，它找上层 cancelCtx 的时候是通过 Value() 方法查找到最近的 cancelCtx 的，`p, ok := parent.Value(&cancelCtxKey).(*cancelCtx)`。（注意 timeCtx 也会创建一个 cancelCtx）
- 可以通过 Value 方法找上层的 cancelCtx 是因为 cancelCtx 类型的 Value 方法当输入 key 是 `&cancelCtxKey` （cancelCtxKey 是个全局唯一量）时，直接返回自身。
    ```go
    func (c *cancelCtx) Value(key any) any {
        if key == &cancelCtxKey {
            return c
        }
        return value(c.Context, key)
    }
    ```

### 锁

#### 互斥锁

```go
type Mutex struct { // 总共空间 8 字节
    state int32 // 计数（29 bit）+三个状态（3 bit，依次为：饥饿、唤醒、上锁）
    sema uint32 // 信号量
}
```

> 饥饿模式：
> 在正常模式下，所有锁的等待者是在一个 **FIFO 队列**中依次获取锁。但当一个新的 goroutine 来争抢锁时，可能会比第一个等待者优先获得（因为自旋），为了减少这种情况的出现，防止 goroutine 被“饿死”，所以有了“饥饿模式”（在这种场景下保证公平性）。

- 一旦某协程超过 1ms 没获取到锁，就会将锁切换到饥饿模式。
- 饥饿模式下，锁会被当前占用的协程直接交给第一个等待者。这时，新唤起的协程不会再进入自旋状态，而是乖乖地加到队列末尾。
- 如果某获得锁的协程是队列的最后一个，或者它的等待时间小于 1ms，则会将饥饿状态切换到正常状态。

<br>

- 锁的自旋：会一直占用 CPU（坏处），检查锁的状态来争抢锁。自旋最多四次，每次会调用 30 次 PAUSE，PAUSE 指令什么也不做，但占用 CPU。
- 自旋的好处是避免 Goroutine 的切换，某些场景下执行更高效。
- 锁自旋有利有弊，为了利用它的利，给它设置了苛刻的先提条件：
    1. 程序运行在多核 CPU 上；
    2. 自旋次数限制最大 4 次；
    3. 当前至少存在一个正在运行的处理器 P 且处理的运行队列是空的。

互斥锁的控制逻辑：

- Fast path：直接进行 CAS(&state, 0, 1)，相当于直接用了底层的 CAS 原子操作（大多数场景下无竞争，高效）。若不成功走 slow path。
- Slow path 包含等待队列、饥饿模式、锁的自旋等复杂的处理。在一个大 for 循环下进行
    - `old&(mutexLocked|mutexStarving) == mutexLocked && runtime_canSpin(iter)`：只是单纯的被锁（非饥饿状态）且可以自旋，则先争抢一次锁，若不成功进行自旋
        > `runtime_canSpin()` 调用的是 runtime/proc.go 下 `sync_runtime_canSpin()`，判断了自旋次数、cpu 核数、和存在空闲P。
    - 其他略

> Mutex 是个混合锁，如上面所提用到了自旋锁和信号量。在 Go 源码的其他地方也大量用了 Mutex 做基础的构件来实现并发串行控制。

---

#### 读写锁

```go 
type RWMutex struct {
    w           Mutex  // 读写锁用 Mutex 锁做基础
    // 写信号量，由写操作申请，由最后一个被等待的读者 RUnlock 时释放
    writerSem   uint32 
    // 读信号量，由读申请使用，“写”在 Unlock 时释放 readerCount 个
    readerSem   uint32 
    // 为正数时，是正在读的读者（相当于已经获取了读锁）的个数；
    // 为负数时，为 正在读的个数 - (1 << 30)
    readerCount int32  
    // 只在 readerCount 为负数时使用，表明是写锁在等待读者的个数
    readerWait  int32  
}
```

设计思路：

> RWMutex 中内嵌的 Mutex （`rw.w`）是用来做 **写与写** 并发控制的锁；
> RWMutex 中不需要对读与读的做并发控制，读会用 **原子计数** 方式来计数；
> **读和写**的并发控制是 **原子计数** 和 **信号量**（可以说 **再加上 Mutex**）配合完成的。
>
> 以下是读和写并发控制的设计思路，主要靠两个计数和两个信号量相互配合完成。

- 读上锁 RLock 的时候，readerCount 原子加一；解锁 RUnlock 的时候会原子减一；
- 当写锁 Lock 发生时，
    1. 先上写与写并发控制的锁 `rw.w.Lock()`；
    2. 然后将 readerCount 置成负值（减去最大允许并发读数 `1 << 30`，表明已经有写操作参与）；
    3. 然后这个协程判断 *原 readerCount*，若为 0，则直接获得了锁；
        > ***原 readerCount***：函数 `r := atomic.AddInt32(&rw.readerCount, -rwmutexMaxReaders) + rwmutexMaxReaders` 原子操作后再加回来返回旧值
    4. 若*原 readerCount* 非 0，则将这个值（*原 readerCount*）原子加到 readerWait 中；（变成了 waiter，标记写操作前有多少个读者，即写操作在等待多少个读完成）
    5. 紧接着判断 waiter 是否为 0。若不为 0，则申请写信号量（**写被读阻塞**）；否则函数结束，表明上锁成功。
- 当读锁要上锁时发现 readerCount + 1 后为负值时（有写在前面执行或排队），会申请读信号量；（**读被写阻塞**）
- 在读锁解锁 RUnlock 时，readerCount - 1 后发现小于0，则（知道自己 RLock 后有一个写操作申请 Lock 了，即自己是被写操作等待的一员）对 readerWait 也原子减一，完成后若 readerWait 为 0（自己是最后一个被等待者），则释放一个写的信号量（**写得到了锁**）
    > 写与写之间是通过 Mutex 互斥的，它底层是用的队列，所以在这个过程中不用管有几个写或解锁的是哪个写，队列保证了它的顺序。

----

（以上为写被读阻塞与解阻塞，下面是读被写阻塞）
- 上面提到了，读在上锁时，原子计数到 readerCount 中。若更新后的值小于零，则知道写正在进行，则自己申请读信号；
- 写在解锁时，
    - 先让 readerCount 置成正数（加上最大允许并发读数）；
    - 然后释放 readerCount （新正数值）个读的信号量。
    - 最后解开与其他写并发控制的锁 `rw.w.Unlock()`

总结，读写锁的设计还是非常巧妙的：
- 用了 Mutex 做写与写的互斥；
- 读和写的并发都会是 FIFO 顺序的（读阻塞后面的写，写阻塞后面的读），使用了原子计数和信号量来控制；
- 原子计数有两个数值相切换表达了多个意义：正在读的个数、写锁之前的读者个数、有写锁时所有读者的个数；
- 用读/写信号量来做并发中的顺序控制。

> 忽然想到一个疑问点，这样的设计是不是也包含了 读-写-读-写 这样的顺序的锁，支持多少个呢，是不是与 `const rwmutexMaxReaders = 1 << 30` 有关？（待分析）

### WaitGroup

作用：等待一组协程结束，且可以有多个等待者。

设计思路：

- WaitGroup 由两个计数器和信号量完成设计。
- 计数器有两个，
    - 一个是记录使用 Add(1) 开启协程的协程计数器，这里记作 counter；
    - 另一个是调用 Wait() 在等待进度中的协程的计数器，这里记作 waiterCounter。
- 通过信号量控制 Wait() 的阻塞开关，在 Wait 中申请，每个 Wait 申请一个，在 counter 变为 0 的时候释放 waiterCounter 个。

```go
type WaitGroup struct { // go version 1.18
    noCopy noCopy // 用于 go vet 检测用

    // 64位值：高32位为协程计数器，低32位是等待者计数器。
    // 64位原子操作要求 64 位对齐，但32位编译器只保证了32位对齐 
    // 因此在32位架构中会在 state() 函数中判断是否 state1 被对齐，
    // 然后动态 swap 字段的顺序获取这两个值的意义（这里用 64 位机做注解）
    state1 uint64 // 状态，高32位为 counter；低32位为 waiterCounter
    state2 uint32 // 信号量
}
```

WaitGroup 有三个暴露的函数:
```go
func (wg *WaitGroup) Add(delta int) 
func (wg *WaitGroup) Done()  // 调用 Add(-1)
func (wg *WaitGroup) Wait()
```

- Add 函数：可以传入负值，但如果 counter （高 32 位）为负值就会 panic，如果 counter 变为 0 就会释放 waiterCounter （低 32 数值）个信号量
- Wait 函数：如果 counter 为 0，表明不需要阻塞；否则 state + 1 （相当于 waiterCounter + 1）并申请一个信号量

> `state := atomic.LoadUint64(statep)`，LoadUint64 函数从 *uint64 中获取 uint64 值，使用这个函数是为了避免 *uint64 正在被另一个线程写入，造成只写了部分就被读取，比如 32 位架构中会每 32 位写一次。

部件：
- 信号量
- 计数器 * 2 个

### Once

设计思路：

- 一个是否执行过的标记值（这里用了 uint32），0 表示未执行，1 表示已经执行
- 一个互斥锁，用于控制并发

结构：
```go
type Once struct {
	done uint32 // 是否调用过
	m    Mutex  // 用于并发控制（bad impl: 用原子计算做并发控制）
}
```

Once 只暴露了一个方法：
```go
func (o *Once) Do(f func())
```

实现：

```go
func (o *Once) Do(f func()) {
    if atomic.LoadUint32(&o.done) == 0 { // fast path
        o.doSlow(f)
    }
}
func (o *Once) doSlow(f func()) {
    o.m.Lock() // 用锁，而不是原子数值操作，
    // 因为 Do 保证了当执行完时 f 一定执行过了
    // 如果是原子数值操作没有阻塞行为，无法保证上句话
    defer o.m.Unlock()
    if o.done == 0 {
        defer atomic.StoreUint32(&o.done, 1) // 即便 f panic 也会认为执行过
        f()
    }
}
```

三个关键点：
- 第一个是 fast path 原子判断 done 值，因为在 done == 1 的场景会很多，所以先做此步判断会很有效率。
- 第二点用的是 Mutex.Lock()，用它保证了 f 一定执行完才走后面的逻辑。（这里不能用原子数值操作，否则无法保证 f 一定执行完后才进行后面的逻辑）
- 第三点是获得锁后需要再次判断 done 的值，并在执行后更新 done 值。

细节：

- Do 保证执行完成后 f 一定时执行过了的。
    - 这就要求一定要用锁，而不能是原子数值操作。因为原子数值操作返回 false 时不会执行 f 就继续执行下面的逻辑。
    - defer 保证了即便 panic 也会保持这种特性。
        > 思考，其实不用 defer 也行：在 o.done==0 块内首先执行原子加一
- **如果 f 中再调用此 Do 函数，将会发生死锁**。

> 源码注释中 `niladic function` 的意思为“没有参数的函数”

### Cond

让多协程任务的开始执行时间可控（按顺序或归一）。（Context 是控制结束时间）

设计思路： 通过一个锁和内置的 notifyList 队列实现，Wait() 会生成票据，并将等待协程信息加入链表中，等待控制协程中发送信号通知一个（Signal()）或所有（Boardcast()）等待者（内部实现是通过票据通知的）来控制协程解除阻塞。

> notifyList 不是通过队列实现顺序，而是通过票据 ticket 来实现顺序的。
> 票据，类似去银行办业务时会在机器上先生成一个编号，然后等待叫号。此设计中的锁的用法就是为了生成票据的时候并发安全。

```go
type Cond struct {
    noCopy noCopy 
    L Locker           // *Mutex 或 *RWMutex
    notify  notifyList //
    checker copyChecker
}
type notifyList struct {
    wait   uint32 // 等待者的票据（编号，表示下一个等待者要分配的编号是几）
    notify uint32 // 下一个要通知的编号/票据，这个编号会存储在 *sudog.ticket 上
    // wait - notify 是当前有多少在阻塞状态的等待者

    // 链表信息，用链表存储
    lock   uintptr        // key field of the mutex
    head   unsafe.Pointer // 链表头节点，底层是 *sudog 类型，即等待状态的 goroutine 类型
    tail   unsafe.Pointer // 链表尾节点
}
```

暴露四个函数：
```go
func NewCond(l Locker) *Cond // 初始化一个 Cond 实例
func (c *Cond) Wait()        // 调用 Wait 前需要先上锁，Wait 中会先解锁
func (c *Cond) Signal()      // 通知第一个协程开始执行
func (c *Cond) Broadcast()   // 广播，让所有的协程都开始执行
```

实现细节：
-  Wait() 函数流程：
	- 会先获取当前票据 t = c.notify.wait 然后给 c.notify.wait 原子 + 1；
	- 然后解锁 `c.L.Unlock()`；
	- 然后将 t 加入到等待队列中；
	- 最后调用一次 `c.L.Lock()`。
	    ```go
		func (c *Cond) Wait() {
			c.checker.check()
			t := runtime_notifyListAdd(&c.notify) // 获取票据并增加 c.notify.wait
			c.L.Unlock() // 解锁
			runtime_notifyListWait(&c.notify, t) // 将此票据加入等待队列
			c.L.Lock() // 再次上锁，恢复用户 Lock 的场景
		}
		``` 
	> 注意开发者在使用 Wait() 函数时需要被 `c.L.Lock()`  和 `c.L.Unlock()` 包裹，所以在外层的这个“上锁”之间并不是原子的，而是被 Wait 分开两段原子逻辑。
	> 由上一条可知在加入等待队列这个操作不是顺序的，所以需要“票据 ticket”这个信息。可以通过 `runtime_notifyListNotifyOne` 源码看到，是在链表上循环查找直到查到票据或遍历完才结束
- Singal() 函数直接调用 `runtime_notifyListNotifyOne(&c.notify)` 即通知 c.notify 这个编号开启执行。
    - 从链表 notifyList .head 上获取第一个等待者 *sudog 进行开启执行
- BroadCast() 函数调用 `runtime_notifyListNotifyAll(&c.notify)` 即通知 c.notify 后所有编号开始执行
    - 函数内部会将 c.wait 更新到 c.notify（即在 BroadCast 后获取的票据的协程将不会被开启）
    - 函数内部链表所有等待者会被开启，最后将链表清空（head、tail 都指向 nil）

部件：
- Mutex，锁，控制协程序列化；
- 两个计数
- 内置 notifyList 队列，用于排队（票据）；

> 值得分析一下这个 check 的代码（不敢保证分析的对）：
> ```go
> func (c *copyChecker) check() { // copyChecker 是 uintptr 的别名，c 是个指针
>     if uintptr(*c) != uintptr(unsafe.Pointer(c)) && // 指针 c 的值不等于 c 的地址
>         !atomic.CompareAndSwapUintptr((*uintptr)(c), 0, uintptr(unsafe.Pointer(c))) && // 原值为 0 表明此地址存储的值是 0，表明？
>         uintptr(*c) != uintptr(unsafe.Pointer(c)) { // 判断替换后 c 的值是否等于 c 的地址
>         panic("sync.Cond is copied")
>     }
> }
> ```
> `unsafe.Pointer(c)` 返回的是十六进制的地址值
> ` uintptr(unsafe.Pointer(c))` 输出的是十进制的地址值
> 感觉后两个判断条件可以合并成一个，忽然又意识到，等第二次进行判断的时候就会直接 `uintptr(*c) != uintptr(unsafe.Pointer(c))` false 短路
> 这里用法的关键点是 *uintptr 指针指向内存的数据存储的就是 *uintptr 的地址。

> *sudog 的结构
> 目前从此部分看源码可以理解到 *sudog 的以下结构信息
>```go
>type sudog struct { // 表示一个在等待状态的 goroutine 信息
>	g *g        // 真正的 goroutine
>	next *sudog // 下一节点，构成链表
>	prev *sudog // 上一个节点，构成双向链表
 >
>	acquiretime int64  // 目测是时间记录
>	releasetime int64  // 时间记录
>	ticket      uint32 // 票据，就是当前等待者的一个编号
>
>	isSelect bool 
>	success bool
>
>	parent   *sudog // semaRoot binary tree
>	waitlink *sudog // g.waiting list or semaRoot
>	waittail *sudog // semaRoot
>	c        *hchan // channel
>}
>```

### 扩展包中的 ErrGroup

包：`golang.org/x/sync/errgroup`

作用：收集并发协程的首次 err 错误。并控制在首次 err 出现时终止组内各协程。

设计思路：
- 通过 WaitGroup 部件来实现等待所有协程结束
- 通过 Once 部件来实现 err 仅收集一次（即第一个）
- 使用 Context 部件（cancelCtx）来实现控制主动结束所有协程

结构：
```go
type Group struct {
	cancel func()     // 获取 err 后终止所有协程的方法
	wg sync.WaitGroup // 无 err 时正常等待所有协程结束
	errOnce sync.Once // Once 控制 err 只获取第一个
	err     error     // err 属性
}
```

暴露的方法：
```go
func WithContext(ctx context.Context) (*Group, context.Context) // 创建方式，当用此创建时会在第一个出现 err 时就终止所有协程；否则会等待所有协程都处理完
func (g *Group) Go(f func() error) // 开启协程
func (g *Group) Wait() error // 等待
```

实现细节：
- 因为要收集 err，所以传入的函数签名是 `func() error`
- `Go()` 函数内用协程开启执行传入的 func，并当返回结果 err 非 nil 的时候，使用 Once 收集 err 信息。然后调用属性 cancel() 取消其他协程上下文调用
- `Wait()` 阻塞等待所有协程的结束，并返回 err 结果

注意问题：
- 如果不使用 `WithContext` 方法创建实例， `cancel()` 函数会是 nil，这时无法控制组内有错误就终止，就会变成所有协程都执行完后才终止，但只收集第一个 err。
- `Wait()` 中也调用了一次 cancel() 方法，感觉这个是冗余处理（暂无法确定解决什么问题）

### 扩展包中的 Semaphore

> 信号量是在并发编程中的一种同步机制，它保证持有的计数器在 0 到初始化权重之间，每次获取资源时会将信号量中计数器减去对应数值，在释放时加回来，当遇到资源不够获取时，就会发生阻塞，直到其他协程释放足够量的信号量。

包：`"golang.org/x/sync/semaphore"`

作用：排队借资源（如钱，有借有还）的一种场景。此包相当于对底层信号量的一种暴露。

设计思路：有一定数量的资源 Weight，每一个 waiter 携带一个 channel 和要借的数量 n。通过队列排队执行借贷。

结构：
```go
type Weighted struct {
    size    int64 // 总资源大小
    cur     int64 // 当前借出量
    mu      sync.Mutex // 锁控制
    waiters list.List  // 队列（链表）
}
type waiter struct { // Weighted.waiters 中的链表的元素
    n     int64
    ready chan<- struct{} // Closed when semaphore acquired.
}
```

暴露方法：
```go
func (s *Weighted) Acquire(ctx context.Context, n int64) error // 请求一定数量的资源
func (s *Weighted) TryAcquire(n int64) bool // 请求一定量的资源，不阻塞，返回请求结果
func (s *Weighted) Release(n int64) // 释放一定数量的资源
func (s *Weighted) notifyWaiters() // 通知
```

细节：
- 借出逻辑（判断数值在 Lock() 下进行）：
    - 如果当前余量足够申请，直接更新被借出量并返回
    - 如果申请量大于资源总量，那么直接阻塞本协程，但不影响其他协程排队（相当于“流氓”协程，不让其排在队列中阻塞其他协程）
    - 申请资源量是按队列一个个进行的，无论本次申请成功还是失败，都会从队列中移除
    - 队列中的第一个节点的移除操作会通知下一个节点判断请求量
```go
func (s *Weighted) Acquire(ctx context.Context, n int64) error {
    s.mu.Lock()
    if s.size-s.cur >= n && s.waiters.Len() == 0 {
        s.cur += n
        s.mu.Unlock()
        return nil
    } // 以上为直接判断可以借出资源，更新 cur 后直接返回

    if n > s.size { // 此块为特殊处理，如果申请资源本身就大于资源量，直接阻塞本协程，但不影响其他协程的阻塞
        // Don't make other Acquire calls block on one that's doomed to fail.
        s.mu.Unlock()
        <-ctx.Done()
        return ctx.Err()
    } // 所以，申请量和资源量需要开发者自己保证这个量的关系

    ready := make(chan struct{})
    w := waiter{n: n, ready: ready}
    elem := s.waiters.PushBack(w) // 加入到队尾
    s.mu.Unlock()

    select {
    case <-ctx.Done(): // 此分支下一定返回 err
        err := ctx.Err()
        s.mu.Lock()
        select {
        case <-ready: // 走到这个分支是 cpu 调度产生的，此时 ctx.Done 和 ready 是几乎同时产生的
            err = nil // 这种情况下直接认为是已经申请到资源了
        default: // 请求资源超时
            isFront := s.waiters.Front() == elem
            s.waiters.Remove(elem) 
            if isFront && s.size > s.cur { // 如果是第一个节点超时，并且有余量资源，则通知下一个等待节点
            // 为什么要判断 isFront 而不是直接全部取消呢？
            // 因为每个 Acquire 可以能是不同的 ctx

                s.notifyWaiters() // 通知下一个等待节点
            }
        }
        s.mu.Unlock()
        return err
    case <-ready: // 等待被通知获取到了资源
        return nil
    }
}
// 按顺序通知队列中的元素获取资源，可获取时记录已借出资源量，
// 并循环通知下一个节点
func (s *Weighted) notifyWaiters() {
	for {
		next := s.waiters.Front()
		if next == nil { break } // 没有等待者直接退出循环

		w := next.Value.(waiter)
		if s.size-s.cur < w.n { // 余量不够当前节点申请，会阻塞在此节点 
			break // 退出循环，即不会通知下一个节点去获取资源
		}

		s.cur += w.n // 更新已经借出的资源量
		s.waiters.Remove(next)
		close(w.ready)
	}
}
```
- 释放逻辑：释放时需要传入释放信号量个数，然后通知下一个节点 `notifyWaiters()`（注意若导致 cur<0，会造成 panic）
- TryAcquire 逻辑：只有当队列为 0 且余量够时才能获取到返回 true，否则直接返回 false

部件：
- Context，控制本资源请求者的超时控制。
- 队列，用于排队。
- 锁，控制资源计数变更
- 两个数值：资源总量 size 和已经借出量 cur
- 通知机制（按队列进行的）

细节：
- 申请量大于资源量的时候，不加入队列直接阻塞，开发者需要自己注意
- 释放量也是开发者传入的，一旦释放量导致资源总借出量 cur 小于 0，会造成 panic 

### 扩展包中的 SingleFlight

包：`"golang.org/x/sync/singleflight"`

作用：防击穿。瞬时的相同请求只调用一次，response 被所有相同请求共享。

设计思路：按请求的 key 分组（一个 *call 是一个组，用 map 映射存储组），每个组只进行一次访问，组内每个协程会获得对应结果的一个拷贝。

结构：
```go
type Group struct {
	mu sync.Mutex       // protects m
	m  map[string]*call // lazily initialized，每一个 *call 是一个组
}

type call struct {
	wg sync.WaitGroup // Group.m map 的每个元素是一个分组

	val interface{} // 调用 fn 的结果和错误信息
	err error       // 
	forgotten bool  // 标记是否在访问期间被调用了 Forget 函数（默认访问完自动 forgot）

	dups  int             // 同时访问此 call 的个数（可能在访问过程中增加计数）
	chans []chan<- Result // 每个访问通过 chan 获取结果（同样可能在访问过程中增加）
}

type Result struct { // 结果收集器，结果、错误、是否被多个协程共享结果
	Val    interface{}
	Err    error
	Shared bool
}
```
```go
func (g *Group) Do(key string, fn func() (interface{}, error)) (v interface{}, err error, shared bool) 
func (g *Group) DoChan(key string, fn func() (interface{}, error)) <-chan Result  
func (g *Group) Forget(key string) 
```

逻辑：
- `Do()` 和 `DoChan()` 都是在 Group.m 中找到对应的 *call（懒加载方式），并执行方法 fn，
    - `DoChan()` 是每个协程通过 channel 获取结果的一个拷贝；而 `Do()` 方法直接返回结果的拷贝
    - `DoChan()` 和 `Do()` 两种方法的阻塞方式不一样（但实际效果是一样的）。前者内用协程调用了 doCall() 然后用 channel 阻塞；后者是用 WaitGroup 等待首次的调用。
    - 用 `DoChan()` 的方式可以自行控制是否等待结果。
- `Forget()` 用于在 flight（调用进行中）期间删除 Group.m[key]（默认是在访问结束后自动删除），它的作用在于在 flight 期间，调用 `Forget()` 之前和之后会有两次实际的访问

细节：
- 源码中用了两个 defer 来区分 panic 退出和 runtime.Goexit 退出。区别方法（the only way）在于：recover 不会捕捉 runtime.Goexit 
- 源码从结果上来说不会用 recover 捕捉 panic，更准确地说时捕捉了一次后再次抛出了 panic（捕捉一次的原因见上一条）
- 用 defer 捕获异常后会隐藏 panic 的调用栈信息，所以为了能够在捕获后再抛出的时候有这个信息，第二次的 panic 内容被封装了调用栈信息
- 源码上为了阻止 channel 造成死锁，为了保证 panic 一定不能被 recover，它用了 `go panic()` 这种调用方法。由于 recover 只能捕获本协程内的 panic，所以这种调用方法一定不能被服务 recover 住。


部件：
- Mutex，用于控制并发下数值的更新操作
- map，控制请求分组。
- WaitGroup，用于每一个分组下阻塞等待结果

---

如有错误，请批评指正。
