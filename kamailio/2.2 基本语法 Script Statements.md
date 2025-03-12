# 脚本语句

## 赋值语句

赋值语句一般用 `=` 来赋值，左侧可以是：

- `$avp(i:)` 无序列表 AVPs
- `$var(...)` 表示脚本变量
- `$shv(...)` 表示共享变量
- 特有变量如：
  - `$ru` Request URI
  - `$rd` Domain of Request URI
  - ...

## 字符串拼接

使用 `+` 号

## 算术运算

`+, -, *, /, %, |, &, ^ (XOR), ~ (bit NOT), << (bit left shift), >> (bit right shift)`

## 操作符

- 类型转换 `int(...), str(...)`
- 字符串比较 `eq, ne`
- 整型比较 `ieq, ine`
- 是否定义 `defined expr`，判断 expr 是否定义（仅 standalone avp or pvar 可以未定义，其他的都是定义了的）
- 获取长度 `strlen(expr)` 评估 expr 为 str 类型，返回长度
- 判断为空串 `strempty(expr)` 评估 expr 为 str 类型，返回是否为空
- 特殊的值 `undef`
- 弱类型比较 `==, !=`
- 强类型比较 `eq, ne, ieq, ine`（前两者用于字符串比较——评估为字符串类型，后者用于整数比较——评估为整数类型）
  - `0 eq ""` 等价于 `"0" eq ""` 等于 false，但 `0 == ""` 为 true
  - `"a" ieq "b"` 等价于 `(int)"a" ieq (int)"b"` 等价于 `0 ieq 0` 等于 true，但 `"a" == "b"` 为 false
- **逻辑操作符** 有 `==, !=, >, <, >=, <=, &&, ||, !`，另外还有
  - `=~`: 大小写不敏感的正则匹配
  - `!~`: 大小写不敏感的正则不匹配
  - `[ ... ]`: 测试操作符，内部可以是任何算术表达式

> 注意，这些名字不是最终的，未来版本可能会变化。

## if-else

> 逻辑表达式参考上方逻辑操作符

```lua
if (logical_expression) {
    actions;
} else {
    actions;
}
```

## switch-case-break

```c
switch(expression)
{
    case -1:
        actions;
        break;
    case 1:
        part_actions;
    case 2:
        actions;
        break;
    default:
        actions;
}
```

> 注意，return 会终止脚本

## while

```c
while (logical_expression) {
    actions;
}
```
