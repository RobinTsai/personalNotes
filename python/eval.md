# eval

eval 函数可以执行一个字符串作为表达式，并返回表达式的值。

它的上下文变量是通过 globals 和 locals 参数传入的。

globals 必须是个字典对象；locals 可以是任何映射对象。（TODO：这里说的映射和字典有什么区别？）

```python
eval(expression[, globals[, locals]])
```

## 一个线程控制另一个线程执行代码

试着执行并阅读以下示例：

```py
import time, threading


GLOBAL_DICT = {}
CMD = ""
DONE_CMD = "DONE"
def wait_cmd():
    global CMD, GLOBAL_DICT, DONE_CMD

    print("start waiting cmd...")
    while True:
        time.sleep(0.01)
        if CMD != "":
            print(f"got cmd {CMD}")
            if CMD == DONE_CMD:
                break
            eval(CMD, GLOBAL_DICT)
            CMD = ""
    print("done cmd loop")

def run_in_another_thread():
    wait_cmd()


def main_thread():
    another_thread = threading.Thread(target=run_in_another_thread)
    another_thread.start()
    time.sleep(1)

    GLOBAL_DICT["a"] = 3
    GLOBAL_DICT["b"] = 2
    GLOBAL_DICT["time"] = time
    global CMD
    CMD = "print(a * b)"
    CMD = "print(time.time())"

    time.sleep(1)
    CMD = DONE_CMD

main_thread()

# start waiting cmd...
# got cmd print(time.time())
# 1672396809.619307
# got cmd DONE
# done cmd loop
```

你看明白了吗？

调用 eval 的时候，用 `GLOBAL_DICT` 提供了上下文的变量信息，注意导入的包也设置成了一个变量对象。
