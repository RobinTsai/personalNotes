# os.fork 用法

## 用例

```py
import os
import time

print(f"{os.getpid()}: I'm the main process.")
for i in range(2):
    print(f"{os.getpid()}: I'm about to be a dad!")
    time.sleep(2)
    pid = os.fork()
    if pid == 0:
        print(f"{os.getpid()}: I got pid 0 from os.fork result, it means I'm the newborn.")
    else:
        print(f"{os.getpid()}: I got pid {pid} from os.fork result, it means pid {pid} is my son.")
        os.waitpid(pid, 0)

print(f"{os.getpid()}: I'm out of for range now.")

# 29362: I'm the main process.
# 29362: I'm about to be a dad!
# 29362: I got pid 29363 from os.fork result, it means pid 29363 is my son.
# 29363: I got pid 0 from os.fork result, it means I'm the newborn.
# 29363: I'm about to be a dad!
# 29363: I got pid 29364 from os.fork result, it means pid 29364 is my son.
# 29364: I got pid 0 from os.fork result, it means I'm the newborn.
# 29364: I'm out of for range now.
# 29363: I'm out of for range now.
# 29362: I'm about to be a dad!
# 29362: I got pid 29365 from os.fork result, it means pid 29365 is my son.
# 29365: I got pid 0 from os.fork result, it means I'm the newborn.
# 29365: I'm out of for range now.
# 29362: I'm out of for range now.
```


如上用例，`os.fork()` 后会返回两次，一次返回为 0（pid 0 代表自己，当程序使用 `kill -9 0` 时就会杀死自己），标识此次返回为子进程，一次返回非 0，标识了子进程的 pid。

`os.waitpid(pid, status)` 会等待指定的 pid 结束。

具体解释参考下方图片：

![os_fork](/assets/python_os.fork.jpg)
