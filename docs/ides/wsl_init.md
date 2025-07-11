# Step config shell

```sh
# zsh
sudo apt-get install -y zsh
chsh -s $(which zsh)
# oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sh -c "$(curl -fsSL https://gitee.com/pocmon/ohmyzsh/raw/master/tools/install.sh)"
# powerlevel10k - oh-my-zsh 的主题，安装完会自行启动配置
git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ~/powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
# ssh 配置（下面命令为自己生成，也可以直接拷贝已有的 私钥、公钥、config 等文件）
ssh-keygen -t rsa -b 1024 # 注：备份自己常用的 Host Config 信息
# git clone 项目
```

```sh
# 安装高亮插件
git clone https://gitee.com/asddfdf/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# 安装自动建议插件
git clone https://gitee.com/chenweizhen/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# 安装字体
sudo apt-get install fonts-powerline
# 使用插件
plugins=( OTHER  zsh-syntax-highlighting zsh-autosuggestions)
```

# 配置 PowerShell

- 参考 [本项目下：docs/others/powershell.md](/docs/others/022.powershell.md)
- 编辑 `~\Documents\WindowsPowerShell\profile.ps1` 若没有则创建目录和文件
- 创建目录用 `mkdir WindowsPowerShell`
- 创建文件用 `New-Item profile.ps1`

```PowerShell
function catWithCn($a) {get-content -encoding utf8 $a} # 让 cat 支持中文

Set-Alias -Name l -Value ls
Set-Alias -Name ll -Value ls
Set-Alias -Name catt -Value catWithCn
```

若遇到 PowerShell 报错：因为在此系统上禁止运行脚本。是因为 PS 执行脚本的策略默认 Restricted 会禁止所有脚本运行，PS 中执行：

```PowerShell
Set-Executionpolicy remotesigned
```

# 配置 Git

```sh
# git clone 明明在 gitlab 上配置了 sshkey，但仍然提示没有权限（调试方法：ssh -Tvvv git@git.xxx.com）
echo 'PubkeyAcceptedKeyTypes +ssh-rsa' >> /etc/ssh/ssh_config
```

一般配置文件：

```ini
# ~/.gitconfig
[alias]
        l = log
        s = status
        b = branch
        c = checkout
        d = diff
        g = log --graph --all
[core]
        editor = vim
[pager]
        branch = false
[diff]
        tool = vimdiff
[user]
        name = robin
        email = robincai@qq.com
```

# 配置 Go 环境

```sh
# 安装 goup（略，目前通过 copy 的二进制文件）
goup install go1.17.13 # 用 goup 安装 go（指定版本）
# 指定 go sdk 版本
goup set go1.17.13
# 将 go 的 bin 加入 path 中，并生效（流程化安装 goup 会自动配置）
echo 'export PATH=$PATH:$HOME/.go/current/bin' >> ~/.zshrc & source ~/.zshrc
```

# 设置 Goland

windows 的 keymaps 配置文件在 `"~\AppData\Roaming\JetBrains\GoLand2021.2\keymaps\Windows copy.xml" 下`

