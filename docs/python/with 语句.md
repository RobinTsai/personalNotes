# with 特性

[refer](https://geek-docs.com/python/python-examples/python-context-manager-and-with-statements.html)

with 块可以自动实现上下文管理。

它的原理很简单，即在进入 `with` 块的时候调用类的 `__enter__(self)` 方法，在退出块时调用 `__exit__(self, exc_type, exc_val, exc_tb)` 方法。

`with` 之后跟一个对象，并不一定是一个函数，是对象就会执行此对象的 `__enter__`/`__exit__` 方法。

`with ... as ...` 块会将 `__enter__(self)` 的返回结果将作为 `as` 后的变量.

因此可以根据此方法自定义实现类的 with 功能。

## 使用标准库

标准库中 `contextlib` 模块提供了基础的上下文管理器功能。

```python
from contextlib import contextmanager

@contextmanager
def manage_something():
    try:
        f = open(name, 'w)
        yield f
    finally:
        f.close()
```

```sh
>>> with managed_file('hello.txt') as f:
...     f.write('hello, world!')
...     f.write('bye now')
```

## 小技巧

- 可以同时有多个上下文：

```python
with open('a.txt', 'r') as a, open('b.txt', 'r') as b:
    print(a.read())
    print(b.read())
```

- 可以多次 with 某一个对象：

```python
class Indenter:
    def __init__(self):
        self.level = 0

    def __enter__(self):
        self.level += 1
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.level -= 1

    def print(self, text):
        print('   ' * self.level + text)

with Indenter() as indent:
    indent.print('hi!')
    with indent:
        indent.print('hello')
        with indent:
            indent.print('bonjour')
    indent.print('hey')
```
