# SRE Skill — 服务器运维工具集

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Linux](https://img.shields.io/badge/Platform-Linux%20%28Ubuntu%7CDebian%7CCentOS%7CRHEL%29-blue.svg)](https://www.linux.org/)
[![macOS](https://img.shields.io/badge/Platform-macOS%20%28Darwin%29-grey.svg)](https://www.apple.com/macos/)

---

## 目录

- [这是什么？](#这是什么)
- [快速开始](#快速开始)
- [前置条件](#前置条件)
- [模块一：服务器监控与巡检](#模块一服务器监控与巡检)
- [模块二：日志分析与故障排查](#模块二日志分析与故障排查)
- [模块三：服务管理](#模块三服务管理)
- [模块四：Docker 与容器管理](#模块四docker-与容器管理)
- [告警阈值参考](#告警阈值参考)
- [常见场景 Playbook](#常见场景-playbook)
- [FAQ](#faq)
- [贡献指南](#贡献指南)
- [协议](#协议)
- [语言](#语言)

---

## 这是什么？

### SRE 是什么？

SRE 的全称是 **Site Reliability Engineering**（站点可靠性工程）。通俗地说，SRE 就是确保你的网站、应用、服务器能够**稳定运行**的一套方法和工具。如果你开了一家 24 小时营业的店，SRE 就是那个确保灯永远亮着、门永远开着、收银机永远不坏的人。

### 这个工具集能做什么？

**sre-skill** 是一个面向初学者的服务器运维工具集，它把日常运维中最常用的操作整理成了四大模块：

| 模块 | 干什么用的 |
|------|-----------|
| 服务器监控与巡检 | 检查服务器的"健康状况"——CPU、内存、磁盘、网络有没有问题 |
| 日志分析与故障排查 | 查"日记"找出服务器出问题的原因 |
| 服务管理 | 管理服务器上运行的各种服务（启动、停止、重启等） |
| Docker 与容器管理 | 管理用 Docker 跑的应用容器 |

简单说：**你的服务器出了问题，用这个工具集就能一步步找到原因并解决。**

---

## 快速开始

下面我们从头开始，一步一步来。假设你刚刚拿到一台 Linux 服务器，什么都还没装。

### 第 1 步：克隆项目

"克隆"就是把代码从 GitHub 下载到你服务器上的过程。

```bash
# 克隆项目到本地（git clone 后面是仓库地址）
git clone git@github.com:dockercore/sre-skill.git

# 进入项目目录
cd sre-skill
```

期望输出类似：

```
Cloning into 'sre-skill'...
remote: Enumerating objects: 42, done.
remote: Counting objects: 100% (42/42), done.
remote: Compressing objects: 100% (35/35), done.
Receiving objects: 100% (42/42), 1.23 MiB | 2.45 MiB/s, done.
Resolving deltas: 100% (12/12), done.
```

### 第 2 步：运行健康巡检

巡检脚本会自动检查你服务器的各项指标，就像体检一样。

```bash
# 给脚本添加可执行权限（chmod +x 表示"让这个文件可以被执行"）
chmod +x scripts/health-check.sh

# 运行快速巡检（只检查最重要的几项）
bash scripts/health-check.sh --quick
```

期望输出示例：

```
=======================================
  SRE Skill - 服务器健康巡检报告
  时间: 2026-04-14 14:30:00
  主机: my-server
=======================================

[CPU] 使用率: 23.5% (4核)  ✅ 正常
[内存] 已用: 3.2G/8.0G (40%)  ✅ 正常
[磁盘] / 分区: 45% 已用  ✅ 正常
[网络] 活跃连接: 128  ✅ 正常
[进程] 僵尸进程: 0  ✅ 正常
[Docker] 运行中容器: 3  ✅ 正常

=======================================
  巡检结果: 全部正常 ✅
=======================================
```

### 第 3 步：查看完整巡检

```bash
# 运行完整巡检（检查所有项目，更详细）
bash scripts/health-check.sh
```

完整巡检会输出更详细的信息，包括每个分区的使用率、Top 进程、网络连接详情等。具体内容我们在"模块一"中详细解释。

---

## 前置条件

大部分 Linux 系统自带了这些工具，你不需要额外安装。但万一缺少某个，下面也告诉你怎么装。

### 必需工具清单

| 工具 | 干什么用的 | 一般自带吗？ | 安装方法 |
|------|-----------|-------------|---------|
| bash | 执行脚本的命令行 | ✅ 自带 | 系统自带 |
| git | 下载代码 | ⚠️ 不一定 | Ubuntu/Debian: `sudo apt install git` / CentOS/RHEL: `sudo yum install git` |
| top/htop | 查看 CPU 和进程 | ✅ 自带 | `sudo apt install htop` 或 `sudo yum install htop` |
| free | 查看内存 | ✅ 自带 | 系统自带 |
| df/du | 查看磁盘 | ✅ 自带 | 系统自带 |
| netstat/ss | 查看网络 | ⚠️ 不一定 | `sudo apt install net-tools` |
| journalctl | 查看系统日志 | ✅ 自带 (systemd 系统) | 系统自带 |
| systemctl | 管理服务 | ✅ 自带 (systemd 系统) | 系统自带 |
| docker | 管理容器 | ❌ 需安装 | 见下方 |

### 安装 Docker

如果你的服务器还没装 Docker，按下面的步骤安装：

```bash
# Ubuntu/Debian 安装 Docker
sudo apt update                        # 更新软件包列表
sudo apt install docker.io -y          # 安装 Docker
sudo systemctl start docker            # 启动 Docker 服务
sudo systemctl enable docker           # 设置开机自启

# CentOS/RHEL 安装 Docker
sudo yum install docker -y             # 安装 Docker
sudo systemctl start docker            # 启动 Docker 服务
sudo systemctl enable docker           # 设置开机自启

# 验证 Docker 是否安装成功
docker --version                       # 查看 Docker 版本
```

期望输出：

```
Docker version 24.0.7, build afdd53b
```

### 安装 Docker Compose

```bash
# 安装 Docker Compose
sudo apt install docker-compose -y     # Ubuntu/Debian
# 或者
sudo yum install docker-compose -y     # CentOS/RHEL

# 验证
docker-compose --version               # 查看版本
```

期望输出：

```
docker-compose version 1.29.2, build 5becea4c
```

---

## 模块一：服务器监控与巡检

这个模块教你如何"体检"你的服务器。就像人需要定期体检一样，服务器也需要定期检查各项指标是否正常。

### 如何运行 health-check.sh

巡检脚本有两种模式：

```bash
# 快速模式 — 只检查最关键的几项，1-2 秒出结果
bash scripts/health-check.sh --quick

# 完整模式 — 检查所有项目，输出详细报告，可能需要 10-30 秒
bash scripts/health-check.sh

# 只检查特定项目
bash scripts/health-check.sh --only cpu,memory,disk
```

### 输出详解

完整巡检报告包含以下部分，我们逐个解释：

---

### CPU 监控

CPU 就是服务器的"大脑"，它负责处理所有计算任务。CPU 使用率越高，说明服务器越忙。

#### 用大白话理解 CPU 指标

| 指标 | 白话解释 |
|------|---------|
| CPU 使用率 | 大脑的忙碌程度。80% 就是 80% 的时间在干活 |
| CPU 核心数 | 大脑有几个"处理器"。4 核 = 可以同时干 4 件事 |
| 负载均值（Load Average） | 排队等大脑处理的任务数量。详见下方 |

#### 负载均值是什么？

负载均值有 3 个数字，比如 `0.5, 1.2, 2.0`，分别代表过去 **1 分钟、5 分钟、15 分钟**内，平均有多少个任务在排队等 CPU 处理。

- 如果你的服务器是 **4 核**的，负载均值 `4.0` 表示刚好满载
- 负载均值 `> 4.0` 表示有任务在排队等着，服务器处理不过来了
- 负载均值 `< 4.0` 表示服务器还有余力

**简单记忆：负载均值除以核心数，超过 1.0 就要注意了。**

#### 查看命令和期望输出

```bash
# 查看 CPU 使用率（top 命令然后按 1 看每个核心）
top -bn1 | head -5                      # 显示 CPU 概况

# 查看 CPU 核心数
nproc                                    # 输出核心数，比如: 4

# 查看负载均值
uptime                                   # 显示运行时间和负载
```

期望输出：

```
# top 输出
top - 14:30:00 up 30 days,  2:15,  1 user,  load average: 0.52, 0.38, 0.29
Tasks: 128 total,   2 running, 126 sleeping,   0 stopped,   0 zombie
%Cpu(s): 23.5 us,  1.2 sy,  0.0 ni, 74.8 id,  0.3 wa,  0.2 hi,  0.0 si

# nproc 输出
4

# uptime 输出
 14:30:00 up 30 days,  2:15, 1 user, load average: 0.52, 0.38, 0.29
```

解读：CPU 使用率 23.5%，4 核心，负载均值 0.52（4 核下远小于 4.0）——非常健康。

---

### 内存监控

内存就是服务器的"工作台"。程序运行时需要把数据放在工作台上，工作台越大，能同时干的事越多。

#### 用大白话理解内存指标

| 指标 | 白话解释 |
|------|---------|
| 已用（used） | 工作台上正在放东西的地方 |
| 空闲（free） | 工作台上完全没放东西的地方 |
| 可用（available） | 真正还能用的空间 = 空闲 + 可以随时腾出来的缓存 |
| 缓存（buff/cache） | 为了加快速度提前准备的东西，需要时可以腾出来 |

**重点：判断内存够不够看"可用（available）"，不要只看"空闲（free）"！** 因为 Linux 会把空闲内存用来做缓存，所以 free 可能很小，但 available 还是够的。

#### 查看命令和期望输出

```bash
# 查看内存使用情况（-h 表示用人类可读的单位，比如 G/M）
free -h                                  # 显示内存概况
```

期望输出：

```
              total        used        free      shared  buff/cache   available
Mem:          7.8Gi       3.2Gi       1.5Gi       256Mi       3.1Gi       4.1Gi
Swap:         2.0Gi          0B       2.0Gi
```

解读：
- 总共 7.8G 内存，已用 3.2G
- 看起来空闲只有 1.5G，但 available 有 4.1G——因为 3.1G 的缓存可以随时腾出来
- **实际可用 = 4.1G，很充裕**

#### 什么是 Swap？

Swap 就是在磁盘上划出一块区域当"备用工作台"。当内存不够用时，系统把暂时不用的数据从内存挪到磁盘的 Swap 里。但磁盘比内存慢很多，所以如果 Swap 用得多，服务器就会变慢。

```bash
# 查看 Swap 使用详情
swapon --show                            # 显示 Swap 设备信息
```

---

### 磁盘监控

磁盘就是服务器的"仓库"，所有文件、数据都存在这里。仓库满了就没法存东西了，程序也会出错。

#### 用大白话理解磁盘指标

| 指标 | 白话解释 |
|------|---------|
| 使用率 | 仓库已经用了多少 |
| Inode 使用率 | 仓库里"货位编号"用了多少。即使仓库还有空间，货位编号用完也存不了东西 |
| 大目录 | 哪些文件夹占的空间最多 |
| I/O | 磁盘的读写速度 |

#### 查看磁盘使用率

```bash
# 查看各分区的磁盘使用率（-h 表示人类可读单位）
df -h                                    # 显示所有分区的使用情况
```

期望输出：

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   22G   26G  46% /
/dev/sda2       200G   80G  120G  40% /data
tmpfs           3.9G     0  3.9G   0% /dev/shm
```

解读：`/` 分区用了 46%，`/data` 分区用了 40%——都正常。

#### 查看 Inode 使用率

```bash
# 查看 Inode 使用率（-i 参数显示 inode 信息）
df -i                                    # 显示 Inode 使用情况
```

期望输出：

```
Filesystem       Inodes   IUsed    IFree IUse% Mounted on
/dev/sda1       3200000  120000  3080000    4% /
/dev/sda2      12800000  500000 12300000    4% /data
```

解读：Inode 使用率只有 4%，远不用担心。

#### 查看大目录

```bash
# 查看根目录下各文件夹占用空间（--max-depth=1 只看第一层）
du -h --max-depth=1 /                    # 显示各目录大小
```

期望输出：

```
1.2G    /var
5.8G    /usr
3.2G    /home
256M    /tmp
12K     /root
22G     /
```

#### 查看磁盘 I/O

```bash
# 查看磁盘 I/O 状况（需要安装 sysstat）
iostat -x 1 3                            # 每秒刷新一次，共刷新 3 次
```

期望输出：

```
Linux 5.15.0-91-generic (my-server)   04/14/2026  _x86_64_ (4 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           5.23    0.00    1.52    0.08    0.00   93.17

Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               0.00     2.50    1.00    5.00     0.01     0.03    16.00     0.02    3.33    2.00    3.60   1.67   1.00
```

解读：`%iowait` 只有 0.08%，`%util` 只有 1%——磁盘完全不忙。

---

### 网络监控

网络就是服务器的"通讯工具"，通过它和外部世界交流。

#### 用大白话理解网络指标

| 指标 | 白话解释 |
|------|---------|
| 监听端口 | 服务器上哪些"窗口"在对外服务（80 = 网页, 22 = SSH） |
| 连接数 | 当前有多少人正在和服务器通讯 |
| 带宽 | 网络通道的宽窄程度，越宽传输越快 |
| Top IP | 哪些 IP 地址访问最多，用于发现异常访问 |

#### 查看监听端口

```bash
# 查看所有正在监听的端口（-t 表示 TCP，-l 表示监听，-n 表示显示数字不用域名）
ss -tlnp                                 # 显示所有 TCP 监听端口
```

期望输出：

```
State    Recv-Q   Send-Q     Local Address:Port    Peer Address:Port   Process
LISTEN   0        128        0.0.0.0:22           0.0.0.0:*
LISTEN   0        128        0.0.0.0:80           0.0.0.0:*
LISTEN   0        128        0.0.0.0:443          0.0.0.0:*
LISTEN   0        511        127.0.0.1:9000       0.0.0.0:*
```

解读：22（SSH）、80（HTTP）、443（HTTPS）端口在监听，9000 只在本机监听——都正常。

#### 查看连接数

```bash
# 查看当前网络连接数
ss -s                                    # 显示连接数摘要
```

期望输出：

```
Total: 256
TCP:   12 (estab 8, closed 2, orphaned 0, timewait 2)
```

解读：共 256 个连接，8 个已建立——正常。

#### 查看带宽使用

```bash
# 查看网络接口流量（需要安装 iftop 或 nload）
# 方法 1：查看网卡统计
cat /proc/net/dev                        # 显示各网卡收发数据量

# 方法 2：用 nload 实时看带宽（需安装）
nload                                    # 实时显示网络流量
```

#### 查看 Top IP

```bash
# 查看当前连接数最多的 IP（netstat 版本）
netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10
# 解释：netstat 输出连接信息 → awk 取第5列（IP:端口）→ cut 去掉端口 → 排序 → 统计 → 按次数倒排 → 取前10
```

期望输出：

```
     28 192.168.1.100
     12 10.0.0.5
      8 172.16.0.50
      3 203.0.113.42
```

解读：192.168.1.100 连接最多（28 个），如果某个不认识的 IP 有几百上千连接，可能是攻击。

---

### 进程监控

进程就是正在运行的程序。就像公司里的员工，有的在干活，有的在摸鱼，有的已经离职但手续没办完（僵尸进程）。

#### 用大白话理解进程指标

| 指标 | 白话解释 |
|------|---------|
| 僵尸进程 | 程序已经死了但"尸体"没被清理，占着编号不干活。少量没事，多了要关注 |
| 文件句柄 | 一个进程同时打开了多少个文件。有上限，超了就打不开了 |
| 资源消耗 Top | 哪些进程最"费钱"（最占 CPU 或内存） |

#### 查看僵尸进程

```bash
# 查看是否有僵尸进程（状态为 Z 的进程就是僵尸）
ps aux | awk '$8 ~ /Z/ {print}'          # 找出所有僵尸进程
```

期望输出：

```
（如果没有僵尸进程，这里什么都没有）
```

如果有僵尸进程，输出类似：

```
user  1234  0.0  0.0   0   0 ?  Z  14:30  0:00 [my-app] <defunct>
```

#### 查看文件句柄

```bash
# 查看系统文件句柄使用情况
cat /proc/sys/fs/file-nr                 # 显示：已分配  未使用  最大值
```

期望输出：

```
1024    0       1048576
```

解读：已分配 1024，最大允许 1048576，使用率不到 0.1%——非常安全。

#### 查看资源消耗 Top

```bash
# 查看 CPU 占用最高的 10 个进程
ps aux --sort=-%cpu | head -11           # 按CPU使用率倒排，取前10

# 查看内存占用最高的 10 个进程
ps aux --sort=-%mem | head -11           # 按内存使用率倒排，取前10
```

期望输出：

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      1001 15.2  2.1 123456 34567 ?        Sl   14:00  10:23 /usr/bin/nginx
mysql     2002  8.5 12.3 456789 98765 ?        Sl   13:00  30:45 /usr/sbin/mysqld
root      3003  2.1  0.5  67890  8765 ?        Ss   12:00   1:23 /usr/sbin/sshd
```

---

## 模块二：日志分析与故障排查

### 什么是日志？为什么重要？

日志就是服务器的"日记本"。服务器每天干了什么、出了什么错，都会记录在日志里。当服务器出了问题，查日志就像看日记一样，能帮你找到原因。

**打个比方**：如果服务器是一个餐厅，日志就是监控录像。菜上慢了？看录像找原因。客人投诉了？看录像回放。

### 系统日志（journalctl）

`journalctl` 是 Linux 系统的"超级日记本"，记录了系统上几乎所有发生的事。

```bash
# 查看所有日志（最近的在最后，太多，一般不看全部）
journalctl                                # 显示所有系统日志

# 查看最近的 50 条日志（-n 50 表示最后 50 条）
journalctl -n 50                          # 显示最近 50 条日志

# 实时跟踪日志（像 tail -f 一样持续显示新日志）
journalctl -f                             # 持续显示新产生的日志，Ctrl+C 退出

# 查看某个服务的日志（比如 nginx）
journalctl -u nginx                       # 显示 nginx 服务相关日志

# 查看今天的日志（--since 指定时间）
journalctl --since today                  # 只显示今天的日志

# 查看最近 1 小时的日志
journalctl --since "1 hour ago"           # 显示最近1小时日志

# 查看某个时间段的日志
journalctl --since "2026-04-14 10:00" --until "2026-04-14 12:00"
# 显示 4月14日 10:00 到 12:00 之间的日志

# 只看错误级别的日志（-p err 表示 error 级别）
journalctl -p err                          # 只显示错误日志

# 查看内核日志（内核是操作系统的核心）
journalctl -k                              # 只显示内核相关日志

# 查看某个进程的日志（用 PID 号）
journalctl _PID=1234                       # 显示 PID 为 1234 的进程日志
```

### 常见日志路径表

除了 journalctl，很多程序有自己的日志文件：

| 路径 | 里面记的是什么 |
|------|--------------|
| `/var/log/syslog` | 系统总日志（Ubuntu/Debian） |
| `/var/log/messages` | 系统总日志（CentOS/RHEL） |
| `/var/log/auth.log` | 登录认证日志（谁登录了、谁登录失败了） |
| `/var/log/nginx/access.log` | Nginx 访问日志（谁访问了你的网站） |
| `/var/log/nginx/error.log` | Nginx 错误日志 |
| `/var/log/mysql/error.log` | MySQL 数据库错误日志 |
| `/var/log/dpkg.log` | 软件安装/卸载日志（Ubuntu/Debian） |
| `/var/log/yum.log` | 软件安装/卸载日志（CentOS/RHEL） |
| `/var/log/cron` | 定时任务执行日志 |
| `/var/log/lastlog` | 所有用户最后登录时间 |
| `/var/log/wtmp` | 所有登录记录 |
| `/var/log/faillog` | 登录失败记录 |

### 如何搜索日志

#### grep — 在文件里找关键词

```bash
# 在日志里搜"error"这个词
grep "error" /var/log/syslog              # 搜索包含 error 的行

# 忽略大小写搜索（-i 参数，Error ERROR error 都能搜到）
grep -i "error" /var/log/syslog           # 忽略大小写搜索 error

# 显示匹配行的行号（-n 参数）
grep -n "error" /var/log/syslog           # 显示行号

# 显示匹配行前后各 2 行（-C 2 参数，方便看上下文）
grep -C 2 "error" /var/log/syslog         # 显示上下文

# 统计匹配到多少行（-c 参数）
grep -c "error" /var/log/syslog           # 只显示匹配行数

# 反向搜索——找不包含某个词的行（-v 参数）
grep -v "debug" /var/log/syslog           # 排除包含 debug 的行

# 在多个文件中搜索
grep "error" /var/log/nginx/*.log         # 搜索所有 Nginx 日志
```

#### awk — 提取和分析日志的列

```bash
# 提取 Nginx 日志的第 1 列（IP 地址）
awk '{print $1}' /var/log/nginx/access.log     # 提取第一列

# 统计每个 IP 出现次数，找出访问最多的 IP
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10
# 解释：提取IP → 排序 → 统计次数 → 按次数倒排 → 取前10
```

期望输出：

```
   1250 192.168.1.100
    890 10.0.0.5
    456 172.16.0.50
    234 203.0.113.42
    123 198.51.100.1
```

### Nginx 日志分析示例

Nginx 是最常用的网页服务器之一，分析它的日志非常有用。

#### 按状态码统计

```bash
# 统计各种 HTTP 状态码出现次数
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn
# 解释：提取第9列（状态码）→ 排序 → 统计 → 按次数倒排
```

期望输出：

```
   8500 200     # 200 = 正常访问
    320 304     # 304 = 缓存命中
    150 404     # 404 = 页面不存在
     30 500     # 500 = 服务器内部错误
     12 502     # 502 = 网关错误
      5 503     # 503 = 服务不可用
```

**状态码解释**：
- `200`：一切正常
- `301/302`：跳转了
- `304`：浏览器缓存还是新的，不用重新传
- `400`：客户端请求有问题
- `401`：没权限，需要登录
- `403`：禁止访问
- `404`：页面不存在
- `500`：服务器内部出错了
- `502`：网关/代理出错了
- `503`：服务器太忙或正在维护

#### 找慢请求

```bash
# 找出响应时间超过 5 秒的请求（假设日志格式包含请求时间）
awk '$NF > 5 {print $0}' /var/log/nginx/access.log | head -20
# 解释：$NF 是最后一列（请求时间），大于 5 秒的打印出来
```

#### 找访问最多的 IP

```bash
# 统计访问最多的 Top 10 IP
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10
```

### 7 步故障排查工作流

当服务器出问题时，按这 7 步走：

#### 第 1 步：确认问题

先搞清楚到底出了什么问题。

```bash
# 问自己几个问题：
# - 什么出了问题？（网页打不开？数据库连不上？）
# - 什么时候开始的？
# - 有没有改过什么配置？
echo "先确认问题现象，不要急于动手"
```

#### 第 2 步：检查系统资源

看看 CPU、内存、磁盘有没有满。

```bash
# 一键查看基本资源
echo "=== CPU ===" && top -bn1 | head -5          # CPU 概况
echo "=== 内存 ===" && free -h                     # 内存概况
echo "=== 磁盘 ===" && df -h                       # 磁盘概况
```

#### 第 3 步：查看最近日志

看看系统日志里有没有错误。

```bash
# 查看最近的错误日志
journalctl -p err -n 50                           # 最近50条错误日志
```

#### 第 4 步：检查服务状态

看看相关服务是否在运行。

```bash
# 检查服务状态（以 nginx 为例）
systemctl status nginx                            # 查看 nginx 状态
```

#### 第 5 步：检查网络

看看网络是否通畅。

```bash
# 检查网络
ping -c 3 8.8.8.8                                # 测试外网是否通（3次）
curl -I http://localhost                          # 测试本机网页是否响应
ss -tlnp                                         # 检查端口是否在监听
```

#### 第 6 步：检查配置

看看最近有没有改过配置文件。

```bash
# 查看最近修改过的配置文件
find /etc -name "*.conf" -mtime -7 -ls            # 7天内修改过的 .conf 文件
```

#### 第 7 步：定位并修复

根据以上线索，找到问题并修复。

```bash
# 常见修复操作
systemctl restart nginx                           # 重启服务
vim /etc/nginx/nginx.conf                         # 修改配置
systemctl reload nginx                            # 重载配置（不中断服务）
```

### 实际故障排查场景

#### 场景 1：服务器变慢了

```bash
# 第 1 步：看 CPU
top -bn1 | head -15                                # 看谁在占 CPU

# 第 2 步：看内存
free -h                                            # 看内存够不够

# 第 3 步：看磁盘 I/O
iostat -x 1 3                                     # 看磁盘忙不忙

# 第 4 步：看是不是 Swap 用多了
free -h | grep Swap                               # Swap 用了多少
```

#### 场景 2：磁盘满了

```bash
# 第 1 步：看哪个分区满了
df -h                                              # 找到 100% 的分区

# 第 2 步：找大文件
du -h --max-depth=1 / | sort -rh | head -10       # 找最大的目录

# 第 3 步：找被删了但还在占空间的文件
lsof +L1                                           # 找被删但未释放的文件

# 第 4 步：清理日志
journalctl --vacuum-size=200M                      # 只保留 200M 日志
```

#### 场景 3：服务挂了

```bash
# 第 1 步：看服务状态
systemctl status nginx                             # 看 nginx 状态

# 第 2 步：看服务日志
journalctl -u nginx -n 50 --no-pager               # 看 nginx 最近日志

# 第 3 步：看配置有没有错
nginx -t                                           # 测试 nginx 配置是否正确

# 第 4 步：重启服务
systemctl restart nginx                            # 重启 nginx
```

#### 场景 4：网络异常

```bash
# 第 1 步：看网络连接数
ss -s                                              # 连接数概况

# 第 2 步：看连接最多的 IP
ss -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10

# 第 3 步：看某个 IP 的连接详情
ss -ntu | grep 192.168.1.100                       # 查看可疑 IP 的连接

# 第 4 步：如果确认是攻击，封 IP
sudo iptables -A INPUT -s 192.168.1.100 -j DROP    # 封掉这个 IP
```

---

## 模块三：服务管理

### 什么是 systemd？

`systemd` 是 Linux 系统的"大管家"。它负责启动和管理系统上的各种服务（程序）。就像小区物业一样，管着水电、电梯、门禁等各种设施。

`systemctl` 是你跟这个大管家沟通的工具——你告诉它"启动 nginx"，它就去启动；你告诉它"重启 mysql"，它就去重启。

### 所有 systemctl 命令及示例

#### 查看服务状态

```bash
# 查看 nginx 服务状态
systemctl status nginx                             # 显示服务是否在运行、PID、最近日志

# 查看所有正在运行的服务
systemctl list-units --type=service --state=running
```

期望输出（systemctl status nginx）：

```
● nginx.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2026-04-14 10:00:00 CST; 4h 30min ago
 Main PID: 1234 (nginx)
    Tasks: 3 (limit: 4915)
   Memory: 5.2M
   CGroup: /system.slice/nginx.service
           ├─1234 "nginx: master process /usr/sbin/nginx"
           └─1235 "nginx: worker process"
```

解读：
- `Loaded: loaded` — 配置文件加载成功
- `Active: active (running)` — 正在运行
- `enabled` — 开机会自动启动

#### 启动服务

```bash
# 启动 nginx（必须用 sudo 因为需要管理员权限）
sudo systemctl start nginx                         # 启动 nginx 服务
```

#### 停止服务

```bash
# 停止 nginx
sudo systemctl stop nginx                          # 停止 nginx 服务
```

#### 重启服务

```bash
# 重启 nginx（先停再启，会短暂中断服务）
sudo systemctl restart nginx                        # 重启 nginx 服务
```

#### 重载服务配置

```bash
# 重载 nginx 配置（不中断服务，平滑加载新配置）
sudo systemctl reload nginx                        # 重载 nginx 配置
```

**restart 和 reload 的区别**：
- `restart` = 把服务关了再开，中间会短暂中断
- `reload` = 让服务重新读取配置文件，不中断（不是所有服务都支持）

#### 设置开机自启

```bash
# 让 nginx 开机自动启动
sudo systemctl enable nginx                        # 设置开机自启

# 取消开机自启
sudo systemctl disable nginx                       # 取消开机自启

# 同时启用并设置开机自启
sudo systemctl enable --now nginx                   # 现在启动 + 开机自启
```

#### 查看服务日志

```bash
# 查看 nginx 的日志
journalctl -u nginx                                # 显示 nginx 所有日志
journalctl -u nginx -n 50                          # 最近 50 条
journalctl -u nginx --since "1 hour ago"           # 最近 1 小时
journalctl -u nginx -f                             # 实时跟踪
```

#### 其他常用命令

```bash
# 查看服务是否开机自启
systemctl is-enabled nginx                         # 输出 enabled 或 disabled

# 查看服务是否正在运行
systemctl is-active nginx                          # 输出 active 或 inactive

# 查看服务依赖关系
systemctl list-dependencies nginx                  # 显示依赖的服务

# 列出所有服务（包括没运行的）
systemctl list-units --type=service --all          # 显示所有服务
```

### 常用服务名对照表

| 服务名 | 中文名 | 干什么用的 |
|--------|-------|-----------|
| nginx | 网页服务器 | 提供网页访问服务 |
| apache2 / httpd | 网页服务器 | 同上（另一个常见网页服务器） |
| mysql / mysqld | 数据库 | 存储和管理数据 |
| postgresql | 数据库 | 同上（另一种数据库） |
| redis | 缓存数据库 | 高速缓存，提升访问速度 |
| docker | 容器服务 | 管理和运行容器 |
| sshd / ssh | 远程登录 | 让你能远程连上服务器 |
| cron | 定时任务 | 按时间自动执行任务 |
| firewalld | 防火墙 | 控制哪些网络请求能进来 |
| ufw | 防火墙 | 同上（Ubuntu 简化版防火墙） |
| systemd-resolved | DNS 解析 | 把域名翻译成 IP |
| rsyslog | 日志服务 | 收集和存储系统日志 |
| networkmanager | 网络管理 | 管理网络连接 |

### 进程管理

除了用 systemctl 管理服务，有时你需要直接管理进程。

#### 查找进程

```bash
# 查找 nginx 相关的进程
ps aux | grep nginx                                # 找到所有 nginx 进程

# 用 pgrep 按名字找进程 PID
pgrep nginx                                        # 输出 nginx 的 PID 号

# 查看进程树（父子关系）
pstree -p | grep nginx                             # 显示 nginx 进程的层级关系
```

#### 终止进程

```bash
# 正常结束进程（发送 SIGTERM 信号，进程可以优雅退出）
kill 1234                                          # 结束 PID 为 1234 的进程

# 强制杀死进程（发送 SIGKILL 信号，进程立刻被杀，没机会收尾）
kill -9 1234                                       # 强制杀死 PID 为 1234 的进程

# 按名字结束进程
killall nginx                                      # 结束所有 nginx 进程

# 用 pkill 按名字结束（支持正则匹配）
pkill -f "nginx: worker"                           # 结束匹配的进程
```

#### SIGTERM 和 SIGKILL 的区别

| 信号 | 编号 | 效果 | 白话解释 |
|------|------|------|---------|
| SIGTERM | 15 | 进程收到后可以清理收尾再退出 | "请你关门"——店员整理好再走 |
| SIGKILL | 9 | 进程立刻被强制杀死，无法收尾 | "立刻关门"——店员被赶走，东西散一地 |

**建议：先尝试 kill（SIGTERM），不行再用 kill -9（SIGKILL）。** 因为 SIGKILL 会导致进程没机会保存数据、释放资源，可能造成数据丢失。

#### 查看进程详情

```bash
# 查看进程的详细信息
top                                                # 实时监控（按 q 退出）
htop                                               # 更好看的实时监控（需安装）

# 查看某个进程的详细信息
cat /proc/1234/status                              # PID 1234 的详细信息

# 查看进程打开了哪些文件
lsof -p 1234                                      # PID 1234 打开的所有文件
```

### 防火墙管理

防火墙就像门口的保安，控制哪些网络请求能进来、哪些不能。

#### UFW（Ubuntu 默认）

```bash
# 查看防火墙状态
sudo ufw status                                    # 显示防火墙是否开启及规则

# 启用防火墙
sudo ufw enable                                    # 开启防火墙

# 关闭防火墙
sudo ufw disable                                   # 关闭防火墙

# 放行端口（允许 80 端口的请求进来）
sudo ufw allow 80                                  # 放行 80 端口（HTTP）
sudo ufw allow 443                                 # 放行 443 端口（HTTPS）
sudo ufw allow 22                                  # 放行 22 端口（SSH）

# 放行特定 IP 访问特定端口
sudo ufw allow from 192.168.1.100 to any port 3306 # 只允许这个 IP 访问 3306

# 删除规则
sudo ufw delete allow 80                           # 删除 80 端口的规则

# 查看规则编号
sudo ufw status numbered                           # 显示带编号的规则列表
```

期望输出（ufw status）：

```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
3306/tcp                   ALLOW       192.168.1.100
22/tcp (v6)                ALLOW       Anywhere (v6)
```

#### firewalld（CentOS/RHEL 默认）

```bash
# 查看防火墙状态
sudo firewall-cmd --state                         # 显示 running 或 not running

# 查看所有开放的端口
sudo firewall-cmd --list-ports                    # 显示所有开放的端口

# 开放端口（--permanent 表示永久生效）
sudo firewall-cmd --permanent --add-port=80/tcp   # 永久开放 80 端口
sudo firewall-cmd --reload                        # 重载防火墙使规则生效

# 关闭端口
sudo firewall-cmd --permanent --remove-port=80/tcp  # 关闭 80 端口
sudo firewall-cmd --reload                        # 重载生效

# 开放服务（按服务名）
sudo firewall-cmd --permanent --add-service=http  # 开放 HTTP 服务
sudo firewall-cmd --reload                        # 重载生效

# 查看所有规则
sudo firewall-cmd --list-all                      # 显示所有防火墙规则
```

期望输出（firewall-cmd --list-all）：

```
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0
  sources:
  services: ssh dhcpv6-client http
  ports: 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

#### iptables（底层防火墙）

```bash
# 查看所有规则
sudo iptables -L -n                               # 显示所有防火墙规则

# 放行某个端口
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT   # 允许 80 端口进入

# 封禁某个 IP
sudo iptables -A INPUT -s 1.2.3.4 -j DROP            # 封禁 IP 1.2.3.4

# 删除规则（先查看行号）
sudo iptables -L INPUT --line-numbers              # 显示规则及行号
sudo iptables -D INPUT 3                           # 删除第 3 条规则

# 保存规则（重启不丢失）
sudo iptables-save > /etc/iptables/rules.v4       # 保存规则到文件
```

---

## 模块四：Docker 与容器管理

### 什么是 Docker？

Docker 是一种"打包和运行应用"的工具。打个比方：

- **传统方式**：你在自己电脑上装了 Python 3.9 + Django + MySQL，程序能跑。但到了服务器上，Python 版本不对、MySQL 没装、少了个依赖库……程序跑不起来。
- **Docker 方式**：你把程序 + 所有依赖 + 配置一起打包成一个"箱子"（镜像），把这个箱子放到任何服务器上都能直接跑，因为所有东西都在箱子里。

**几个关键概念**：
- **镜像（Image）**：打包好的"箱子模板"，是只读的
- **容器（Container）**：用镜像启动的"运行中的箱子"，可以读可以写
- **Dockerfile**：教 Docker 怎么打包的"说明书"
- **Docker Compose**：一次管理多个容器的工具

### 容器生命周期

#### 运行容器（docker run）

```bash
# 运行一个 nginx 容器
# -d: 后台运行（detached）
# --name: 给容器起个名字
# -p: 端口映射（主机端口:容器端口），把主机的 8080 映射到容器的 80
docker run -d --name my-nginx -p 8080:80 nginx:latest
# 解释：用 nginx 最新镜像创建一个叫 my-nginx 的容器，后台运行，访问主机的 8080 端口就是访问容器里的 80 端口
```

期望输出：

```
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
（这是容器的 ID，每个容器都有唯一 ID）
```

#### 启动已存在的容器

```bash
# 启动一个已停止的容器
docker start my-nginx                              # 启动 my-nginx 容器
```

#### 停止容器

```bash
# 停止正在运行的容器
docker stop my-nginx                               # 优雅停止（给 10 秒时间收尾）
```

#### 重启容器

```bash
# 重启容器
docker restart my-nginx                            # 先停后启
```

#### 删除容器

```bash
# 删除一个已停止的容器
docker rm my-nginx                                 # 删除 my-nginx 容器

# 强制删除正在运行的容器
docker rm -f my-nginx                              # 强制删除（即使还在运行）

# 删除所有已停止的容器
docker container prune                             # 清理所有停止的容器
```

#### 查看容器

```bash
# 查看正在运行的容器
docker ps                                          # 列出运行中的容器

# 查看所有容器（包括已停止的）
docker ps -a                                       # 列出所有容器
```

期望输出（docker ps）：

```
CONTAINER ID   IMAGE          COMMAND                  CREATED       STATUS       PORTS                    NAMES
a1b2c3d4e5f6   nginx:latest   "/docker-entrypoint.…"   2 hours ago   Up 2 hours   0.0.0.0:8080->80/tcp     my-nginx
f6g7h8i9j0k1   redis:7        "docker-entrypoint.s…"   3 hours ago   Up 3 hours   0.0.0.0:6379->6379/tcp   my-redis
```

### 容器运维

#### 查看容器日志

```bash
# 查看 my-nginx 容器的日志
docker logs my-nginx                               # 显示所有日志

# 实时跟踪日志
docker logs -f my-nginx                            # 持续显示新日志，Ctrl+C 退出

# 查看最近 50 行日志
docker logs --tail 50 my-nginx                     # 最后 50 行日志

# 查看最近 1 小时的日志
docker logs --since "1h" my-nginx                  # 最近 1 小时的日志
```

#### 进入容器

```bash
# 进入容器内部（像 SSH 登录服务器一样进入容器）
docker exec -it my-nginx /bin/bash                 # 进入 my-nginx 容器，打开 bash
# 进去后可以像操作 Linux 一样操作，输入 exit 退出

# 如果容器没有 bash，用 sh
docker exec -it my-nginx /bin/sh                   # 有些精简镜像没有 bash，用 sh

# 在容器里执行一条命令（不进入容器）
docker exec my-nginx cat /etc/nginx/nginx.conf     # 查看容器里的配置文件
```

#### 容器资源监控

```bash
# 查看容器资源使用情况
docker stats                                       # 实时显示所有容器的 CPU/内存使用
docker stats my-nginx                              # 只看 my-nginx 的资源使用
```

期望输出：

```
CONTAINER ID   NAME       CPU %   MEM USAGE / LIMIT   MEM %   NET I/O           BLOCK I/O         PIDS
a1b2c3d4e5f6   my-nginx   0.02%   5.2MiB / 7.78GiB   0.07%   1.2kB / 0B        0B / 0B           3
f6g7h8i9j0k1   my-redis   0.15%   8.5MiB / 7.78GiB   0.11%   856B / 0B         12MB / 0B         5
```

#### 查看容器详情

```bash
# 查看容器的详细信息（IP 地址、挂载卷、环境变量等）
docker inspect my-nginx                            # 显示详细 JSON 格式信息

# 只看 IP 地址
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' my-nginx
```

#### 查看端口映射

```bash
# 查看 my-nginx 的端口映射
docker port my-nginx                                # 显示端口映射关系
```

期望输出：

```
80/tcp -> 0.0.0.0:8080
```

### 镜像管理

#### 拉取镜像

```bash
# 从 Docker Hub 下载 nginx 镜像
docker pull nginx:latest                            # 下载最新版 nginx 镜像

# 下载特定版本
docker pull nginx:1.25                             # 下载 1.25 版本
```

期望输出：

```
latest: Pulling from library/nginx
a2abf6e4d28e: Pull complete
7cac8d5db1f1: Pull complete
8236b3bb1173: Pull complete
Digest: sha256:abc123...
Status: Downloaded newer image for nginx:latest
docker.io/library/nginx:latest
```

#### 构建镜像

```bash
# 根据当前目录的 Dockerfile 构建镜像
# -t: 给镜像起名字和标签（格式: 名字:标签）
docker build -t my-app:v1 .                         # 构建镜像，名字 my-app，标签 v1
```

#### 查看镜像

```bash
# 查看本地所有镜像
docker images                                      # 列出所有本地镜像
```

期望输出：

```
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
nginx        latest    abc123def456   2 days ago     187MB
redis        7         789ghi012jkl   5 days ago     130MB
my-app       v1        mno345pqr678   1 minute ago   500MB
```

#### 删除镜像

```bash
# 删除一个镜像（必须先删除用这个镜像的容器）
docker rmi nginx:latest                            # 删除 nginx 最新镜像

# 强制删除
docker rmi -f nginx:latest                         # 强制删除（即使有容器在用）
```

#### 清理镜像

```bash
# 删除所有没有用的镜像（没有被任何容器引用的）
docker image prune                                 # 清理无用镜像

# 删除所有镜像（慎用！）
docker image prune -a                              # 清理所有未使用的镜像

# 查看 Docker 占用的磁盘空间
docker system df                                   # 显示 Docker 各部分占用的空间
```

期望输出（docker system df）：

```
TYPE            TOTAL   ACTIVE  SIZE      RECLAIMABLE
Images          5       3       1.2GB     500MB (41%)
Containers      4       3       120MB     30MB (25%)
Local Volumes   2       1       500MB     250MB (50%)
Build Cache     10      0       800MB     800MB (100%)
```

### Docker Compose

Docker Compose 用来一次性管理多个容器。比如你的应用需要 nginx + mysql + redis，用 Compose 可以一条命令全部启动。

#### 启动所有服务

```bash
# 在 docker-compose.yml 所在的目录下执行
docker-compose up -d                               # 后台启动所有服务（-d 表示后台）
```

期望输出：

```
Creating network "myapp_default" with the default driver
Creating myapp_nginx_1 ... done
Creating myapp_mysql_1 ... done
Creating myapp_redis_1 ... done
```

#### 停止所有服务

```bash
# 停止所有服务
docker-compose down                                # 停止并删除所有容器
```

#### 查看服务状态

```bash
# 查看所有服务状态
docker-compose ps                                  # 显示所有服务的运行状态
```

期望输出：

```
      Name                   Command              State          Ports
--------------------------------------------------------------------------------
myapp_mysql_1   docker-entrypoint.sh mysqld   Up (healthy)   3306/tcp
myapp_nginx_1   /docker-entrypoint.sh ngin   Up             0.0.0.0:80->80/tcp
myapp_redis_1   docker-entrypoint.sh redis   Up             6379/tcp
```

#### 查看日志

```bash
# 查看所有服务的日志
docker-compose logs                                # 显示所有服务日志

# 查看某个服务的日志
docker-compose logs nginx                          # 只看 nginx 的日志

# 实时跟踪
docker-compose logs -f nginx                       # 持续显示 nginx 日志
```

#### 扩容

```bash
# 把 nginx 扩展到 3 个实例
docker-compose up -d --scale nginx=3               # 启动 3 个 nginx 容器
```

#### 其他常用命令

```bash
# 重启所有服务
docker-compose restart                             # 重启

# 重启某个服务
docker-compose restart nginx                       # 只重启 nginx

# 停止但不删除容器
docker-compose stop                                # 停止所有服务

# 重新构建镜像
docker-compose build                               # 重新构建所有服务的镜像
docker-compose build nginx                         # 只重新构建 nginx 的镜像
```

### Docker 系统维护

```bash
# 查看 Docker 占用的磁盘空间
docker system df                                   # 显示各部分占用

# 一键清理所有没用的东西（停止的容器、无用镜像、未用网络、构建缓存）
docker system prune                                # 清理无用资源
# 注意：这个命令会问你确认，输入 y 确认

# 更彻底的清理（包括所有未使用的镜像）
docker system prune -a                             # 清理更多（包括未使用的镜像）

# 清理卷（volume）
docker volume prune                                # 清理未使用的卷

# 清理构建缓存
docker builder prune                               # 清理构建缓存
```

**每个清理命令清什么**：

| 命令 | 清理什么 | 会不会影响运行中的容器 |
|------|---------|---------------------|
| `docker system prune` | 停止的容器、无用镜像、未用网络、构建缓存 | ❌ 不会 |
| `docker system prune -a` | 同上 + 所有未被容器使用的镜像 | ❌ 不会 |
| `docker image prune` | 未被任何容器使用的镜像 | ❌ 不会 |
| `docker container prune` | 所有停止的容器 | ❌ 不会 |
| `docker volume prune` | 未被任何容器使用的卷 | ❌ 不会 |
| `docker builder prune` | 构建缓存 | ❌ 不会 |

### Docker 常见故障排查

#### 容器启动后立刻退出

```bash
# 查看容器退出原因
docker logs my-container                           # 看日志找错误信息

# 查看退出码
docker inspect my-container | grep -i exit         # 查看退出码
```

退出码含义：
- `0`：正常退出
- `1`：应用错误
- `137`：被 OOM Killer 杀了（内存不够）
- `139`：段错误（程序 bug）

#### 容器无法连接网络

```bash
# 检查容器网络
docker network ls                                  # 列出所有 Docker 网络
docker network inspect bridge                     # 查看 bridge 网络详情

# 重建网络
docker network create my-network                   # 创建新网络
docker run -d --network=my-network my-nginx        # 使用新网络
```

#### 容器磁盘空间不足

```bash
# 查看 Docker 磁盘使用
docker system df                                   # 显示各部分磁盘使用

# 清理无用资源
docker system prune -a                             # 清理所有无用资源

# 查看 Docker 数据目录大小
du -sh /var/lib/docker                             # 显示 Docker 数据目录大小
```

#### 容器内无法解析域名

```bash
# 进入容器测试 DNS
docker exec -it my-container ping google.com       # 测试是否能解析域名

# 查看 DNS 配置
docker exec -it my-container cat /etc/resolv.conf  # 查看 DNS 配置

# 启动时指定 DNS
docker run -d --dns 8.8.8.8 my-nginx               # 指定 DNS 服务器
```

---

## 告警阈值参考

下面这张表告诉你各个指标在什么范围需要注意、什么范围需要紧急处理。

| 指标 | 正常范围 | ⚠️ 警告 | 🔴 严重 | 白话解释 |
|------|---------|---------|---------|---------|
| CPU 使用率 | < 70% | 70% - 90% | > 90% | 大脑太忙了，处理不过来 |
| 负载均值/核心数 | < 0.7 | 0.7 - 1.0 | > 1.0 | 排队的任务比处理器还多 |
| 内存可用率 | > 30% | 10% - 30% | < 10% | 工作台快放不下了 |
| Swap 使用率 | < 10% | 10% - 30% | > 30% | 备用工作台用多了，说明主工作台不够 |
| 磁盘使用率 | < 70% | 70% - 85% | > 85% | 仓库快满了，需要清理 |
| 磁盘 Inode 使用率 | < 70% | 70% - 85% | > 85% | 货位编号快用完了 |
| 磁盘 I/O await | < 10ms | 10ms - 50ms | > 50ms | 读写等待时间太长 |
| 僵尸进程数 | 0 | 1 - 10 | > 10 | 没清理的"尸体"太多了 |
| 文件句柄使用率 | < 50% | 50% - 80% | > 80% | 打开的文件太多了 |
| 网络连接数 | < 1000 | 1000 - 5000 | > 5000 | 连接太多了，可能有攻击 |

---

## 常见场景 Playbook

这里给你准备了 6 个最常见的故障排查手册，每个都有详细步骤。

### Playbook 1：服务器变慢了

```bash
# 第 1 步：先看看整体资源
top -bn1 | head -15                                # 看谁在占 CPU
free -h                                            # 看内存够不够
df -h                                              # 看磁盘满没满

# 第 2 步：CPU 高？
# 找出最占 CPU 的进程
ps aux --sort=-%cpu | head -11                     # CPU 排行榜

# 第 3 步：内存高？
# 找出最占内存的进程
ps aux --sort=-%mem | head -11                     # 内存排行榜

# 第 4 步：磁盘 I/O 高？
iostat -x 1 3                                     # 看磁盘 I/O
iotop                                              # 看谁在读写磁盘（需安装）

# 第 5 步：Swap 用多了？
free -h | grep Swap                               # 看 Swap 使用量
# 如果 Swap 用得多，说明内存不够

# 第 6 步：根据结果处理
# 如果是某个进程占资源太多，考虑重启它
# 如果是内存不够，考虑加内存或优化程序
# 如果是磁盘 I/O 高，看看是不是在写大日志
```

### Playbook 2：磁盘快满了

```bash
# 第 1 步：看哪个分区快满了
df -h                                              # 找到 Use% 接近 100% 的分区

# 第 2 步：找大目录
du -h --max-depth=1 / | sort -rh | head -10       # 找最大的目录

# 第 3 步：进一步定位
du -h --max-depth=1 /var | sort -rh | head -10    # 如果 /var 大，进一步看

# 第 4 步：常见占用大户
# /var/log — 日志文件
ls -lhS /var/log/ | head -10                      # 找最大的日志文件
# /var/lib/docker — Docker 数据
docker system df                                   # 看 Docker 占了多少

# 第 5 步：清理
# 清理旧日志
journalctl --vacuum-size=200M                      # 日志只保留 200M
# 清理大日志文件（不要直接 rm，用 truncate）
truncate -s 0 /var/log/big-file.log                # 清空日志文件但保留文件

# 清理 Docker
docker system prune -a                             # 清理 Docker 无用资源

# 第 6 步：检查 Inode
df -i                                             # 如果磁盘没用完但 Inode 满了
find / -xdev -type f | cut -d/ -f2 | sort | uniq -c | sort -rn | head
# 找哪个目录文件数最多
```

### Playbook 3：服务挂了

```bash
# 第 1 步：确认服务状态
systemctl status nginx                             # 看服务状态

# 第 2 步：看日志找原因
journalctl -u nginx -n 100 --no-pager             # 看最近 100 条日志

# 第 3 步：看配置有没有错
nginx -t                                           # 测试配置（各服务有各自的检测命令）

# 第 4 步：看端口是否被占用
ss -tlnp | grep :80                                # 看 80 端口被谁占了

# 第 5 步：看相关资源
df -h                                              # 磁盘满没？
free -h                                            # 内存够不够？

# 第 6 步：尝试重启
systemctl restart nginx                            # 重启服务

# 第 7 步：如果重启失败
journalctl -u nginx -n 50 --no-pager               # 再看日志
# 检查配置文件语法
# 检查依赖服务（比如数据库）是否正常
```

### Playbook 4：Docker 容器一直重启

```bash
# 第 1 步：看容器状态
docker ps -a                                       # 看容器状态（注意看 STATUS 列）

# 第 2 步：看容器日志
docker logs my-container --tail 100                # 看最近 100 行日志

# 第 3 步：看退出码
docker inspect my-container | grep -A 5 "State"    # 看退出码和原因

# 第 4 步：常见原因
# 退出码 137 = 内存不足被杀
# 退出码 1 = 应用内部错误
# 退出码 0 = 正常退出但没前台进程

# 第 5 步：如果是内存不足
docker stats                                       # 看容器内存使用
# 增加内存限制
docker update --memory=2g my-container             # 把内存限制调到 2G

# 第 6 步：如果是应用错误
docker logs my-container 2>&1 | grep -i error      # 搜索错误关键词

# 第 7 步：临时进入容器排查
docker run -it --rm --entrypoint /bin/sh my-image  # 用镜像启动一个新的容器进去看
```

### Playbook 5：内存占用过高

```bash
# 第 1 步：看内存总览
free -h                                            # 看整体内存情况

# 第 2 步：找最占内存的进程
ps aux --sort=-%mem | head -11                     # 内存排行榜

# 第 3 步：看进程详情
top -p 1234                                        # 看 PID 1234 的详情

# 第 4 步：看 Swap 使用
cat /proc/swaps                                    # 看 Swap 详情
vmstat 1 5                                         # 看 swap in/out 情况

# 第 5 步：处理
# 如果是某个进程内存泄漏（内存一直涨不释放），考虑重启它
systemctl restart my-service                       # 重启服务释放内存

# 如果是整体内存不够，考虑：
# 1. 增加物理内存
# 2. 优化程序减少内存使用
# 3. 增加 Swap 空间
sudo fallocate -l 4G /swapfile                    # 创建 4G 的 swap 文件
sudo chmod 600 /swapfile                           # 设置权限
sudo mkswap /swapfile                              # 格式化为 swap
sudo swapon /swapfile                              # 启用 swap
```

### Playbook 6：网络连接异常多

```bash
# 第 1 步：看连接数
ss -s                                              # 看连接数摘要

# 第 2 步：看哪些 IP 连接最多
ss -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -20

# 第 3 步：看连接状态分布
ss -ant | awk '{print $1}' | sort | uniq -c | sort -rn
# 解释：统计各种连接状态的连接数
```

期望输出：

```
    1200 ESTAB       # 正在通信
     500 TIME-WAIT   # 等待关闭
      30 CLOSE-WAIT  # 等对方关闭
      10 SYN-RECV    # 收到连接请求
```

```bash
# 第 4 步：如果 TIME-WAIT 太多
# 调整内核参数减少 TIME-WAIT
sudo sysctl -w net.ipv4.tcp_fin_timeout=15         # 缩短等待时间（默认60秒）

# 第 5 步：如果 CLOSE-WAIT 太多
# 说明程序没有正确关闭连接，是代码问题，需要修复

# 第 6 步：如果是恶意 IP
# 封禁 IP
sudo iptables -A INPUT -s 1.2.3.4 -j DROP          # 封禁可疑 IP

# 第 7 步：如果是 DDoS 攻击
# 考虑使用 CDN（如 Cloudflare）或联系云服务商
# 临时措施：限制单个 IP 连接数
sudo iptables -A INPUT -p tcp --syn -m connlimit --connlimit-above 50 -j DROP
# 解释：限制每个 IP 最多 50 个并发连接
```

---

## FAQ

### 1. 我刚买了服务器，第一步该做什么？

1. 用 SSH 连上服务器：`ssh root@你的服务器IP`
2. 更新系统：`sudo apt update && sudo apt upgrade -y`（Ubuntu/Debian）或 `sudo yum update -y`（CentOS/RHEL）
3. 创建一个普通用户（不要一直用 root）：`adduser myuser && usermod -aG sudo myuser`
4. 设置 SSH 密钥登录，禁用密码登录（更安全）
5. 配置防火墙：`sudo ufw enable && sudo ufw allow 22 && sudo ufw allow 80 && sudo ufw allow 443`
6. 运行巡检：`bash scripts/health-check.sh`

### 2. health-check.sh 报权限不够怎么办？

```bash
# 给脚本添加执行权限
chmod +x scripts/health-check.sh                  # 让脚本可以被执行
```

### 3. 我是 macOS 用户，能用这个工具集吗？

可以！大部分命令在 macOS 上也能用，但有些略有不同：
- `free` 命令 macOS 没有，用 `vm_stat` 代替或 `brew install coreutils` 后用 `gfree`
- `ss` 命令 macOS 没有，用 `netstat` 代替
- `systemctl` macOS 没有（macOS 用 `launchctl`）
- 建议先安装 Homebrew：`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

### 4. Docker 容器里时间不对怎么办？

```bash
# 方法 1：运行时映射主机时区
docker run -e TZ=Asia/Shanghai -v /etc/localtime:/etc/localtime:ro my-image

# 方法 2：在 Dockerfile 里设置
# ENV TZ=Asia/Shanghai
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
```

### 5. 怎么查看某个端口被谁占了？

```bash
# 查看 8080 端口被谁占了
sudo lsof -i :8080                                # 显示占用 8080 端口的进程

# 或者用 ss
sudo ss -tlnp | grep :8080                        # 查看 8080 端口
```

### 6. 服务器重启后服务没有自动启动怎么办？

```bash
# 检查服务是否设置了开机自启
systemctl is-enabled nginx                         # 看是否设置了自启

# 设置开机自启
sudo systemctl enable nginx                        # 设置自启
```

### 7. 日志文件太大怎么办？

```bash
# 方法 1：清空日志（保留文件）
truncate -s 0 /var/log/big-file.log               # 清空文件内容

# 方法 2：用 logrotate 自动管理（推荐）
# 大多数系统已经配置了 logrotate，日志会自动轮转

# 方法 3：清理 journal 日志
journalctl --vacuum-size=200M                      # 只保留 200M
journalctl --vacuum-time=7d                        # 只保留 7 天
```

### 8. 如何知道我的服务器是什么系统？

```bash
# 查看系统信息
cat /etc/os-release                                # 显示系统版本信息
uname -a                                           # 显示内核信息
```

期望输出：

```
PRETTY_NAME="Ubuntu 22.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
ID=ubuntu
```

### 9. Docker 删不掉容器怎么办？

```bash
# 先看容器状态
docker ps -a | grep my-container                   # 查看容器状态

# 如果是运行状态，先停
docker stop my-container                           # 停止容器

# 如果停不下来，强制杀
docker kill my-container                           # 强制停止

# 再删除
docker rm my-container                             # 删除容器

# 还是不行？重启 Docker 服务
sudo systemctl restart docker                      # 重启 Docker
```

### 10. 巡检显示 Swap 使用率高怎么办？

Swap 使用率高说明物理内存不够用了：

```bash
# 第 1 步：看内存情况
free -h                                            # 看物理内存和 Swap

# 第 2 步：找最占内存的进程
ps aux --sort=-%mem | head -11                     # 内存排行榜

# 第 3 步：处理
# 如果是某个进程占太多，考虑重启它
# 如果是整体不够，考虑加内存或优化程序

# 临时方案：清除 Swap（会把 Swap 里的数据移回内存，内存要够才行）
sudo swapoff -a && sudo swapon -a                  # 先关再开 Swap，相当于清空
```

### 11. 如何防止服务器被暴力破解 SSH？

```bash
# 方法 1：改 SSH 端口（把默认 22 改成其他）
sudo vim /etc/ssh/sshd_config                      # 编辑 SSH 配置
# 找到 Port 22 改成 Port 2222
sudo systemctl restart sshd                        # 重启 SSH 服务

# 方法 2：禁止 root 直接登录
# 在 /etc/ssh/sshd_config 里设置 PermitRootLogin no

# 方法 3：只允许密钥登录
# 在 /etc/ssh/sshd_config 里设置 PasswordAuthentication no

# 方法 4：安装 fail2ban 自动封禁暴力破解的 IP
sudo apt install fail2ban -y                       # 安装 fail2ban
sudo systemctl enable --now fail2ban               # 启动并设置自启
```

### 12. 巡检报告里某项标红怎么办？

1. 不要慌，先看是哪个指标
2. 对照"告警阈值参考"表，判断严重程度
3. 在"常见场景 Playbook"中找到对应的排查步骤
4. 按步骤排查和处理

---

## 贡献指南

我们欢迎所有人参与贡献！无论你是运维老手还是刚入门的新人，都可以帮忙：

### 如何贡献

1. **Fork 本仓库**：在 GitHub 页面点击右上角 "Fork" 按钮
2. **克隆你的 Fork**：`git clone git@github.com:你的用户名/sre-skill.git`
3. **创建分支**：`git checkout -b my-feature`
4. **修改代码**：做出你的改动
5. **测试**：确保改动没有破坏现有功能
6. **提交**：`git add . && git commit -m "添加了 xxx 功能"`
7. **推送**：`git push origin my-feature`
8. **创建 Pull Request**：在 GitHub 上创建 PR，描述你的改动

### 贡献类型

- 🐛 报告 Bug：在 Issues 里提
- 📝 完善文档：修正错误、补充说明
- 🔧 添加功能：新的检查项、新的分析脚本
- 🌍 翻译：帮助翻译成其他语言
- 💡 提建议：在 Issues 里提新功能建议

### 代码规范

- Shell 脚本使用 `#!/usr/bin/env bash` 开头
- 函数和变量使用小写加下划线命名
- 关键操作添加注释
- 输出使用彩色标注（正常=绿色，警告=黄色，错误=红色）

---

## 协议

本项目基于 [MIT 协议](https://opensource.org/licenses/MIT) 开源。

简单来说：你可以随便用、随便改、随便分发，只要你保留原作者的版权声明就行。

---

## 语言

- [English](README.en.md)
- **中文（当前）**

