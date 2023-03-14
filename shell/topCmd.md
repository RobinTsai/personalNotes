# top 的使用

在 top 界面:

- M：按内存排序（注意大写，即 Shift+m）
- m：显示内存形式（图表、百分比等）
- o：筛选，再加 COMMAND=java 可筛选 java 进程
- u：按用户筛选，如输入 root 筛选用户下所有进程
- U：按用户筛选，和 u 不同的是 u 只能筛选 effective user，而 U 可以筛选任何 user（real、effective、saved、filesystem）
- b：批模式，在输出到其他程序或文件的时候很有用，会停止交互，并迭代 -n 指定的次数或 kill 掉
- n：指定刷新次数，如 -n 2 刷新两次数据后退出（默认 3s 刷新一次）
- d：指定刷新间隔
- p：指定监控 PIDs，最多 20 个 PID，如 -pN1 -pN2 ... 或 -pN1,N2,N3...（按 = 可恢复到所有进程的监控）
