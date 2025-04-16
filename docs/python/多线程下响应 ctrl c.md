# 多线程下响应 ctrl c

在多线程执行过程中，按一次 Ctrl+C 只会终止一个线程的执行，并在控制台输出异常信息。

```py
import sys, os, signal

class Watcher:
    def __init__(self):
        self.child = os.fork()
        if self.child == 0:
            return
        else:
            self.watch()

    def watch(self):
        try:
            os.wait()
        except KeyboardInterrupt:
            self.kill()
        sys.exit()

    def kill(self):
        try:
            os.kill(self.child, signal.SIGKILL)
        except OSError:
            pass

if __name__ == '__main__':
    Watcher()
    # do anything you want, many threads or just one
```
