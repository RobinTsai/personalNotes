# 限制命令的资源使用

- [限制命令的资源使用](#限制命令的资源使用)
  - [第三方工具 cpulimit](#第三方工具-cpulimit)
  - [nice 命令](#nice-命令)
  - [taskset](#taskset)
  - [renice](#renice)
  - [ionice](#ionice)
  - [cgroup](#cgroup)
  - [systemd-run](#systemd-run)
  - [schedtool](#schedtool)
  - [systemctl](#systemctl)

> 在线上执行 grep 查询东西，但发现 cpu 使用率太高，怕影响线上业务，所以向 chatGPT 询问，chatGPT 给了多种方案，这里记录，真实使用需要自己尝试。

## 第三方工具 cpulimit

可以使用 cpulimit 工具来限制 grep 命令的 CPU 使用率，以避免 CPU 达到 100%。

以下是使用 cpulimit 工具限制 grep 命令 CPU 使用率的示例命令：

```sh
cpulimit -l 50 grep <pattern> <filename>
```

上述命令会将 grep 命令的 CPU 使用率限制在 50% 以下。其中，<pattern> 是要搜索的字符串模式，<filename> 是要在其中搜索的文件名或路径。

你也可以将 -l 后面的数字更改为其他值，以达到所需的 CPU 使用率限制。

## nice 命令

Unix 系统自带的 nice 命令来限制 grep 命令的 CPU 使用率。

nice 命令只会影响命令的 CPU 时间分配，并不会真正地限制其 CPU 使用率。如果系统负载很高，那么即使使用 nice 命令，grep 命令也可能会占用大量 CPU 资源。

使用方式：

```sh
nice -n 10 grep <pattern> <filename>
```

- `-n` 参数表示设置 `nice` 值。数值越大，表示越 `nice`，表示优先级越低。默认 nice 值是 `10`，可取值范围为 `-20~19`。因此 `19` 是最低优先级。

## taskset

另外一种方法是使用 taskset 命令，将 grep 命令限制在指定的 CPU 核心中运行，从而达到限制其 CPU 使用率的目的。

以下是使用 taskset 命令限制 grep 命令 CPU 使用率的示例命令：

```sh
taskset -c 0-1 grep <pattern> <filename>
```

上述命令中，-c 参数表示将 grep 命令绑定到指定的 CPU 核心中运行。在此示例中，grep 命令被限制为只能在 CPU 核心 0 和 1 中运行，从而限制了其 CPU 使用率。

你也可以将 -c 后面的数字范围更改为其他值，以适应不同的硬件环境和需求。需要注意的是，taskset 命令只能在具有多个 CPU 核心的系统上使用。如果系统只有一个 CPU 核心，那么使用 taskset 命令将无效。

## renice

还有一种方法是使用 renice 命令，降低 grep 进程的优先级，从而限制其 CPU 使用率。

以下是使用 renice 命令限制 grep 命令 CPU 使用率的示例命令：

```sh
renice +10 <pid>
```

上述命令中，+10 表示将进程的优先级增加 10，从而将其降低。<pid> 是要降低优先级的 grep 进程的进程 ID。

需要注意的是，renice 命令只能影响已经运行的进程，并不能防止 grep 进程占用大量 CPU 资源。如果系统负载很高，那么即使使用 renice 命令，grep 进程也可能会占用大量 CPU 资源。因此，为了更好地限制 grep 命令的 CPU 使用率，最好结合多种方法一起使用。


## ionice

除了前面提到的方法，另外一种方法是使用 ionice 命令来限制 grep 命令对磁盘 IO 的访问。这将有助于减少 grep 命令对 CPU 的需求，从而降低其 CPU 使用率。

以下是使用 ionice 命令限制 grep 命令 CPU 使用率的示例命令：

```sh
ionice -c 3 grep <pattern> <filename>
```

上述命令中，-c 参数表示要指定一个 IO 调度类别。在此示例中，我们使用值 3 表示将 grep 命令的 IO 调度类别设置为“idle”，这意味着它只能在空闲时间运行，不会影响其他任务和进程的 IO 操作。

你也可以将 -c 后面的数字更改为其他值，以适应不同的硬件环境和需求。需要注意的是，ionice 命令只能影响对磁盘的 IO 访问，并不能直接限制 grep 命令的 CPU 使用率。但是，通过减少 grep 命令对磁盘 IO 的需求，可以减轻系统负载并限制 grep 命令的 CPU 使用率

## cgroup

还有一种方法是使用 cgroup（控制组）来限制 grep 命令的 CPU 使用率。cgroup 是 Linux 内核提供的一种机制，可以用于限制进程使用系统资源的能力。

以下是使用 cgroup 来限制 grep 命令 CPU 使用率的示例命令：

创建一个名为 limit-grep-cpu 的 cgroup：

```sh
sudo cgcreate -g cpu:limit-grep-cpu
```

将想要执行的 grep 命令加入到 limit-grep-cpu 中：

```sh
echo <pid> | sudo tee /sys/fs/cgroup/cpu/limit-grep-cpu/tasks
```

其中，<pid> 是要限制其 CPU 使用率的 grep 进程的进程 ID。

设置 limit-grep-cpu 的 CPU 时间配额和周期：

```sh
sudo cgset -r cpu.cfs_period_us=50000 limit-grep-cpu
sudo cgset -r cpu.cfs_quota_us=25000 limit-grep-cpu
```

在此示例中，我们将 limit-grep-cpu 的 CPU 时间周期设置为 50000 微秒，CPU 时间配额设置为 25000 微秒，这意味着 grep 进程最多只能使用这个 cgroup 中所分配的 CPU 时间。

需要注意的是，cgroup 需要在 Linux 内核中启用，并且需要具有 root 权限才能创建和使用 cgroup。此外，cgroup 是一种比较高级的技术，需要一定的系统管理经验和知识才能正确地配置和使用。

## systemd-run

除了前面提到的方法，还有一种方法是使用 systemd-run 命令来限制 grep 命令的 CPU 使用率。systemd-run 是 Systemd 系统管理器提供的一个工具，可以用于启动并管理一个系统服务。

以下是使用 systemd-run 命令限制 grep 命令 CPU 使用率的示例命令：

systemd-run -p CPUQuota=50% grep <pattern> <filename>
上述命令中，-p 参数表示要设置一个 Systemd 的属性。在此示例中，我们使用 CPUQuota 属性将 grep 命令的 CPU 使用率限制为 50%。

你也可以将 -p CPUQuota=50% 更改为其他值，以达到所需的 CPU 使用率限制。需要注意的是，Systemd 在几乎所有现代 Linux 发行版中都默认安装，但可能需要一些额外的配置和管理才能正确地使用 systemd-run 命令。

## schedtool

另外一种方法是使用 schedtool 命令来限制 grep 命令的 CPU 使用率。schedtool 是一个工具，可以用于设置 Linux 进程的调度策略和优先级。

以下是使用 schedtool 命令限制 grep 命令 CPU 使用率的示例命令：

schedtool -D -n 19 -e grep <pattern> <filename>
上述命令中，-D 参数表示要将 grep 命令降低为最低优先级。 -n 参数表示要将 grep 命令的实时优先级设置为 19，这是最低的实时优先级，也可以通过此项设置避免 grep 进程占用整个 CPU 的情况。<pattern> 是要搜索的字符串模式，<filename> 是要在其中搜索的文件名或路径。

你也可以将 -n 19 更改为其他值，以达到所需的 CPU 使用率限制。需要注意的是，schedtool 命令可能需要额外的安装和配置才能在某些 Linux 发行版中使用。


## systemctl

另外一种方法是使用 systemctl 命令来限制 grep 命令的 CPU 使用率。systemctl 是 Systemd 系统管理器提供的一个工具，可以用于启动并管理一个系统服务。

以下是使用 systemctl 命令限制 grep 命令 CPU 使用率的示例命令：

1. 创建一个名为 limit-grep-cpu.service 的 systemd 服务：

```sh
sudo tee /etc/systemd/system/limit-grep-cpu.service <<EOF
[Unit]
Description=Limit grep CPU usage

[Service]
CPUQuota=50%
ExecStart=/bin/grep <pattern> <filename>

[Install]
WantedBy=multi-user.target
EOF
```

其中，CPUQuota 表示要将 grep 命令的 CPU 使用率限制为 50%。<pattern> 是要搜索的字符串模式，<filename> 是要在其中搜索的文件名或路径。

2. 重新加载 Systemd 配置并启动 limit-grep-cpu.service 服务：

```sh
sudo systemctl daemon-reload
sudo systemctl start limit-grep-cpu
```

需要注意的是，该方法需要对 Systemd 进行配置和管理，并且需要 root 权限才能创建和管理服务。同时，与其他方法相比，配置和管理 Systemd 服务需要更高的技术水平。
