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
    {
        "key": "ctrl+t",
        "command": "-workbench.action.showAllSymbols"
    },
    {
        "key": "ctrl+t", // 将光标前后两个字符互换
        "command": "editor.action.transpose"
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
    "go.lintTool": "gometalinter" // 用 gometalinter 没有多余的波浪线
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
