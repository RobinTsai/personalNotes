# uv

目录：

- `.python-version`: 记录 python 版本信息
- `pyproject.toml`: 工程配置文件

```sh
uv python list                 # 列出版本
uv python install cpython-3.12 # 下载对应版本
uv run -p 3.12 abc.py          # 使用对应版本运营 abc.py

uv init -p 3.12       # 创建 uv 工程，会自动创建一系列文件
uv add PACKAGE_NAME   # 安装库文件（同时会创建一个虚拟环境 .venv，目录下 bin/phthon 是解释器）
nv tree               # 打印工程依赖树
nv run SCRIPT

uv tool install PACKAGE # 安装库到系统中
uv tool list            # 查看系统工具

uv  build # 打包工程未 .whl 文件。后续可以发布到 python 软件库中了
```
