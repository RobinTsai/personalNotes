+ 可以在百度百科上找到目录，方便查阅

+ 不用var来声明变量，就是声明了一个全局变量。
    + 但这和在全局位置声明的有些不一样: delete操作
    + 用var在全局位置声明的变量不可以使用delete操作: false
    + 不加var声明的变量可以用delete操作: true
    + 见例子：deleteGlobalVar.js

+ 对象的使用可以用‘.’，也可以用‘[]’, 但
    + 包含空格、标点、保留字或者是个数字时，必须用方括号
    + 通过运算而得出的值，必须用方括号
    + 4.4

+ javascript中，5/2 == 2.5, 2.5%0.2约等于0.1(0.09999999999999987)

+ true+true == 2, 1+true == 2, 1+undefined=NaN, '+'把undefined转换成了NaN

+ 位运算符
    + 只能操作整数,并且是32位的.
    + 位运算符会把NaN、Infinity和-Infinity转换成0

+ 一个对象永远不等于另一个对象（‘另一个’表示不是同一个引用），一个数组永远不等于另一个数组，即便他们内部完全相等.

+ ??? P75,说:"如果两个值都是null或者都是undefined,那么他们不相等"(===),但事实是他们相等

+ x!=x 为true的，只有NaN

+ 0 === -0 是true

+ 字符串的比较类型不同不会转换，所以即便表面相同，不同编码，可能不相等(===)

+ null == undefined是true, null === undefined是false, false == 0是true

+ in运算符, 左侧是一个字符串类型的， 右侧是一个对象类型的，如果左侧的字串是右侧对象的其中的一个键（注意：不是值），那么才返回true

+ instanceof 是判断左侧是否是右侧的一个实例的运算符

+ eval()的作用就是把字符串当作一个javascript来处理(编译).编译不代表执行，所以eval(return;)说不通.

+ 用delete a[2]来删除a = ['a', 'b', 'c'],可以删除c，但a[2]并没有删除，它给数组留了一个‘洞’.而且length不变.

+ switch中的case是按===来的

+ with 可以更改作用域链(with ×××，用新的×××作为当前作用域)
    + use strict 模式下是禁用with的
    + with(document.forms[0]) {...} 等价于 var f = document.forms[0];

+ delete只是断开联系，而不是真正的删除。比如:
    + a = {b: {c: 1}}; d = a.b; delete a.b; d.c依然是1

+ in, hasOwnProperty, propertyIsEnumerable.
    + in 前者是后者中的属性名,可以来自于继承, o.x !== undefined 约等于它,(特殊情况是一个undefined的值)
    + hasOwnProperty 判断是否不是来自于继承, o.hasOwnProperty("x")
    + propertyIsEnumerable 判断是自有属性，并且这个属性是可枚举型的=>true

+ Object.keys(x); 可返回对象x中的所有自有属性的名称（键名）, 但仅仅是可枚举的属性
    + Object.getOwnPropertyNames(x); 和keys()类似，但不仅仅是可枚举的属性

+ 到P144, 6.6了
