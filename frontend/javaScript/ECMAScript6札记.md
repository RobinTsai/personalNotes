[markdown](http://www.jianshu.com/p/q81RER/)
[markdownTheme](http://www.tuicool.com/articles/NJrQfub)

[ECMAScript6](http://es6.ruanyifeng.com/#README)
回家后安装MarkDown Preview
markdown Toc

# ECMAScript 6

## let and const

1. let 命令

- let不再有"声明提前"

- 定义变量，作用域:仅代码块.（现在代码块有作用域了）
  ES6明确声明，如果在区块中存在let和const命令, 这个区块对这些命令声明的变量，从一开始就是封闭作用域。
  未声明而使用，会报错，不再是undefind

## 变量的解构赋值

- 按一定模式，从数组和对象中提取值，对变量进行赋值——解构

1. 数组

- 用法

```script
var [a, b, c] = [1, 2, 3];
```
只要等号两边的模式相同，即可完成赋值, 否则返回undefined

- 不完全解构

```script
let [a, [b], d] = [1, [2, 3], 4]; // a=1, b=2, d=4
```

- `...`的用法

```script
let [head, ...tail] = [1, 2, 3, 4]; // head=1, tail=[2, 3, 4]
```

```script
let [x, y, z] = new Set(["a", "b", "c"])
```

- 惰性取值

- 对象

```
var { foo: baz } = { foo: "aaa", bar: "bbb" };
baz // "aaa"

let obj = { first: 'hello', last: 'world' };
let { first: f, last: l } = obj;
f // 'hello'  //是f而不是first
l // 'world'
```

## 字符串

- 字符串遍历

```script
for (let codePoint of 'foo') {...} // 'f', 'o', 'o'
```

- at方法

```script
'abc'.charAt(0)  // 'a'
'我'.charAt(0)   // '\u****'
'abc'.at(0)      // 'a'
'我'.at(0)       // '我'
```

- includes(), startsWith(), endsWith()

三种方法都支持第二个参数， 表示开始的位置
```script
var s = 'Hello world!';
s.startsWith('Hello') // true
s.endsWith('!')       // true
s.includes('o')       // true
```

- repeat()

```script
'hello'.repeat(2); // 'hellohello'
'na'.repeat(0);    // ''
'na'.repeat(2.9);  // 'nana'
'na'.repeat(Infinity);    // RangeError
'na'.repeat(-1);          // RangeError
```

- 模板字符串

    * 使用反引号

如Jquery中使用

```script
$('#id').append(
  "There are <b>" + basket.count + "</b>"
);
```
现在用：

```script
$('#id').append(
  `There are <b>${basket.count}</b>`
);
```
大括号内{}可以放任意的JavaScrip代码

- 模板编译

    * 在模板中可以使用`<%=...%>`来输出JavaScirpt表达式

- tag函数

    * passthru函数

    * SaferHTML函数, 过滤HTML

    * i18n函数

    * jsx函数，将一个DOM字符串转为React对象

## RegExp

- RegExp()

    * ES5中只接受字符串参数`var regex = new RegExp("xyz", "i");`, ES6中接受正则式作为参数`var regex = new RegExp(/xyz/i);`
    * 新增flags属性(正则表达式对象), 返回修饰符是y还是其他或者组合

- u修饰符, Unicode字符表示法

    * `/^.$/u.test('a')` 不加u， 不能识别`\uFFFF`以上的字符，加了之后可以识别
    * `/\u{61}/u.test('a')`, 用{}表示Unicode编码, 用了{}后都需要加u

- y修饰符, '粘连'修饰符

    * 与g类似，差别仅在，匹配了第一次后从下一个字符未知开始匹配，如果词字符不是，则匹配不到
    * 注意一点：用y修饰的，第一次匹配一定是从头开始匹配的, 某一个字符不对的时候的时候就停止
    * 正则对象的sticky方法，可以返回true/false，标识是否设置了y修饰符

- 将字符串转移直接作为正则表达式: RegExp.escape()

## 数值的扩展

- 二进制和八进制

    * ES6中二进制0b或0B, 八进制0o或0O.(必须使用0o, ES5中未强制)

- Number对象的方法

    * isFinite()
    * isNaN()
    * parseInt()  转移到了Number对象上，不再是全局
    * parseFloat()
    * isInteger() 由于浮点型和整型存储方式一样，所以3和3.0都返回true
    * EPSILON 新增极小的常量
    * isSafeInteger() 是否实在(-2^53, 2^53)之间(开区间), 超过范围，无法精确表示

- Math对象扩展

    * trunc() 去除小数点
    * sign() 判断一个数到底是正数(返回+1), 负数(-1), +0(+0), -0(-0), 还是其他值(NaN).
    * cbrt() 立方根
    * clz32() 返回32位无符号整数形式有多少个前导0. (只考虑整数部分)
    * imul() 返回两个以32位带符号整数形式相乘的结果， 返回的也是一个32位带符号整数
    * fround() 返回一个数的单精度浮点数形式
    * hypot() 返回所有参数的平方和的平方根
    * 对数方法
    1. expm1()
    2. log1p()
    3. log10()
    4. log2()
    * 三角函数的方法
    1. sinh(x) 双曲正弦
    2. cosh(x) 双曲余弦
    3. tanh(x) 双曲正切
    4. asinh(x) 反双曲正弦
    5. acosh(x) 反双曲余弦
    6. atanh(x) 反双曲正切

- 指数运算符 **

    * a **= 2 // 等同于 a = a * a.

## 数组

- Array的方法
    + from() 将对象(两种)转为数组: 类数组对象和可遍历的对象
    + of() 将一组值转换为数组
    + copyWithin() 数组赋值(会覆盖)
    + find()和findIndex()
    + fill() 填充一个数组的指定几个元素
    + entries()，keys()和values() 遍历数组, 分别是对键值对、键、值
    + includes() 是否包含给定值
    + ES6明确规定将数组空位转为undefined，这将不同于空位
    + 数组推导: 允许直接通过现有数组生成新数组. 有一种使用是将for...of...放在[]中
    + observe()和unobserve() 监听和取消监听数组的变化, 用于指定回调函数

## Function

- ES6中的函数参数可以指定默认值, 用等号
    * 默认值不能传入null，应该传入defined.否则， 不会赋默认值
    * 函数的length属性，将不会有默认值的计数
    * rest参数(...), rest参数后面不能再有参数，而且不能用arguments取，可以当作数组，用for循环遍历
    * 扩展运算符(...)与数组结合，将数组转化成逗号分隔的序列
    * 扩展运算符可以将字符串转为真正的数组[..."hello"] // ['h','e','l','l','o']
    * name属性，返回函数名
    * 允许箭头=>来定义函数
        - 无参数用空括号，一个参数可以省略括号，多个参数有括号
        - this指的是定义时候的对象，而非使用时候的对象
        - 不可以使用arguments对象
        - 不可以使用yield命令
        - 不可以使用new来构造
        - 可嵌套使用，要用括号=>(=>(...))
    * 函数绑定，双冒号::

## 对象
