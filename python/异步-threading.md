## 异步-threading

```py
import threading
import queue
import time

# 创建一个共享的队列
shared_queue = queue.Queue()

# 生产者函数
def producer():
    for i in range(10):
        shared_queue.put(i)
        print(f"生产者生产了物品: {i}")
        time.sleep(0.5)

# 消费者函数
def consumer():
    while True:
        item = shared_queue.get()
        if item is None:
            break
        print(f"消费者消费了物品: {item}")
        shared_queue.task_done()

# 创建生产者线程
producer_thread = threading.Thread(target=producer)

# 创建消费者线程
consumer_thread = threading.Thread(target=consumer)

# 启动生产者和消费者线程
producer_thread.start()
consumer_thread.start()

# 等待生产者线程完成生产
producer_thread.join()

# 阻塞等待队列中的所有物品被消费完
shared_queue.join()

# 往队列中添加一个空值，通知消费者线程退出
shared_queue.put(None)

# 等待消费者线程完成消费
consumer_thread.join()
```