```xml
<keymap version="1" name="Windows copy" parent="$default">
  <action id="$Redo">
    <keyboard-shortcut first-keystroke="shift ctrl z" />
    <keyboard-shortcut first-keystroke="shift alt back_space" />
    <keyboard-shortcut first-keystroke="ctrl y" />
  </action>
  <action id="Back">
    <keyboard-shortcut first-keystroke="ctrl alt left" />
    <mouse-shortcut keystroke="button4" />
    <keyboard-shortcut first-keystroke="alt left" />
  </action>
  <action id="ChangesView.ToggleCommitUi" />
  <action id="CheckinProject" />
  <action id="CloseContent">
    <keyboard-shortcut first-keystroke="ctrl f4" />
    <keyboard-shortcut first-keystroke="ctrl w" />
  </action>
  <action id="CompareTwoFiles" />
  <action id="Console.Execute.Multiline" />
  <action id="Console.SplitLine" />
  <action id="Console.TableResult.CloneRow" />
  <action id="Console.TableResult.DeleteRows" />
  <action id="Console.TableResult.Submit" />
  <action id="Diff.ShowDiff" />
  <action id="DirDiffMenu.SynchronizeDiff.All" />
  <action id="Editor Redo">
    <keyboard-shortcut first-keystroke="ctrl y" />
  </action>
  <action id="EditorDeleteLine" />
  <action id="EditorDown">
    <keyboard-shortcut first-keystroke="down" />
    <keyboard-shortcut first-keystroke="ctrl k" second-keystroke="ctrl k" />
  </action>
  <action id="EditorDuplicate" />
  <action id="EditorLeft">
    <keyboard-shortcut first-keystroke="left" />
    <keyboard-shortcut first-keystroke="ctrl j" />
  </action>
  <action id="EditorLineEnd">
    <keyboard-shortcut first-keystroke="end" />
    <keyboard-shortcut first-keystroke="ctrl k" second-keystroke="ctrl l" />
  </action>
  <action id="EditorLineStart">
    <keyboard-shortcut first-keystroke="home" />
    <keyboard-shortcut first-keystroke="ctrl k" second-keystroke="ctrl j" />
  </action>
  <action id="EditorRight">
    <keyboard-shortcut first-keystroke="right" />
    <keyboard-shortcut first-keystroke="ctrl l" />
  </action>
  <action id="EditorSelectWord" />
  <action id="EditorSplitLine" />
  <action id="EditorStartNewLine">
    <keyboard-shortcut first-keystroke="shift enter" />
    <keyboard-shortcut first-keystroke="ctrl enter" />
  </action>
  <action id="EditorUp">
    <keyboard-shortcut first-keystroke="up" />
    <keyboard-shortcut first-keystroke="ctrl i" />
  </action>
  <action id="FileChooser.GotoDesktop" />
  <action id="FindNext">
    <keyboard-shortcut first-keystroke="f3" />
  </action>
  <action id="Forward">
    <keyboard-shortcut first-keystroke="ctrl alt right" />
    <mouse-shortcut keystroke="button5" />
    <keyboard-shortcut first-keystroke="alt right" />
  </action>
  <action id="Generate.Missing.Members.ES6" />
  <action id="Generate.Missing.Members.TypeScript" />
  <action id="Git.Commit.Stage" />
  <action id="ImplementMethods" />
  <action id="InsertLiveTemplate" />
  <action id="NextTab" />
  <action id="PreviousTab" />
  <action id="RunDashboard.CopyConfiguration" />
  <action id="SelectNextOccurrence">
    <keyboard-shortcut first-keystroke="alt j" />
    <keyboard-shortcut first-keystroke="ctrl d" />
  </action>
  <action id="SendEOF" />
  <action id="SmartSelect" />
  <action id="SplitChooser.Duplicate" />
  <action id="TableResult.GrowSelection" />
  <action id="Terminal.ClearBuffer" />
  <action id="Terminal.SmartCommandExecution.Run" />
  <action id="Vcs.Log.FocusTextFilter" />
  <action id="ViewSource" />
  <action id="XDebugger.CopyWatch" />
  <action id="openAssertEqualsDiff" />
  <action id="org.intellij.plugins.markdown.ui.actions.styling.ToggleItalicAction" />
  <action id="RenameElement">
    <keyboard-shortcut first-keystroke="shift f6" />
    <keyboard-shortcut first-keystroke="f2" />
  </action>
</keymap>
```

# 设置 Goland 结合 WSL

在 `File | Settings | Go | Build Tags & Vendoring` 中配置使用 SDK 的 OS 信息。（Windows 无法使用 WSL GOROOT 问题）

如果 `go mod tidy` 在 WSL 下安装了库，但仍然无法识别，可用 vendor 模式： `go mod vendor`。（Windows 无法使用 WSL GOPATH 问题）

通过 WSL 内的 Go SDK 构建工程：在 `Go Build` 处可选 `Run on <WSL>`。（在 Goland 编辑器中 Build 工程）

# 设置 VScode

- 快捷键

