# 操作 DOM

## 全选/取消全选

```js
// all-scripts 是 全选框 checkbox 的 id
// id 为 scripts-list 的元素下的 input 是所有的子 checkbox
$("#all-scripts").click(function () {
    let isAll = $("#all-scripts")
    $("#scripts-list input").each(function (i, e) {
        $(e).prop("checked", isAll.prop("checked"))
    })
})
```
