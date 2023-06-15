- [《Linux 命令行与 shell 脚本编程大全》](#linux-命令行与-shell-脚本编程大全)
  - [一些常用命令及参数](#一些常用命令及参数)
  - [shell 基础](#shell-基础)
  - [变量](#变量)
    - [字符串操作](#字符串操作)
    - [将多行文本变为单行的方法](#将多行文本变为单行的方法)
  - [三种启动 shell 的方式](#三种启动-shell-的方式)
  - [数组变量](#数组变量)
  - [scripts](#scripts)
  - [数学运算](#数学运算)
  - [退出码](#退出码)
  - [流程控制](#流程控制)
    - [if-then](#if-then)
    - [条件测试（比较）](#条件测试比较)
    - [Case](#case)
    - [For](#for)
    - [While](#while)
    - [until](#until)
    - [break and continue](#break-and-continue)
  - [用户输入](#用户输入)
  - [再探重定向](#再探重定向)
  - [临时文件 `mktemp`](#临时文件-mktemp)
  - [控制脚本](#控制脚本)
  - [函数](#函数)
  - [创建库](#创建库)
  - [有趣的脚本](#有趣的脚本)
    - [send msg](#send-msg)
- [《鸟哥的Linux私房菜》笔记](#鸟哥的linux私房菜笔记)
  - [bash 和 zsh 的差别](#bash-和-zsh-的差别)

# 《Linux 命令行与 shell 脚本编程大全》

## 一些常用命令及参数

- `ls`
    + `-a`: all
    + `-l`: long info
    + `-F`: classify 分类
    + `-R`: recursion (这个好用，嵌套文件也能找)

- `ln`
    + `-s`: 软链
    + 无 `-s`: 硬链，但不可链文件夹，同样是同一个文件，因为 inode 相同，可用 `ls -i` 查看

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
- `du`: 查看文件夹所有文件和大小（包括嵌套、隐藏文件）
    + `--max-depth=1` 最大深度为 1
    + `-h` 以易读的方式显示文件大小
- `df -h`: 查看磁盘使用信息
- `ps`: 只能看当前用户进程
    + `-ef`: 查看所有进程
- `top`: 查看占用内存情况

## shell 基础

- 外部命令（如 `ps`）和内部命令（如 `cd`），可用 `type/which -a` 查看
- `history` 对应文件 `~/.zsh_history`. 在 Terminal 注销时，命令会更新到文件中
- `;`: 单行命令的串行执行
- `()`: 创建子 shell 执行命令。子 shell 的成本高，会拖慢速度
- `coproc`: 协程，并行方式执行命令
- 示例 `(zsh; zsh; zsh; ps --forest)` 分析
    + 遇见 `(`，创建一个子shell, `)`结束这个子shell
    + 执行第一个 zsh。这个时候已经进入了第一个 zsh shell，所以后面的命令没有执行
    + 当你按`CTRL+D`时，退出第一个 zsh shell，执行第二个 zsh，……
    + 所以这个脚本从开始执行，你需要按三次 `CTRL+D`，才能输出命令 `ps --forest`的结果


## 变量

- 定义：`res=abc` 或 `local res=abc`，定义时不加 `$`，等号前后无空格，如果不用 `local` 约束，当前 shell 中会一直保持此变量
- 使用：`$res`/`${res}` 或 `"$res"`/`"${res}"`，使用时加 `$`
- 有双引号和无双引号的差别：当用 for 循环的时候，带双引号的是一个完整的值，不带双引号会按空格分割读取每一个元素
    - 如： `a="1 2  3 4"; for v in $a; do echo $v; done` 输出 `1 \n 2 \n 3 \n 4` (`\n` 表示换行)
    - 如： `a="1 2  3 4"; for v in "$a"; do echo $v; done` 输出 `1 2 3 4`
- 查看变量：`set` 不加参数是查看所有 *用户变量*，加参数是用来设置 shell 的执行方式。另外还有 `env`, `printenv` 来查看环境变量。
- 环境变量：环境变量的设置要用 `=`，导成全局要用 `export`，但仅当前 shell 中有效
- 变量继承：subshell 继承的变量只能是父 shell 导出（`export`）的变量
- 一般地，使用变量用 `$`，修改变量不用前缀 `$`，如 `unset $my_var`，但 `printenv` 例外，用它查看环境变量不用前缀 `$`。
    + 注意变量值为带有空格的字符串时，要使用引号 `"$var"`
- 单个点号加入 `$PATH`变量，执行本目录命令就不用 `./`了。但这样还有其他问题：重启系统后即丢失 => 持久化需放入 `/etc/profile.d/` 下的 shell 文件中。这关系到下面讲的三种 shell 不同的启动方式

### 字符串操作

- 取长度：`${#var}`
- 按匹配删除：
  - 规则：`#` 从左到右、`%` 从右到左、两个按最长、一个按最短、`*` 只是通配
  - 从左到右删除长匹配 *str：`${varible##*str}`
  - 从左到右删除短匹配 *str：`${varible#*str}`
  - 从右向左删除长匹配 str*：`${varible%%str*}`
  - 从右向左删除短匹配 str*：`${varible%str*}`
- 按下标读取：
  - `${varible:START}`，从下表 START 始，截取到最后（下标从 0 开始计数）
  - `${varible:START:LEN}`，从下表 START 始，长度为 LEN
  - `${varible:START:-LEN}`，从下表 START 始，到倒数第 LEN 个
  - `${var: -LEN}` 或 `${var:(-LEN)}` 截取后 LEN 位，注意冒号后方有空格，或加括号
  - `${var:(-4):2}`，从后 4 位开始截取 2 个字符
- 读变量时附加判断：
  - 规则：`:` 多判断个空、`-` 只管返回值、`=` 赋值+返回、`+` 与 `-` 相反
  - 未定义返回默认值：`${var-DEFAULT}`（为空时返回空）
  - 非有效字串时返回默认值：`${var:-DEFAULT}`（为空返回 DEFAULT）
  - 未定义时，定义为默认值，并返回：`${var=DEFAULT}`
  - 非有效字串时，定义为默认值，并返回：`${var:=DEFAULT}`
  - 已定义返回 OTHER：`${var+OTHER}`
  - 已定义且非空返回 OTHER：`${var:+OTHER}`
- 按匹配替换：
  - 规则：`#` 从前、`%` 从后、
  - 替换一次匹配：`${string/substring/replacement}`
  - 替换全部匹配：`${string//substring/replacement}`
  - 前缀匹配替换：`${string/#substring/replacement}`
  - 后缀匹配替换：`${string/%substring/replacement}`
- 比较
  - 规则：可以用通配，放在 `[[ ` 和 ` ]]` 中间，要用空格
  - `[[ "a.txt" == a* ]]`        # 逻辑真 (pattern matching，注意正则没有引号)
  - `[[ "a.txt" =~ .*\.txt ]]`   # 逻辑真 (regex matching)
- 获取匹配的字符串
  - 这需要用到 `expr match`
  - `expr match $string '\([a-c]*[0-9]*\)'`
  - `expr $string : '\([a-c]*[0-9]\)'`
  - `expr $string : '.*\([0-9][0-9][0-9]\)'` // 只显示括号中匹配的内容

### 将多行文本变为单行的方法

三种方式（以下示例用逗号拼接）：

- 用 `sed`：`echo "$multi_line_str" | sed ':a;N;$!ba;s/\n/,/g'`
- 用 `tr`：`echo "$multi_line_str" | tr '\n' ','` （注意删除最后一个逗号）
- 转为数组 ```IFS=$'\n' clientUrls=(`echo $clientUrls`);```，再用 for 循环拼接字符串到变量

## 三种启动 shell 的方式

- 登陆时作为默认登录 shell
- 作为交互式 shell
- 作为运行脚本的非交互式 shell

<br>

- 1. 非交互式 shell 最简单，就是 shell 直接读取存放在文件中的命令并执行；
- 2. 交互式 shell
    + 只运行 `~/.bashrc`文件。如每开一个 bash 就会执行 `~/.bashrc`
- 3. 登陆 shell，需要用户名、密码登录才能进入的 shell
    + 五个不同的启动文件入口
        * `/etc/profile` 主启动文件, 所有 user 都会读
        * 1, `~/.bash_profile`; `~/`即 `$HOME/`, 每个用户有自己的 `$HOME`
        * 2, `~/.bash_login`
        * 3, `~/.profile`(上面三个有顺序，且只会执行一个)
        * `~/.bashrc` (这个文件可储存 **个人用户永久性变量**)
    + `/etc/profile`，每个帐户登陆时会执行它，可顺此看代码。它主要迭代了所有 `/etc/profile.d/`下的 `.sh`文件
    +  `$HOME/` 下的文件一般只用到其中一到两个，这些文件定义了一些环境变量，并在每次启动 bash shell 时生效

注：一般在首先登录之后，才能继续使用非登录 shell，`exit` 即可退出登录 shell，又可退出非登录 shell；而 `logout` 直接退出登录 shell。

## 数组变量

- 括号用于声明数组: `myArr=(one two three)`；注意：空格的有无
- 输出所有：`echo ${myArr[*]}` （用 `*` 可输出所有）
- `unset myArr[2]` 后，数组其他 key->value 不会变
- TODO：带空格的文本被认为是一个变量怎么处理
- 多行的文本变更为数组：
    - bash 可用 readarray，但 zsh 无法用
    - 使用 IFS 变量，`IFS=$'\n' my_array=($(echo $lines_txt))`
    - 使用 IFS 变量，```IFS=$'\n' my_array=(`echo $lines_txt`)```
    - 注意备份 IFS ，`IFS_OLD=$IFS; IFS=$'\n' my_array=($(echo $lines_txt)); IFS=$IFS_OLD`
- 关联数组

```sh
declare -A supported            # 定义
supported[easy-deploy.tar]=1    # 注意 key 不能有引号
echo ${supported[etcd-chk.tar]} # 注意使用时一定要用 ${}
# zsh histchars 会让 ! 意义变化导致 ${!supported[@]} 无法正常工作（获取关联数组的 key）
```

## scripts

- 将命令赋值给变量有以下两种方法，都是将执行结果赋值给变量。
    + 用 `反引号` 包裹
    + 用 `$()` 包裹
- 在脚本中使用字符串拼接命令，如果内部有引号，则默认会进行转义，如果执行失败可以用 `eval $cmd_str` 来执行
- 命令替换会 **创建一个子shell** 来运行命令
- `./` 会创建一个子shell，不加路径时不是子shell
- 用 `exec` 命令不会创建子 shell 去执行命令
- `<<` 叫 **内联输入重定向**，真正的输入其实来自用户，它只是用来标记结束的字符串


## 数学运算

- `expr` 不建议使用，弃学
- `$[]`包裹。仅整数运算，如 `a=5; echo $[a-1]`。（zsh 提供了浮点数运算）
- `bc` 命令，'bash calculator'，支持浮点运算（内置变量 `scale`）

## 退出码

- 变量 `$?` ，一个成功的退出应显示为 0，否则是个正数值
- `exit` 可自定义状态码(0~255)

## 流程控制

### if-then

- `if-then(-elif-then)(-else)-fi`：`if` 后面必须是命令（不能是数字），按退出状态码（0 表示成功）判断。if的命令后有分号 `;` 时可以把 `then`放在同行

```shell
    if Condition
    then
        Commands
    elif Command2; then
        Commands
    else
        Commands
    fi
```

### 条件测试（比较）

用 `test` 或 `[ CONDITION ]`（严格空格）。用于条件测试（数值、字符串、文件），可和if一起使用。

+ `test $var1`，只要变量不为空都通过（应该是这样）
+ 数值比较（注意不能用 > 号等）： `[ n1 -eq n2 ]`. `-eq`,`-ge`,`-gt`,`-le`,`-lt`,`-ne`
+ 字符串比较：`[ str1 = str2 ]`. `=`/`==`（是的，单个 `=` 就可以，zsh 不支持 `==`）,`!=`,`<`,`>`; `-n str1`（非空）,`-z`（为0）
    * 未定义的变量用字符串长度测试，输出为 0
    * `>`, `<`在使用时大多情况下要加转义符，否则认为是重定向
+ 文件比较
    * `-d` is directory?
    * `-e` is existent?
    * `-f` is a file?
    * `-r`, `-w`, `-x` is readable/writable/executable
    * `-s` is empty?
    * `-nt` is newer than
    * `-ot` is older than

- 复合条件： `&&`、`||`、`!`，`[ condition1 ] && [ condition2 ]`，示例：
    - `if [ $num1 -gt 5 ] && [ $num2 -lt 50 ]; then`
    - `if ! [ $num1 -eq $num2 ]; then`
- `(( EXPRESSION ))`. 高级 **数学**表达式. 支持 `++`, `--`, `!`, `~`, `**`(幂), `<<`, `>>`, `&`, `|`, `&&`, `||`
- `[[ EXPRESSION ]]`. 高级 **字符串**表达式. 支持模式匹配 (有些shell可能不支持)

### Case

```shell
case $variable in
    pattern1 | pattern2)
        commands1;;     # can lay it in up one line
    pattern3)
        commands2
        ;;
    *) commands3;;
esac
```

### For

- 重定向可以写在 done 后面，这样就不会输出在shell中了

```shell
for var in LIST         # there is 'var', not '$var'.
do                      # for var in list; do ...
    commands1           # there use '$var', not 'var'
done > output.log       # 重定向(非必需)可以写这里
```

- `LIST` can be:
    + `str1 str2 str3` elements seperate by SPACE by default, or use quotes for a sentence as one element
    + SPACE 是空格，制表符，换行符. 更改 `IFS`的值来更改这个符号.
        * IFS(Internal Field Separator), 内部字段分割符
        * `IFS=:`
        * `IFS=$'\n'`. 至于为什么用 `$`，自己用到的时候查吧
        * `IFS=$'\n':;`. 指定多种分隔符
    + `$list` use variables. `list="ele1 ele2 ele3"`, `list=$list" ele4"`(字串拼接)
        + 如果没有按空格迭代（bash 可以，zsh 不可以），可以再用 `echo $list` 表示
    + `$(cat $file)` 从命令中读。 以上说过`$()`是一种命令替换符
    + `/home/robin/test/*` 用通配符. 这时应该将 `commands1`中所有用到 `$var`的地方用引号括起来(避免空格)
    + `{1..10}` 表示 1 到 10
    + `$(seq 1 2 10)` 从 1 到 10 步长 2

- for 中将多行的字符串转换为数组（或单行用空格分割）的方法：
    - `IFS_OLD=$IFS; IFS=$'\n' my_array=($(echo $lines_txt)); IFS=$IFS_OLD`

```shell
IFS_OLD=$IFS  # backup old IFS
IFS=$'\n'     # set new IFS
IFS=$IFS_OLD  # restore old IFS
```

- For as C lang `for (( i = 1; i <= 10; i++ ))`

### While

```shell
while Condition          # test or []
do
    Commands
done
```

```sh
# 例，从 input 中读每行
grep -Eo '[0-9]*' a05 | while read line; do; echo got_$line; done;
```

### until

- 只有在退出状态码为0时终止

```shell
until Condition          # test or [].
do
    Commands
done
```

### break and continue

- `break N`
- `continue N`

## 用户输入

- `$0`, shell脚本名
- `$$`, shell本身的PID
- `$1`~ `$9`, `${10}`... `${n}`, 参数
- `$#`, 参数个数
- `$*`和`$@`: 返回所有参数。但 `$*`把所有参数当作一个变量(可以有空格的变量)保存，而 `$@`当作一个字符串中独立的单词。在输出时没有分别，但用for时就有区别了.
- `basename` can remove path, only leave file name
- `shift N` 移动变量,单独用即可。N可省，默认为1,$1删除, $2->$1, $3->$2
- shell中-a后跟参数值就是用 `case`, `shift` 组合使用的
- `getopt`是一个处理选项和参数的工具. (一般你看到的-ab是-a,-b的组合，就是它做的)
- `getopts`扩展了 `getopt`
    + -a "test1 test2",使用时多了引号，是它做到的
    + 你用的 `-pabc123_`,-p能和值放在一起是它做到的
- `read`:
    + 读取用户输入
        * `read name`, 将输入信息存入 `name`中
        * `-p`, 读时自定义提示 `read -p 'Please enter your name: ' name`
        * 不指定以上的name变量时，它默认把输入放入 `$REPLY`中
        * `-t`,指定用户输入的时间(s)，超时返回一个非0状态码
        * 输入是实时的，所以用 case可以及时限定输入的长度(是y就退出)
        * `-s`隐藏用户输入的内容
    + 读取文件
        * 技巧： `cat test | while read line ...` (read自动读取下一行)


## 再探重定向

- 文件描述符: 0, 1, 2; 自定义的:3~8
    + `0`, STDIN
    + `1`, STDOUT; `1>`, `1>>` 将STDOUT重定向
    + `2`, STDERR; `2>`, `2>>` 将STDERR重定向;
    + `cat file 1> file1 2> file2`, 分别重定向
    + `&>`, `&>>`; 将STDOUT和STDERR都重定向到一个文件。(自动地shell认为错误信息优先级高)
    + `>&2`, 改变重定向, 可以将STDOUT导向STDERR.(shell默认将STDERR导向STDOUT)
- 永久重定向 `exec 1>out.log`; 在脚本中某位置设定了它后，之后的STDOUT会重定向到out.log (恢复:中间量)
- 输入重定向 `exec 0< file`; 可以在脚本中使用，把文件重定向到STDIN (之后可直接用read)
- 自定义重定向 `exec 3>>test.log` ( `>>`比 `>`好), `echo '...' >&3`
- 自定义读写文件描述符 `exec 3<> testfile`.即可读入，也可写入
- 手动关闭文件描述符 `exec 3>&-`
- `>/dev/null` 阻止输出
- `tee` T型管道, 一方输出到stdout, 一方输出到指定文件(默认覆盖)
- `tee -a` 输出追加

- 这个脚本可以将数据按格式填充到模板中

```shell
#!/bin/bash

outfile='members.sql'       # define output file
IFS=','                     # redefine seperator ('cause it's from .csv file)
while read lname fname address city state zip   # read each line into each variable
do
    cat >> $outfile << EOF  # each line below as INPUT output to file, and end when EOF
    # the next lines till EOF will be as INPUT (STDIN),
    # so having spaces at front or not is different
INSERT INTO members (lname,fname,address,city,state,zip) VALUES ('$lname','$fname','$address','$city','$state','$zip')  # $lname is variable, will be replaced
EOF    # attention, this line must not have space at front. because ' EOF'!='EOF'
done < ${1}                 # read from $1 parameter (file)
```

## 临时文件 `mktemp`

- 创建临时文件 `mktemp file.XX...X` (3+个X会自动生成)
- `-t` 在系统临时目录中创建，并返回全路径
- `-d` 创建临时目录

## 控制脚本

- Linux信号
    + 1, SIGHUP, 挂起进程
    + 2, SIGINT, 终止, CTRL+C
    + 3, SIGQUIT, 停止, 停止进程可保留在内存中，以待继续运行
    + 9, SIGKILL, 无条件终止
    + 15, SIGTERM, 尽可能终止
    + 17, SIGSTOP, 无条件停止但不终止
    + 18, SIGTSTP, 停止或暂停但不终止, CTRL+Z
    + 19, SIGCONT, 继续运行停止的进程
- `kill -9 PID`, `-9` 无条件终止
- `./shell.sh &`, `&` 后台运行脚本, (但此进程还是和当前终端会话连在一起, 终止会话->终止进程)
- `nohup ./shell.sh &` 阻断SIGHUP信号 (退出终端依旧运行, 输出内容重定向到nohup.out)
- `trap` 捕获信号
- `jobs -l` 查看作业
- `bg`, `fg`, 重启作业 (backgroud or frontground)
- `nice`, `renice`, 调整优先级
- `at` 定时作业 `atq`, `atrm`
- `cron` 安排定时作业

## 函数

- 定义

```shell
function NAME {
    COMMANDS
}
```
or
```shell
name() {
    COMMANDS
}
```

- 使用 (先定义，后使用)

```shell
NAME # no need ()
```

- `return` 退出并指定退出状态码 (0~255) (必须是numberic型的)
- `local` 声明的变量作用域是本函数 (果然实践才能发现很多奇怪的问题）
    + 不要随意用 local, 我将自己 shell 中的变量改成 local，出现了很奇怪的现象
    + 请在 shell 中试试 `files=$(ls)` 和 `local files=$(ls)`
    + `local files=$(ls)` 等效于 `local files=file1 file2 file3`，会分别定义 `files=file1`, `file2=''`, `file3=''`, 而 `files=$(ls)` 才会存成一个变量
- `return` 和 `exit` 的异同：
    + 都是退出，且返回退出码
    + `return` 仅仅退出函数，而 `exit` 会退出shell


## 创建库

- 使用 `source` 或 `.`，如 `source ./script.sh` or `. ./script.sh`.
    + 用 `source` 或 `.` 与单纯执行脚本不同。前者是在当前 shell 中执行脚本，而后者其实是在子 shell 中执行的，子 shell退出后，方法、变量会销毁
    + 但为什么 `source ~/.profile` 等一些操作是系统级的呢？当前 shell 和再开一个 shell，它们的关系是兄弟关系啊，肯定是系统对这些文件做了什么


- `select` 会在shell中自动生成 menu
- 例: (You can chose the Number before the menus)
    + ```shell
    PS3='Enter the option:' # attention this
    select x in 'a' 'b' 'c' 'd'
    do
        case $x in
            'a')
                echo 'You chose A'; break;;
            'b')
                echo 'You chose B'; break;;
            'c')
                echo 'You chose C'; break;;
            *)
                clear
                echo 'You chose other';;
        esac
    done
    ```

- `sed`

## 有趣的脚本

### send msg

- `who` who is online; `who -T` check open 'mesg' or not;
- `whoami` who am I
- `mesg` check; `mesg y` open; `mesg n` close;
- `write user pts/1` open to send msg to 'user pts/1'

# 《鸟哥的Linux私房菜》笔记

找到了可能是他的博客: [link](http://www.cnblogs.com/ningvsban/category/423741.html)


- `cal`: calendar
- `man` 等命令中，用 `/STR`来搜索字符串(向下)，`?`是向上, `n`next，`N`last
- `nl -w N FILE` 可带补0的行号输出文件内容
- `find` 比 `whereis/locate` 搜文件慢，后者是从数据库中查的
- 还记得字符串的 **部分裁剪** 吗？ `#`, `##`, `%`, `%%` （修改ozsh时用了）
    + `#`, `##` 是从左往右
    + `%`, `%%` 是从右往左
    + `#`, `%`, 最短匹配
    + `##`, `%%`, 最长匹配
    + `${VAR#*STR}` 剪掉最短匹配 `*STR`. (VAR是变量名)
    + `${VAR##*STR}` 剪掉最长匹配 `*STR`
    + `${VAR%STR*}` 剪掉最短匹配 `STR*`
    + `${VAR%%STR*}` 剪掉最长匹配 `STR*`
- 变量内容的 **部分替换** `/`, `//`
    + `/`, 仅一处 `${VAR/SEARCH/REPLACEMENT}`
    + `//`, 全部处 `${VAR//SEARCH/REPLACEMENT}`
- 变量的测试及赋值 `-`/`:-`, `+`/`:+`, `=`/`:=`, `?`/`:?`
    + 冒号的差别：无冒号时只检测有没有定义，有冒号判断是否为空字符串
    + `NEW_VAR=${OLD_VAR-NEW_VALUE}`和 `NEW_VAR=${OLD_VAR:-NEW_VALUE}`
        * 相当于 `NEW_VAR = OLD_VAR ? OLD_VAR : NEW_VALUE`
        * 但两者的判断条件不一样，前者是 **有没有定义**，后者为 **是不是空值**
    + `+`/`:+`与 `-`相反
    + `=`/ `:=`把旧变量 `OLD_VAR`也变成 `NEW_VALUE`
    + `?`/ `:?` 为空时报出错误, 否则进行赋值


- `ls ./test || mkdir test` 利用的是返回的错误码 `$?`
- `cut -d CHAR -f NUMBER` **选取命令**和 `grep`功能相似. 这个很有用啊，你可以按每一行固定格式进行解析后显示
    + `NUMBER` 还可以是 `N1,N2,N3`, `N1-N3`, `N1-`, `-N3`
    + 另外还有一个参数 `-c`, 按字符进行cut. (-d: delimiter)
- `sort` 可进行排序 `-t`, `-k`连用，指定分隔符并选取第几列进行排序
- 字符转换命令
    + `tr`, translating, 单字符的替换/删除, 但支持正则 `[a-z]`/`[A-Z]`
    + `col`, 过滤控制字符
    + `join`, 可用mysql中的join的用法来思考其作用,或用excel对列的操作来思考, 可实现按某一字段，匹配两个文件的行，进行整合
        * `join file1 file2`
        * `join -j N file1 file2` (N为列号，默认为1)
        * `join -1 2 -2 3 file1 file2`, 按file1的第2列与file2的第3列进行匹配，并合并
        * `join file1 file2 | join - file3`, `|`和 `-`一起使用实现标准输入
    + `paste` 将两个文件按行以tab分隔联结
    + `expand` [tab]转空格


- `seq [FROM] [STEP] [LAST]`, 生成连续的数字, 这个功能和 for一起使用挺好的
- `sh [-nvx] script.sh`可用来查询语法
    + `-n`, 不执行script, 只查询语法问题
    + `-v`, 执行前先输出script内容
    + `-x`, 执行的过程(包含代码)全列出来

## bash 和 zsh 的差别

- `echo` 在 `zsh` 中默认使用了 `-e` 参数，在 `bash` 中没有，所以在 `bash` 中要输出换行，记得加 `-e`
- `#!/bin/bash` 一定要在行首，前面也不能有空行。否则会用 `/bin/sh` 解释器运行脚本，语法不同会发生异常
- 此外，对于没有可执行权限的 `.sh` 文件，它的运行默认也会是 `/bin/sh`（不论是否加正确 `#!/bin/bash`）
- 用 `sh ./xx.sh` 时，实际是在当前 Shell 环境启动了一个新的 Shell 进程直接读取内容并执行
- `chmod +x xx.sh; ./xx.sh` 运行可以按 `xx.sh` 内 shebang 指定的解释器运行，这种方式比 `sh xx.sh` 更安全
