vs code config

### 方便开发的插件：

- Sublime Text Keymap and Settings Importer
- Go
- JSON tools
- GitLens

### keybindings.json

```js
// Place your key bindings in this file to overwrite the defaults
[
    // 将光标前后两个字符互换
    {
        "key": "ctrl+t",
        "command": "-workbench.action.showAllSymbols"
    },
    {
        "key": "ctrl+t",
        "command": "editor.action.transpose"
    },
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
    }
]
```

### UserSetting.go

```js
{
    // 使用 sublime 的快捷键
    "sublimeTextKeymap.promptV3Features": true,
    // 更改多光标的方式为 alt+click， 这样可以让 Ctrl+Click 为 Go To Defination
    "editor.multiCursorModifier": "alt",
    "editor.snippetSuggestions": "top",
    "editor.formatOnPaste": true,
    "go.lintTool": "gometalinter", // 用 gometalinter 没有多余的波浪线
    // 文件样式
    "editor.unicodeHighlight.allowedLocales": { // 关闭汉字高亮
        "zh-hans": true
    },
    "files.trimTrailingWhitespace": true, // 剔除行末空格
    "files.insertFinalNewline": true,     // 文件末尾加入空行
    "files.trimFinalNewlines": true,      // 文件末尾剔除多个空行
}
```

### 创建 Snippet

- File > Preferences > User Snippets, select the language then create a snippet.

```golang
{
	"fmt.Println": {
		"prefix": "fmt",
		"body": [
            "fmt.Println(\"----------------- ${1:flag}\"$2)"
		],
		"description": "fmt.Println"
	}
}
```
