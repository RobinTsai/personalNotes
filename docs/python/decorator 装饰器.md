# decorator 装饰器

- [基本使用](#基本使用)
- [被装饰函数的运行时名字](#被装饰函数的运行时名字)
- [参数的传递](#参数的传递)
  - [带参数的装饰器](#带参数的装饰器)
  - [带参数的被装饰函数](#带参数的被装饰函数)
- [源码解析 functools.wraps 的实现原理](#源码解析-functoolswraps-的实现原理)


装饰器是将 `被装饰函数` 放入 `装饰函数`，在执行的时候变为在 `装饰函数` 内部执行 `被装饰函数`。

## 基本使用

- 被装饰函数上一行使用 `@装饰器名` 使用装饰器装饰此函数；
- 装饰器函数 **第一个参数** 传入的是 **被装饰函数** 的句柄；
- 装饰器函数内部要定义一个包裹的函数，并在包裹函数内执行被装饰函数；
- 装饰器函数要返回包裹函数的句柄；
- 上步很重要。

注意点：

- python 解释器在执行到 `@装饰器` 时会 *执行装饰器，用返回的函数句柄替换当前函数句柄*。（见错误的使用方式一）

正确示例：

```python
def decorator(func): # 装饰器函数
    def wrap(): # 装饰器内要定义一个函数，装饰函数
        print(f"entering {func.__name__}")
        func()
        print(f"leaving {func.__name__}")
    return wrap # 注意返回函数名，不加括号

@decorator
def worker_a():
    print(f"do some works")

worker_a()
print(worker_a.__name__) # 输出被装饰函数的在运行时的名字

# entering worker_a
# do some works
# leaving worker_a
# wrap
```

> 注：**为了解释准确，下文中将 decorator 的定义称为 *装饰器函数*；将 wrap 的定义称为 *装饰函数*；将 func 的定义称为 *被装饰函数*。**

错误的定义和使用方式一

```python
# 解释器解释到装饰器时，会执行装饰器
# 并用装饰器返回的函数句柄替换原函数句柄
def decorator(func):
    print(f"entering {func.__name__}")
    func()
    print(f"leaving {func.__name__}")

@decorator
def worker_a():
    print(f"do some works")

# entering worker_a
# do some works
# leaving worker_a
```

## 被装饰函数的运行时名字

如上方正确示例，在最后输出被装饰函数的名字时，我们发现它被替换了。这在某些场景下不是我们想要的。

有两种方式
- 一种是在装饰器函数内执行 `wrap.__name__ = func.__name__` 替换装饰器函数句柄的名称为被装饰函数名
- 另一种是使用内置包 `functools` 下的 `wraps` 装饰器装饰被装饰函数句柄 `@functools.wraps(func)`

> `@wraps`装饰器加入了复制函数名称、注释文档、参数列表等功能

## 参数的传递

这里说的参数有两种不同的位置：

- 一种是 [带参数的装饰器](#带参数的装饰器)，即装饰器传入参数
- 另一种是 [带参数的被装饰函数](#带参数的被装饰函数)，即被装饰函数传入参数

### 带参数的装饰器

一个装饰器函数，它只有一个参数，就是被装饰的函数句柄。

但是，要知道，装饰器的实现是返回了一个 *装饰函数* 包裹了 *被装饰函数* 的使用，并替换了 *被装饰函数* 的函数句柄。而我们使用装饰器的时候（`@decorator`）是不带括号的，即相当于 `@装饰器函数句柄`。

因此，当我们要用带参数的装饰器函数时，需要这样用 `@decorator()`，而它，相当于执行 `decorator()` 函数的结果做装饰器函数。

由上，我们可以实现一个返回 *装饰器函数* 的函数，让它带参数即可，然后使用这样的语句 `@decorator(args...)`。

```python
# 让 decorator_wrapper 返回一个装饰器的句柄
# decorator_wrapper 可以自定义传入参数
def decorator_wrapper(name_with_wrap_name=False):
    def decorator(func):
        if name_with_wrap_name:
            func.__name__ = f"wrap({func.__name__})"
        else:
            func.__name__ = func.__name__

        def wrap():
            print(f"entering {func.__name__}")
            func()
            print(f"leaving {func.__name__}")

        return wrap
    return decorator

# 使用装饰器的时候要带括号，即用装饰器返回的函数做装饰器
@decorator_wrapper(name_with_wrap_name=True)
def worker_a(work_name="abc"):
    print(f"do work with name: {work_name}")

worker_a()

# entering wrap(worker_a)
# do work with name: abc
# leaving wrap(worker_a)
```

### 带参数的被装饰函数

被装饰函数带参数，要保持原样的参数列表，只需在 *装饰函数* 和 *被装饰函数* 中传入参数列表即可。

当然或者也可以使用 `@functools.wraps(func)` 装饰器，它也做到了。

> 如果理解了 “用返回的函数句柄替换当前函数句柄” 这条规则的话，这个使用方式就会很好理解。

```python
def decorator(func):
    def wrap(*args, **kwargs):
        print(f"entering {func.__name__}")
        func(*args, **kwargs)
        print(f"leaving {func.__name__}")
    return wrap

@decorator
def worker_a(work_name="abc"):
    print(f"do work with name: {work_name}")

worker_a()

# entering worker_a
# do work with name: abc
# leaving worker_a
```

## 源码解析 functools.wraps 的实现原理

如上文可见， `functools.wraps` 做了很多方便使用的事情，了解它的实现将有助于我们深入理解 python 的运行和使用。

TODO。

- python 中冒号 `:` 后面跟 *建议* 传入变量的类型，强类型可提高解释速度。
- python 中箭头 `->` 后面跟 *建议* 返回的类型
- python 中三个点 `...` 是个单例对象，相当于 `pass`。（可以试试在 python 交互命令行中用 `type(...)`、`id(...)`、`... == ...` 观察下结果）