```json
[
    {
        "key": "ctrl+j",
        "command": "cursorLeft",
        "when": "textInputFocus"
    },
    {
        "key": "ctrl+l",
        "command": "cursorRight",
        "when": "textInputFocus"
    },
    {
        "key": "ctrl+k ctrl+j",
        "command": "-editor.unfoldAll",
        "when": "editorTextFocus && foldingEnabled"
    },
    {
        "key": "ctrl+k ctrl+j",
        "command": "cursorHome",
        "when": "textInputFocus"
    },
    {
        "key": "home",
        "command": "cursorHome",
        "when": "textInputFocus"
    },
    {
        "key": "ctrl+k ctrl+l",
        "command": "cursorEnd",
        "when": "textInputFocus"
    },
    {
        "key": "ctrl+shift+up",
        "command": "editor.action.moveLinesUpAction",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "ctrl+shift+down",
        "command": "editor.action.moveLinesDownAction",
        "when": "editorTextFocus && !editorReadonly"
    },
    {
        "key": "alt+left",
        "command": "workbench.action.navigateBack",
        "when": "canNavigateBack"
    },
    {
        "key": "ctrl+alt+=",
        "command": "workbench.action.navigateForward",
        "when": "canNavigateForward"
    },
    {
        "key": "ctrl+shift+-",
        "command": "-workbench.action.navigateForward",
        "when": "canNavigateForward"
    },
    {
        "key": "alt+right",
        "command": "workbench.action.navigateForward",
        "when": "canNavigateForward"
    },
    {
        "key": "ctrl+[",
        "command": "editor.fold",
        "when": "editorTextFocus && foldingEnabled"
    },
    {
        "key": "ctrl+shift+[",
        "command": "-editor.fold",
        "when": "editorTextFocus && foldingEnabled"
    },
    {
        "key": "ctrl+shift+oem_4",
        "command": "editor.foldAll",
        "when": "editorTextFocus && foldingEnabled"
    },
    {
        "key": "ctrl+k ctrl+0",
        "command": "-editor.foldAll",
        "when": "editorTextFocus && foldingEnabled"
    },
    {
        "key": "ctrl+]",
        "command": "editor.unfold",
        "when": "editorTextFocus && foldingEnabled"
    },
    {
        "key": "ctrl+shift+]",
        "command": "-editor.unfold",
        "when": "editorTextFocus && foldingEnabled"
    },
    {
        "key": "ctrl+shift+]",
        "command": "editor.unfoldAll"
    },
    {
        "key": "ctrl+i",
        "command": "cursorUp",
        "when": "textInputFocus"
    },
    {
        "key": "ctrl+k ctrl+k",
        "command": "cursorDown",
        "when": "textInputFocus"
    },
    {
        "key": "ctrl+shift+u",
        "command": "editor.action.transformToUppercase"
    },
    {
        "key": "ctrl+shift+l",
        "command": "editor.action.transformToLowercase"
    },
    {
        "key": "ctrl+k ctrl+l",
        "command": "-editor.toggleFold",
        "when": "editorTextFocus && foldingEnabled"
    },
    {
        "key": "ctrl+shift+u",
        "command": "-workbench.action.output.toggleOutput",
        "when": "workbench.panel.output.active"
    },
    {
        "key": "ctrl+k ctrl+u",
        "command": "-editor.action.removeCommentLine",
        "when": "editorTextFocus && !editorReadonly"
    }
]
```

# 设置 Sublime

- 快捷键

```json
[
	{ "keys": ["ctrl+j",], "command": "move", "args": {"by": "characters", "forward": false} },
	{ "keys": ["ctrl+l"], "command": "move", "args": {"by": "characters", "forward": true} },
	{ "keys": ["ctrl+i"], "command": "move", "args": {"by": "lines", "forward": false} },
	{ "keys": ["ctrl+k","ctrl+k"], "command": "move", "args": {"by": "lines", "forward": true} },
	{ "keys": ["ctrl+k","ctrl+j"], "command": "move_to", "args": {"to": "bol", "extend": false} },
	{ "keys": ["ctrl+k","ctrl+l"], "command": "move_to", "args": {"to": "eol", "extend": false} },
    { "keys": ["ctrl+b"], "command": "toggle_side_bar" },
]
```

# 注：

## Windows 休眠后 WSL 无法进入

WSL 时常在 Windows 休眠醒来后会有卡住的情况，当前可以通过杀死此进程处理：任务管理器-详细信息-vmwp.exe。它会自动启动起来。

如果重启也不行的话，可以在 启用或关闭 Windows 功能 处 勾选/取消勾选 “适用于 Linux 的 Windows 子系统”（切换就行）然后重启。
