# 基础

- [lua 官方文档](https://www.lua.org/pil/contents.html)

## 交互式编程

```sh
lua -i
```

## 脚本式编程

在 sh 中用 lua 工具执行

```sh
lua hello.lua
```

在 lua 脚本中指定编译器，在 shell 中直接 `./hello.lua` 执行

```lua
#!/usr/bin/lua

print("hello world")
```

## 基础语法

- 单行注释：`-- xxx`
- 多行注释：`-- [[ ` ... 多行文本 ... `-- ]]`
- 区分大小写
- 数据类型用 `type()` 查询，有以下这几种
    - `nil`, `boolean`, `number`, `string`, `function`, `userdata`, `thread`, `table`
- 全局变量：默认下变量总是全局的，访问未初始化的全局变量不会出错，结果是 nil
- 局部变量：local 用于声明局部变量，局部变量访问速度比全局变量快
- 变量赋值：
    - 可以多个赋值 `a, b = 1, 3`，常用来交换变量或接收函数的多个返回值
    - 赋值两边个数不一致时候，左边多的赋值为 nil，右边多的忽略
- nil 比较应该用引号：`print(type(nonexist) == "nil") -- ture`，`print(type(nonexist) == nil) -- false`
- 变量类型
    - boolean 类型：false 和 nil 是 false；其余值都是 true，0 也是 true
    - number 类型：`2`, `2.2`, `2e+1`, `0.2e-1`, `7.8888e-06`
    - 字符串类型：
        - 单引号双引号皆可
        - 多行的字符串用 `[[ ]]`：`html = [[ ...多行... ]]`，里面可以带引号
        - 在字符串数值上做运算操作，lua 会转换成数值做运算，转换失败会报错
        - 字符串拼接用 `..`：`print("abc" .. "def")`
        - 获取长度：
            - 使用 `#"字符串内容"` 或 `#变量名`（也可以得到 table 的长度）
            - 使用 `string.len()` 获取 ASCII 长度
            - 使用 `utf8.len()` 获取中文的长度
        - 内置方法：
            - 大小写转换： `string.upper(arg)` / `string.lower(arg)`
            - 子字符串替换： `newStr, count = string.gsub(str, match_sub_str, new_sub_str[, N])`，N 为最大替换次数
            - 子字符串查询： `string.find(str, sub_str, [startIdx[, plain]])`
                - 返回子串的起始索引和结束索引，不存在返回 nil
                - plain 是表示是否使用简单模式，false 时是正则模式
                - 正则支持的模式参考 https://www.runoob.com/lua/lua-strings.html
            - 字符串反转： `string.reverse(str)`
            - 字符串格式化输出： `string.format("the value is: %d", 4)`
                - 转义码参考 https://www.runoob.com/lua/lua-strings.html
            - ASCII 数值转为字符（可变参数）：`string.char(97, 98, 99, 100) -- abcd`
            - 字符串内某字符转换为  ASCII 数值： `string.byte("abcd", 3) -- 99`
            - repeat： `string.rep(str, N)`
            - 返回一个匹配的迭代函数： `string.gmatch(str, pattern)`
            - 正则匹配：`string.match(str, pattern[, startIdx])`，pattern 表示正则
                - 正则中没有捕获时，返回匹配的子串
                - 正则中有捕获时，按顺序返回所有捕获结果
                - 没有匹配返回 nil
            - 字符串截取：`string.sub(str, startIdx, [endIdx])`, endIdx 省略时默认为 -1 表示截取到最后
    - table 是关联数组（关联数组包含数组和字典），索引从 1 开始
        - `a={"abc", "def"}`
        - `a["key"] = "value"`
        - `a.key = "value"`，用点号也可以访问索引
        - 内置方法：
            - 拼接： `table.concat(table, [sep, [start, [end]]])` 按分隔符 sep 拼接 table 内从 start 到 end 的所有元素
            - 插入： `table.insert(table, [pos], value)`
            - 返回最大 key（<=lua5.2）： `table.maxn(table)`，不存在返回 0
            - 删除： `table.remove(table, [pos])`
            - 排序（默认升序）： `table.sort(table, [comp])`
    - table 总是引用传递的，输出值要用循环输出
    - function 是“第一类值”（First-Class Value），函数名为句柄，可以赋值给变量，可以作为参数传递
    - thread （线程），lua 中最主要的线程数协程（coroutine），
    - userdata（自定义类型）用于表示由应用程序或 C/C++ 库所创建的类型（通话是 struct 和指针）
- 流程控制：`if`
- 循环：`while`, `for`, `repeat ... until`
- 循环控制：`break`, `goto`

```lua
if(cond) then -- nil 和 false 为 false，其他都是 true
    statements
elseif(cond) then
    statements
else
    statements
end
--- 分割线 ---
while(cond) do
    statements
end
--- 分割线 ---
for variable=exp1, exp2, exp3 do -- 从 exp1 到 exp2，步长为 exp3；exp3 可省略，默认 1；可为负值
    statements
end
--- 分割线 ---
for i=1, f(x) do statements end -- 可以用 f() 的返回值做参数，可以写成一行

for k,v in ipairs(a) do print(k,v) end -- 泛型 for 循环，ipairs() 迭代器函数
--- 分割线 ---
repeat  -- 先执行，再判断条件
    statements
until(cond)
```

- 函数
  - 函数定义可以用 local 修饰，表示局部函数
  - 返回值直接返回函数列表即可
  - 可变参数用 `...`（三个点）表示；`{...}` 表示可变参数构成的数组；用 `select("#",...)` 来获取可变参数的数量；`select("n", ...)` 来获取从起点 n 到末尾的所有参数列表
- 运算符
  - 算数运算符：加减乘除，`%` 取余，`^` 乘幂，`//` 整除（>=lua5.3）
  - 关系运算符：`==` 等于, `~=` 不等于，其他略
  - 逻辑运算符：`and`, `or`, `not`

### string 库

#### 正则匹配函数

lua 的正则匹配没有使用 POSIX 的实现，原因是代码量太大。

有一下三种方式：

- `beginIdx, endIdx = string.find(str, patternStr[, fromIdx])` （lua 中 idx 从 1 开始）
- `string.gfind()` 是自带循环的 `string.find`
- `subStr = string.sub(str, startIdx, endIdx)`
- `resultStr, count = string.gsub(str, patternStr, replacementStr[, limitCount])` Global Suubstitution
- `string.gfind` Global Find

#### 正则



## 高级语法

### 模块和包

- lua 5.1 及之后加入了标准模块管理机制
- 模块是由变量、函数等组成的大 table
- 创建模块，就是创建一个大 table，然后将函数、变量等挂在 table 中，最后返回大 table
- require 函数用来加载模块： `require("mod_name")` 或 `require "mod_name"`
    - 它会返回这个 table，可以用变量接收并进行使用 `local m = require("mod_name")`
    - 它还会定义一个此 table 一样名称的全局变量，可直接使用 `require("mod_name")`, `mod_name.xxx`
    - require 尝试先搜索 `LUA_PATH` 中定义的 package.path，若无，则使用编译时定义的默认路径来初始化
- `export LUA_PATH="~/lua/?.lua;/usr/local/share/lua/5.1/?.lua;;"`
    - ? 代表匹配模式，等同于其他地方常用的 *
    - 最后两个 `;;` 表示 新家的路径后面加上原来的默认路径

C 包

- lua 和 C 很容易结合，可以用 C 为 lua 写包
- `local f = lualib(path, "func_name")` 函数加载指定 path 的包，并设置初始化函数，但他并不执行初始化；当使用 f() 的时候才会初始化

### metatable 元表

- lua 提供元表用来改变 table 的行为，如定义两个 table 进行操作（如相加）
- `setmetatable(table, metatable)` 对指定的 table 设置元表 metatable，元表会相当于作为 table 底层的一个属性（若 metatable 中存在 __metatable 键值，会返回失败）
- `getmetatable(table)` 返回对象中的元表
- 内置方法（元方法）：
    - `__index` 键，可以赋值为一个 table，也可以是一个函数 `t1 = setmetatable({}, { __index = { foo = 3 } })` 或 `t2 = setmetatable({}, { __index = func(mytable, key) ... })`
        - 为 table 时，在获取指定键的时候，若找不到会延伸到 `__index` 对应 table 下的此键获取值 `t1.foo == 3 -- true`
        - 为函数时，传入函数接收两个参数，第一个为 table，第二个是对应 key，可以自定义一些处理方式
    - `__newindex` 键，在对 table 赋值时，若 table 无此属性，会设置到 metatable.__newindex 指定到 table 上
    - `__add` 键，可以指定 `+` 的行为；后面传入函数的签名为 `function(mytable, newtable) -- return table`
    - `__sub` `-`
    - `__mul` `*`
    - `__div` `/`
    - `__mod` `%`
    - `__unm` `-`
    - `__concat` `..`
    - `__eq` `==`
    - `__lt` `<`
    - `__le` `<=`
    - `__call` 键，在将 table 作为函数调用（`table()`）时执行此属性定义的函数
    - `__tostring` 键，传入函数 `function(table)` 修改表打印输出的行为

### 协程 coroutinee

- 协程：有独立的堆栈，独立的局部变量，独立的指令指针，同时又与其它协同程序共享全局变量和其它大部分东西。
- 一个线程中有多个协程，但同一时刻只有一个协程在执行
- 函数的主逻辑也是一个协程
- 由 `coroutine` 模块提供支持
- 内置函数
    - `local co = coroutine.create(func_name)`，创建一个协程，参数是一个函数，当 resume() 时唤醒此函数调用
    - `local status, result = coroutine.resume(co, [value ...])`，重启协程，和 create 配合使用，value 为传入值
    - `coroutine.yield()`，挂起协程
    - `coroutine.status(co)`，查看协程的状态，三种（也是返回值）：`dead`，`suspended`，`running`
    - `local co = coroutine.wrap( func() ... )`，将函数封装成一个协程，一旦调用 `co`，就用协程执行这个函数
    - `coroutine.running()`，在协程内的函数中使用，返回正在跑的协程，一个 coroutine 就是一个线程，返回线程号
- lua 协程可以完成 生产者-消费者 模型

### 文件 I/O
