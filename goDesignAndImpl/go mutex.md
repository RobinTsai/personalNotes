# mutex

- 使用锁一定要短，我的业务中有好多管理各自 worker 的 manger，他们之间有交互，我现在已经不知道他们都在什么地方使用锁了，应该在一开始就想好，锁住的内容一定要短。记住这个原则
- 或者顺序话也是一种方法，用 chan 来通信，不要用锁，锁的开销太大了，且危险
