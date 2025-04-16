# Google style guide

> 整理来源于 [Google Go Style](https://gocn.github.io/styleguide/)，只整理重要的。
> （延申：这是用 [Hugo](https://gohugo.io/) 发布的文档网站）


## map

- 总是使用 make 进行初始化：写一个没有初始化的 map 会产生 panic
- 注意并发操作：多协程读写同一个 map 要加锁，或用 sync.Map
- 注意精度问题：精度有限
- 用作 key 的类型——可比较的类型都可以用作 key：
  - 可用：基本类型、指针、结构体、chan、接口、数组（特殊说明：数组和结构体中元素必须都是由可比较的元素组成）
  - 不可用：切片、map、func
- 用作 value：所有类型都可以用作 value

```go
// panic: assignment to entry in nil map
var m map[string]string
m["a"] = "A"
```

## 可比较的类型

- 结构体：hash 后相等且字面值相等为相等
  - 同类型的结构体有相同的 hash（固定在底层字段上）
  - 字面值：各属性值都可比较且相等（字段指针不同不相等，包含不可比较的属性无法比较）
- float：在按精度截取后相等则相等——底层转为 uint64
- NaN：永不相等——hash 函数会加入随机数
- func 类型只可与 nil 进行比较

`reflect.DeepEqual` 可以判断：

- 数组值：对应元素深度及值都相等
- 结构体：对应字段——包含导出的和未导出的——都相等时，相等
- 函数：两个函数都是 nil 时，相等
- 接口：...
- ...

## 结构体

- 定义相同的结构体可以相互转换（强制转换）

## 类型判断一定要有第二个参数

原因解释：不加第二个参数且判断失败时，会发生 panic。如果输入来源于外界，

```go
// GOOD
s, ok := k.(string)
// BAD
s := k.(string)
```

## 减少冗余信息

参考作用域（Scope）进行命名，不冗余

- 包下导出变量或函数，不要再带有包名
- Receiver 的函数名不要再带有 Receiver 名

## channel 的使用

panic 的三种情况（都与关闭有关）：

- 写已关闭
- 重复关闭
- 关闭 nil

特殊的阻塞操作：

- 读/写 nil 的 channel

关闭的技巧：

- 在写的地方关闭（只一处写的场景适用）
- 使用 sync.Once 等保证只关闭一次
- 使用 defer-recover 兜底
- 利用其他 chan 退出协程，不关闭让 GC 回收

## error

- error 是个接口

## interface

- 利用编译器确保实现了接口
- 尽量用指针的 Receiver 实现接口：

```go
// GOOD: 确保 RecordUploadMinio 实现了 RecordUploader 接口
var _ RecordUploader = &RecordUploadMinio{}
```
