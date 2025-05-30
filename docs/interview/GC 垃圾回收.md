# GC 垃圾回收

## Java VS C/C++

- Java 有 GC 自动处理垃圾，所以开发效率高，但执行效率低
- C++ 需要手工处理垃圾，但这样造成开发上的不便，忘记回收就会造成内存泄漏，回收多次会造成非法访问，因此开发效率差，但执行效率高

## 如何找到垃圾

一般有两种算法：

- **引用记数法**（Reference Count，RC）
- **根可达算法**（Root Searching，RS）

> Python 用的引用计数

- 引用记数法：一个变量会被计数引用了多少次，这就是引用记数法。但它不能解决循环引用的问题。
- 根可达算法：从根对象开始搜索。

**根对象**，总得来说，在程序运行的时候马上用到的对象，就是根对象：

- **线程栈变量**。一个 main 函数运行起来就会起一个线程，线程中会有线程栈，线程栈中会有栈针，从栈针开始的对象，就是根对象。
- **静态变量**。Class Load 时马上就初始化静态变量，所以它也是根对象。
- **常量池**。就是一些字面量，程序会有一块内存空间存储这些字面量。
- **JNI 指针**（Java Native Interface）。native 是与C++联合开发的时候用的关键字，指明这个方法是原生函数，也就是这个方法是用C/C++语言实现的，并且被编译成了DLL，由java去调用的。它也是概对象。

![根可达算法](https://upload-images.jianshu.io/upload_images/3491218-e7f5a311a3bb4704.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/480)


## 如何清理垃圾

三种方法：

- Mark-Sweep（标记清除）。
- Copying（拷贝）。Copy 到另一块空间，两块空间互相转换，移动后清理另一块，所以清理很快。
- Mark-Compact（标记压缩）。一边寻找还要一边压缩，所以效率差些。

![GC 过程及方法](/assets/interview_gc.png)

## 分代模型

 ![分代模型](/assets/interview_gc_generation.png)

![image.png](/assets/interview_gc_obj_lifecycle.png)

> G1 及之前都是分代模型（参考下面的常见的垃圾回收器）
> G1 是逻辑分代，物理不分代
> G1 之前都是逻辑分代物理也分代

### 专业名词

- 新生代的 GC 叫：MinorGC 或 YGC（Young GC），是在年轻代空间耗尽时触发
- 老年代/整个的 GC 叫：MajorGC 或 FullGC，是在老年代空间耗尽时同时触发 FullGC 和 YGC

## 变量的分配

- **栈上分配**。比如一些线程私有的小对象、代码块内的对象等。（**无需调整**）
- **线程本地分配**（TLAB，Thread Local Allocation Buffer）。占用 Eden （伊甸区），默认 1%。（**无需调整**）
- **老年代**。大对象。

> TLAB 是这样的，如果无 TLAB 那每一个线程都需要在 Eden 区分配一部分空间，会发生争抢，所以规定每个线程在 Eden 区占有 1% 的自有空间，当占满了后再去占有其他空间。提高了效率。

### 何时进入老年代

- **按年龄**：年龄可以设置，Java 中对象头标记 GC 代数的是 4 位，所以最大设置为 15 次就进入老年代。
- **动态年龄**：从 S1 拷贝到 S2 时超过 S2 的 50%，就将年龄最大的放入老年代（此时不管年龄是多大，将最大的移动）。

### 总结一下

- 变量先进栈，栈上处理最快，用完 pop 掉。
- 大变量直接进入老年区。老年区触发 FullGC 才会清除。
- 变量不大的话进入伊甸区。伊甸区进行 YGC 可能清除。
- 伊甸区的多次未清除的话（达到年龄）进入老年区。进行 FullGC 清除。

> 还有一种情况是 **分配担保**，是指在 YGC 期间，survivor 区空间不够用了，一些变量直接进入老年代。

![变量生命周期](/assets/interview_gc_obj_life2.png)

## 常见的垃圾回收器

![image.png](/assets/interview_gc_methods.png)

> 术语：
> - STW，Stop-The-World，是指在垃圾回收时，让所有的线程停止运行。
> - Safe Point，是指线程停止的那个安全点。比如在上锁期间，就不是一个安全点，它会等到到安全点时停止线程。

上图解释
- 左侧分上下的，上方是 YGC 的几种方式，下方是老年代 GC 的几种方式。
- Serial 是指单线程去清理垃圾
- Par... 是指多线程并发去清理垃圾
- PS + PO 是 JVM 中的默认组合
- 目前还没有不 STW 的垃圾回收器

> scavenge：清除污物，打扫。

### CMS 并发标记清除

CMS（Concurrent Mark Sweep） 是里程碑式的，因为在这之前清理垃圾时都是需要 STW 的，从这里开始，可以在清理工作时不进行 STW。

CMS 的流程有四步：
- 初始标记。花的时间很短，很快。
- 并发标记。这个阶段是最花时间的（其他 GC 中亦然），CMS 实现了并发标记。
- 重新标记。花的时间也很短，因为大部分都标记了。
- 并发清理。这个时间产生的垃圾叫 **浮动垃圾**，会进入下一轮清理。

> 可以套一下上面 **根可达算法** 的图例，就清楚流程了。

![CMS](/assets/interview_gc_procedure.png)

> 图中一根黄线表示单线程，多根黄线表示多线程并发。

CMS 几乎未被广泛使用，虽然它是里程碑式的，但它的原因很大。
优：有并发标记的过程，所以不妨碍主程序的运行。
劣：
- 是 Mark-Sweep 模型，所以会有很多 **碎片**。内存很大时就无法清理了。

> 碎片很多会报 “Concurrent Mode Failure” 或 “PromotionFailed” 的错误。

> 问，一个网站，服务器 32 位，1.5G 的堆，用户反馈网站缓慢，公司决定升级，新服务器是 64 位，16G 内存，结果用户反馈十分卡顿，反不如初。为何？
> 答：因为内存变大了，大成天安门广场，GC 清理不过来了。

---

课后话：
- Serial 支持几十兆的内存
- PS 在上百兆
- CMS 在 20G
- G1 在上百G
- ZGC 在 4T

 G1、 ZGC 他们的区别主要在 **并发标记**（Concurrent Mark）阶段的算法不同
- CMS 用的三色标记 + Incremental Update
- G1 用的三色标记 + SATB（Snapshot At The Beginning）
- ZGC 用的颜色指针（Corlored Pointers）

三色标记：黑、灰、白，白色回收。

---

附：[参考 mashibing github 库文件](https://github.com/bjmashibing/JVM/blob/master/05_GC%20and%20Tuning.md)
