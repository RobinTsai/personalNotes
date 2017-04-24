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
    + 遇见 `(`，创建一个子shell, `)`结束这个子shell
    + 执行第一个zsh。然而这个时候，已经进入了第一个zsh shell，所以后面的命令没有执行
    + 当你按`CTRL+D`时，退出第一个zsh shell，执行第二个 zsh
    + 所以这个脚本从开始执行，你需要按三次 `CTRL+D`，才能输出命令 `ps --forest`的结果

# Day 2

## 环境变量

- `set` 单独用是查看用户变量，加参数是用来设置shell的执行方式。另外还有 `env`, `printenv` 来查看环境变量。
- 环境变量的设置要用 `=`，导成全局要用 `export`
- subshell中修改全局环境变量，仅当前shell中有效，用 `export`覆盖也不行
- subshell继承的变量只能是父shell导出(`export`)的
- 一般地，使用变量用 `$`，操作变量不用 `$`，仅 `printenv`例外.如 `unset $my_var`
- 单个点号加入 `$PATH`变量，执行本目录命令就不用 `./`了。但这样还有其他问题：重启系统后即丢失 => 持久化,即放入 `profile.d/`下的shell中。这关系到下面讲的三种shell不同的启动方式
- 三种shell不同的启动方式
    + 1. 登陆时作为默认登录 shell
    + 2. 作为交互式 shell
    + 3. 作为运行脚本的非交互式 shell

- 1. 默认登陆shell
    + 五个不同的启动文件入口 
        * `/etc/profile` 主启动文件
        * `~/.bash_profile`; `~/`即 `$HOME/`
        * `~/.bashrc` (这个文件可储存 **个人用户永久性变量**)
        * `~/.bash_login` 
        * `~/.profile`
    + `/etc/profile`，每个帐户登陆时会执行它，可顺此看代码。它主要迭代了所有 `/etc/profile.d/`下的 `.sh`文件
    +  `$HOME/`下的文件一般只用到其中一到两个，这些文件定义了一些环境变量，并在每次启动bash shell时生效

- 2. 交互式shell
    + 只运行 `~/.bashrc`文件。(这就是为何我在这里引入项目build脚本时，每开一个shell都会执行的原因)

- 3. 非交互式shell

## 数组变量

- 定义: `myArr=(one two three)`注意:所有的空格有无是严格的
- 输出所有：`echo ${myArr[*]}`(用 `*`可输出所有)
- `unset myArr[2]`后，数组其他key->value不会变
