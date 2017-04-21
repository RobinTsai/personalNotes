Book Name: Linux命令行与shell脚本编程大全(第3版)

# Day 1

## command

- `ls` 
    + `-a`: all
    + `-l`: long info
    + `-F`: classify 分类
    + `-R`: recursion (这个好用，嵌套文件也能找)

- `ln` 
    + `-s`: 软链
    + 无 `-s`: 硬链，但不可链文件夹，同样是同一个文件，因为inode相同，可用 `ls -i` 查看

- `cat` 
    + `-n`: 行号
    + `-b`: 空行无行号
    + `-s`: 压缩连续的空行为一个

- `mkdir`
    + `-p`: parents, 自动创建缺失的父目录

- `uniq`: 按行去重
    + `-c`: count, 输出重复的次数
    + `-d`: print continuous duplicated lines ONLY ONCE
    + `-D`: print continuous duplicated lines ALL
    + `-s N`: skip first N chars, `N` is a number
    + `-i`: ignore case
    + `-u`: only print unique lines
    + `-w N`: only first N chars, `N` is a number

- `rm` 不进回收站，所以最好复写
- `less` > `more`: 比more多了强大的键盘操作
- `du`: 磁盘命令，可查看所有文件和大小（包括嵌套、隐藏文件）
- `ps`: 只能看当前用户进程
    + `-ef`: 查看所有进程
- `top`: 查看占用内存情况

## shell

- 外部命令：如 `ps`
- 内部命令：如 `cd`. 以上两个用 `type/which (-a)`试试看，还有 `whereis`
- `history`: 对应文件 `~/.zsh_history`
- `;`: 单行命令的串行执行
- `()`: 创建子shell执行命令。子shell的成本高，会脱慢速度
- `coproc`: 协程，并行方式执行命令
- `(zsh; zsh; zsh; ps --forest)`分析
    + 遇见'('，创建一个子shell
    + 执行第一个zsh。然而这个时候，已经进入了第一个zsh shell，所以后面的命令没有执行
    + 当你按`CTRL+D`时，退出第一个zsh shell，执行第二个 zsh
    + 所以这个脚本从开始执行，你需要按三次 `CTRL+D`，才能输出命令 `ps --forest`的结果

