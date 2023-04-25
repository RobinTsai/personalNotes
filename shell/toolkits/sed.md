# sed 命令编程

sed，Stream EDitor，命令行式的文本编辑器。

特点：非常高效。一次只读取一行文本到缓冲区，然后读取命令对此行进行编辑。

因为不需要一次性将文本全部加载出来。

适用场合：

- 大文件编辑
- 复杂的编辑命令
- 单次扫描文件，多个编辑命令

注意：sed 只对缓冲区进行编辑，不直接编辑原始文件，所以需要重定向保存更改结果。（疑问，今天的尝试没有啊，Win 环境 Git bash）

## 基本用法

三种方式：

- 命令行方式
- sed 脚本方式 (与 `sed -f` 一起使用)
- shell 脚本方式

三个常用选项：

- `-n`，**不** 打印 **所有行** 到标准输出
- `-e`，将下一个字符串解析为 sed 编辑命令
- `-f`，表示调用 sed 脚本文件

命令体两个组成部分：

- 定位文本部分
- 编辑命令部分

定位文本方法：

- `x`，指定行号
- `x,y`，指定从 x 到 y 的行号范围
- `/pattern/` ，查询包含模式的行
- `/pattern/pattern/`，查询包含两个模式的行
- `/pattern/,x`，从与 pattern 匹配的行到第 x 行间的所有行
- `x,/pattern/`，从第 x 行到与 pattern 匹配的所有行
- `x,y!`，查询不包括 x 和 y 行号的行

编辑命令（部分）：

- `p`，打印匹配行（常与 `-n` 一起用）
- `=`，输出文件行号
- `a\`，行后追加，如 `/line/a\new line appended`
- `i\`，行前追加，如 `/line/i\new line inserted before`
- `d`，删除定位行，如 `/line/d`
- `c\`，替换本行，如 `/file/c\replace with this line`
- `{}`，命令组，组内命令用分号分隔
- `s`
- 还有 r，w，q，l，n，h，x，g，G

## 行匹配

### -n 与 p

`-n` 表示不输出全部行（`-n`），无 `-n` 表示会输出全部行；`-p` 表示只输出匹配行（`1p`）

所以，

- `sed -n '1p' input`，只输出第一行
- `sed '1p' input`，会先输出第一行，然后输出全部行（第一行输出两次）
- `sed -n '3,6p' input`，只输出 3-6 行

### -e 、 =

- `-e`，expression，表示将下一个字符串解析为 sed 命令，当只有一个命令时可省略
- `=`，输出匹配行行号

所以，

- `sed -n '/Certificate/=' input` 只会输出匹配到 `Certificate` 的行到行号
- `sed -n -e '/Certificate/p' -e '/Certificate/=' input` 会先执行第一句，输出存在 `Certificate` 的行，再（另起一行）输出此行行号

注意，sed 不支持多个编辑命令合并使用，如 ~~`sed -n '/Certificate/p=' input`~~

### -f 选项

`-f` 只有调起 sed 脚本文件时才起作用。

追加、插入、修改、删除、替换 常常需要几条 sed 命令组合完成

如追加一行的例子可以用 `sed '/Certificate/a\a new line.' input`
，但如果要追加一个多行文本，就可以定义一个 sed 脚本文件 `append.sed` 内容如下：

```sh
#!/bin/sed -f
/Certificate/a\ # a\ 表示此处换行添加文本

A new line.\ # 这个反斜杠表示换行
Another new line.
```

> 注意，这里两个 `\` 表示换行

然后执行命令 `./append.sed input`

### 行匹配的特殊表达

- `$` 在正则中表示行尾，但在 sed 从表示最后一行。如 `sed -n '＄p' input` 只输出最后一行
- sed 的编辑命令放在单引号内外皆可，如，`sed -n '＄p' input` 等价于 `sed -n '＄'p input`
- `!` 符号取反，即 `x,y!` 表示匹配不在 x-y 范围内的行，如 `sed -n '2,10!p' input` 表示输出 2-10 之外的行。但，`!` 不能用于模式匹配，即 ~~`/pattern/!`~~ 不可用

**注意，实战中发现 `/sth/!d` 可以表示删除匹配行之外的其他行，这岂不与上述描述的有出入**

## 编辑命令

### 插入文本

`i\`，insert，用法和 `\a` 追加文本一致，只不过是在匹配行到行前添加文本

```sh
sed -i -e '1i\mode: set' ./${file} # 首行加上 mode: set
```

### 修改文本

`c\`，替换匹配行，用法和上述一致，略

### 删除文本

`d`，其后不带 `\` 符号，其他与上述类似

```sh
sed -i '/vendor/d' ./${file} # 剔除包含 "vendor" 行
sed -i '/IRTCROOM/!d' ./${file} # （反向剔除）仅保留包含 "IRTCROOM" 的行
```

### 替换文本

`s/.../.../g` 会将匹配到的行从的文本，用新文本进行替换。注意，这里是 文本替换，不是 行替换。

```sh
sed -i 's/:[0-9]*\.[0-9]*,[0-9]*\.[0-9]*//g' ./${file} # 替换 ":dd.dd,dd.dd " 为空, d 表示数字
sed -i 's/C:\\Users\\go/D:\\gopath/g' ./${file}
```

后缀 `g` 表示替换所有，不带 `g` 时只替换行中的第一处匹配。另外此位置还可以是 `p`、`2`（数字）、`w`、`pg`、`2p`

- `p`，它与之前的介绍一致，表示输出行
- `2` ，一个数字 n，可以表示替换第 n 个匹配
- `w`，表示输出到文件，如 `sed -n 's/seu/nyue/w output' input`
- `pg`、`2p` 表示他们组合

### 写入新文件

`w`，如 `sed -n '1,5 woutput' input`，`sed -n '/globss/w output' input`

### 从文件中读入文本

`r`，如 `sed '/Centi/r otherfile' input`，它将在指定匹配的位置的行后追加 otherfile 的内容（与前面的一个例子一致）

### 退出命令

可以在不完全扫描整个文本文件就可以退出

`q`，如 `sed '5 q' input`，即表示扫喵晚前 5 行即退出

### 字符替换

`y`，与 `s` 一样的用法，但它表示字符集到字符集对应的单个字符的替换，如 `sed 'y/ymt/YMT/' input`

### 命令组

`{}` 命令组括起来的成为一组，其内多个命令用分号分隔。

口述不成，见例子，如:

- `sed -n -e '/Certification/p' -e '/Certification/=' input` 可写成 `sed -n -e '/Certification/{p;=}' input`
- `sed -n -e '/Certification/{s/i/I/g;s/le/LE/;}' input` 表示在匹配到 Certification 的行中，将 i 全部替换成 I，然后将第一个 le 替换成 LE

### 处理匹配行的下一行

编辑命令 `n` 的意义是匹配当前行的下一行

如 `sed '/certi/{n;s/11/99/;}' input` 即在匹配到 `certi` 行到下一行，使用 `s/11/99/` 命令进行编辑

### 编辑命令的特殊表示

`&`，表示被替换的字符串，相当于一个变量用，在模式匹配时可以复用被匹配值

如，`sed -n 's/seu/(&)/pg' input` 等同于 `sed -n 's/seu/(seu)/pg' input`

`;` 可分隔多个编辑命令

行末一个引号 `'` 会进入多行编辑模式
