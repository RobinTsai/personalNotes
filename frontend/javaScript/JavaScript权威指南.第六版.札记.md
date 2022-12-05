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

+ 存取器：get/set方法可以定义单向流动方向的数据和方法. get r(){...}用在定义r()方法只读

+ Object.getOwnPropertyDescriptor(a, 'x');是获取<strong>自有</strong>a变量x属性的描述(要想获得继承属性的描述，需要遍历原型链getPrototypeOf())
    返回类型有,一般变量：{value: *, writable: *, enumerable: *, configurable: *}
    而存取器的描述：{get/set: *, writable: *, enumerable: *, configurable: *}
    value/get/set性，可写性，可枚举性，可配置性
+ 可以定义或修改属性的特性：Object.defineProperty(a, 'x', {value: 1, writable: true, enumerable: false, configurable: true}); 此属性存在但不可枚举：a.x==1;Object.keys(a)是[]空

+ 数组的语法允许最后一个元素有逗号，所以当最后一个元素是空时,[,,,]表示有三个元素，而非四个

+ var a = new Array(10); 10有或没有，表示数组的长度, 但这长度还是可以增加的。但参数过多，就不是数组个数了，而是数组的值

+ var data=[1,2,3,4,5];data.forEach(function(x){});forEach方法，data是一个数组,x是数组中的每个元素

+ Array中的方法
    + join() 连接成字符串，可以加一个分隔符，默认为逗号, split()是将字符串分隔为数组
    + reverse() 将数组元素颠倒顺序
    + sort() 排序,可以传入一个函数，函数有两个参数，按返回0,>0,<0进行排序
    + concat() 数组连接成数组，但不会连接嵌套的数组
    + slice(start, end) 切分为字数组[start, end), 不会修改调用的数组
    + splice(start, end, ...) 替换元素(插入、替换、删除)
    + push(),pop() 栈操作
    + unshift(),shift() 和栈类似，但前后倒置
    + toString() 数组变成字符串，字符元素的引号不会留，嵌套数组的数组中括号不会留
    + ECMAScript5中的方法，大多第一个参数是个函数(传递参数为数组每个元素)，第二个是可选参数
    + data.forEach(function(v, i ,a){a[i] = v + 1});注意v,a,i三个参数:值，键，名
    + 调用一个.break能终止forEach(用法特殊，见P157)
    + [1,2,3].map(function(x){});map将数组的每个元素传入到函数中，并一个值一个值地计算
    + filter() 筛选，传入一个函数
    + every()和some() 传入函数或参数,返回true或false
    + reduce() 折叠或组合，第一个传入函数，第二个参数是给函数的初始值
    + indexOf(),lastIndexOf() 正向和反向搜索,不接受函数,第一个参数为要搜索的值，第二个可选是start

+ 字符串类似于数组，它可以用数组形式访问某一个字符a[1]，等效于a.charAt(1).不过注意：字符串是不可以修改的

+ arguments是实参对象,它有两个方法callee, caller.参见callee.js
    + callee指代当前正在执行的函数
    + caller指代调用 ’当前正在执行的函数‘ 的函数

+ 函数也可以带属性, 把某一个值存入函数的属性中，有时可以省去全局变量. (也可以当作数组) 见funAttr

+ 在函数中定义函数就是闭包
