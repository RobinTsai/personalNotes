# for

## 基本用法

```py
items = ['a']
for item in items:
    print(item) # a


dict = {'a': 'A'}
for key in dict:
    print(key, dict[key]) # a A

# for + 列表推导式
for a in [attr for attr in dir(self) if attr.startswith("dialog_")]:
    print(a)

# 字典推导式
{x: x * x for x in range(10) if x % 3 == 0}

# 集合推导式
{x for x in range(10) if x % 3 == 0}

# 列表转集合（不需要过滤）
set(list1)
```
