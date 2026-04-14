---
name: ops-toolkit
description: "Server Operations Toolkit — Monitoring, Log Analysis, Service Management, Docker (服务器运维工具集 — 监控巡检、日志分析、服务管理、Docker容器管理)"
version: 2.0.0
category: devops
license: MIT
author: dockercore
triggers:
  - 运维
  - 巡检
  - 监控
  - 服务器状态
  - server health
  - log analysis
  - 日志分析
  - 故障排查
  - troubleshooting
  - 服务管理
  - service management
  - docker管理
  - docker management
  - 容器管理
  - container management
  - sre
---

# ops-toolkit — Server Operations Toolkit / 服务器运维工具集

A comprehensive Linux/macOS server operations skill covering 4 modules: Monitoring, Log Analysis, Service Management, and Docker Management.
全面的 Linux/macOS 服务器运维 skill，覆盖监控巡检、日志分析、服务管理、Docker 容器管理四大模块。

---

## Module 1: Server Monitoring & Health Check / 模块一：服务器监控与巡检

### Quick Health Check / 一键健康检查

Run the built-in health check script to automatically inspect CPU, memory, disk, network, processes, services, and Docker:
运行内置巡检脚本，自动检查 CPU、内存、磁盘、网络、进程、服务、Docker 状态：

```bash
# Quick mode (default) — for daily checks / 快速模式（默认）—— 适合日常巡检
bash ~/.hermes/skills/devops/ops-toolkit/scripts/health-check.sh --quick

# Full mode — includes network interfaces, container details / 完整模式 —— 包含网络接口详情、容器详情等
bash ~/.hermes/skills/devops/ops-toolkit/scripts/health-check.sh --full

# Show help / 显示帮助
bash ~/.hermes/skills/devops/ops-toolkit/scripts/health-check.sh --help
```

**Expected Output / 期望输出：**
```
=========================================
  服务器健康巡检  2026-04-14 14:36:20
  系统: Darwin
=========================================

[系统信息]
  主机名:   zailing
  内核:     25.4.0
  运行时间: up 7 days, 23:51
  当前用户: dockercore

[CPU]
  [OK]   CPU 使用率 51%
  CPU 核心数: 8
  负载均值:   10.75 8.35 7.25

[内存]
  [OK]   内存使用率 8% (1340M/16384M)
  可用内存:   694M
  [WARN] Swap 使用率 95% (6836M/7168M)

[磁盘]
  [OK]   挂载: /  大小: 460Gi  已用: 12Gi  可用: 46Gi  使用率: 21%
  [WARN] 挂载: /System/Volumes/Data  大小: 460Gi  已用: 375Gi  可用: 46Gi  使用率: 89%

[网络]
  [OK]   监听端口数: 20
  端口列表:   80 3306 5000 8080 ...

[进程]
  [OK]   进程总数: 565
  [OK]   无僵尸进程

[Docker]
  [OK]   Docker 守护进程运行中
  运行容器:   5
  镜像数:     12

=========================================
  巡检完成
=========================================
```

**Output Legend / 输出图例：**
- `[OK]` = Normal / 正常
- `[WARN]` = Warning, needs attention / 警告，需要关注
- `[FAIL]` = Critical, must fix immediately / 严重，必须立即处理

### CPU Monitoring / CPU 监控

```bash
# Real-time CPU usage (1-second sample) / 实时 CPU 使用率（采样1秒）
# Linux:
top -bn1 | grep "Cpu(s)" | awk '{print "User: "$2", System: "$4", Idle: "$8}'
# macOS:
top -l 1 -n 0 | grep "CPU usage"

# CPU core count / CPU 核心数
nproc                              # Linux
sysctl -n hw.ncpu                  # macOS

# Load average (1min/5min/15min) / 负载均值（1分钟/5分钟/15分钟）
# Load average = average number of processes waiting for CPU
# 负载均值 = 等待 CPU 的平均进程数
# Rule of thumb: load < core count = healthy
# 经验法则：负载 < 核心数 = 健康
cat /proc/loadavg                  # Linux
sysctl -n vm.loadavg               # macOS

# Per-core CPU usage / 按核心查看 CPU 使用率
mpstat -P ALL 1 1                  # Requires sysstat package / 需要 sysstat 包

# Top 10 CPU-consuming processes / 高 CPU 进程 Top 10
ps aux --sort=-%cpu | head -11     # Linux
ps aux -r | head -11               # macOS
```

**What is Load Average? / 什么是负载均值？**
- The three numbers represent 1-minute, 5-minute, and 15-minute averages
- 三个数字分别代表 1分钟、5分钟和 15分钟的平均值
- If you have 4 cores, load of 4.0 means 100% busy
- 如果你有 4 个核心，负载 4.0 表示 100% 繁忙
- Load > core count = processes are waiting / 负载 > 核心数 = 进程在排队

### Memory Monitoring / 内存监控

```bash
# Memory overview (MB) / 内存使用概览（MB）
free -m                            # Linux
vm_stat                            # macOS (pages, multiply by 4096 for bytes)

# Memory details / 内存使用详情
cat /proc/meminfo | head -20       # Linux
sysctl -n hw.memsize               # macOS: total physical memory

# Top 10 memory-consuming processes / 内存 Top 10 进程
ps aux --sort=-%mem | head -11     # Linux
ps aux -m | head -11               # macOS

# Continuous monitoring (refresh every 2s) / 持续监控内存（每2秒刷新）
watch -n2 free -m                  # Press Ctrl+C to stop / 按 Ctrl+C 停止
```

**Understanding Memory: / 理解内存：**
- `used` = memory currently in use / 当前使用的内存
- `free` = completely unused memory / 完全未使用的内存
- `available` = memory available for new programs (includes cache that can be freed)
- `available` = 可分配给新程序的内存（含可释放的缓存）
- `buffers/cache` = disk cache, automatically freed when needed
- `buffers/cache` = 磁盘缓存，需要时自动释放
- Don't panic if `free` is low — Linux uses free memory for cache
- `free` 很低不要慌 — Linux 会把空闲内存用作缓存

### Disk Monitoring / 磁盘监控

```bash
# Disk usage overview / 磁盘使用概览
df -hT -x tmpfs -x devtmpfs        # Linux
df -h                              # macOS

# Inode usage (filesystem can run out of inodes even with free space)
# Inode 使用率（即使空间有余，Inode 耗尽也会报错）
df -i -x tmpfs -x devtmpfs         # Linux only

# Top 10 largest directories / 大目录 Top 10
du -ah /path 2>/dev/null | sort -rh | head -10

# Mount details / 挂载详情
findmnt                            # Linux
mount                              # macOS

# Disk I/O statistics / 磁盘 I/O 统计
iostat -xz 1 3                     # Requires sysstat / 需要 sysstat 包
```

**What are Inodes? / 什么是 Inode？**
- Every file uses one inode. If you create millions of tiny files, inodes run out before disk space does.
- 每个文件占用一个 inode。如果创建大量小文件，inode 会比空间先耗尽。

### Network Monitoring / 网络监控

```bash
# Listening ports / 监听端口
ss -tlnp                           # Linux
lsof -iTCP -sTCP:LISTEN -P -n      # macOS

# Connection statistics / 网络连接统计
ss -s                              # Linux
netstat -s                         # macOS

# Connections by state / 各状态连接数
ss -ant | awk '{print $1}' | sort | uniq -c | sort -rn

# Network interface traffic / 网络接口流量
ip -s link show eth0               # Linux
netstat -I en0                     # macOS (replace en0 with your interface)

# Real-time bandwidth monitoring / 实时带宽监控
iftop -i eth0                      # Requires iftop
nload                              # Requires nload

# Top IPs by connection count / 连接数 Top IP（排查异常访问）
ss -nt | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10
```

### Process Monitoring / 进程监控

```bash
# Process tree / 进程树
ps auxf                            # Linux
ps aux                             # macOS

# Find zombie processes / 僵尸进程
ps aux | awk '$8=="Z"'

# File handles by process / 占用文件句柄最多的进程
lsof 2>/dev/null | awk '{print $1}' | sort | uniq -c | sort -rn | head -10

# Total open file handles / 系统打开文件句柄总数
cat /proc/sys/fs/file-nr           # Linux only

# Process resource usage / 某进程的详细资源占用
pidstat -p <PID> 1 5              # Linux, requires sysstat
```

---

## Module 2: Log Analysis & Troubleshooting / 模块二：日志分析与故障排查

### System Logs / 系统日志

```bash
# View recent system logs / 查看最近系统日志
journalctl -n 50 --no-pager

# By time range / 按时间范围查看
journalctl --since "2024-01-01" --until "2024-01-02"

# By priority (0=emerg ... 7=debug) / 按优先级过滤
journalctl -p err -n 50            # Show errors only / 只看错误

# By service / 按服务过滤
journalctl -u nginx.service --since "1 hour ago"

# Follow logs in real-time / 实时跟踪日志
journalctl -f                      # Press Ctrl+C to stop / 按 Ctrl+C 停止

# Kernel logs / 内核日志
dmesg -T -l err,warn | tail -20    # Linux only
```

### Log Search / 通用日志搜索

```bash
# Search for keyword in log directory / 在日志目录中搜索关键词
grep -rn "ERROR" /var/log/ --include="*.log" | tail -20

# Search by time range / 按时间区间搜索
awk '/2024-01-15 10:00/,/2024-01-15 11:00/' /var/log/app.log

# Error type distribution / 统计错误类型分布
grep "ERROR" /var/log/app.log | awk -F'[: ]' '{print $1}' | sort | uniq -c | sort -rn | head -10

# HTTP status code distribution (Nginx) / 提取 HTTP 状态码分布
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn

# Slow requests (>5 seconds) / 慢请求（超过5秒的请求）
awk '$NF > 5 {print $0}' /var/log/nginx/access.log | tail -20

# Top IPs by request count / 查找 IP 访问频率（排查异常访问）
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -20
```

### Common Log Paths / 常见日志路径

| Service 服务 | Path 路径 |
|------|----------|
| System 系统 | `/var/log/syslog` or `/var/log/messages` |
| Auth 认证 | `/var/log/auth.log` or `/var/log/secure` |
| Nginx | `/var/log/nginx/access.log`, `/var/log/nginx/error.log` |
| MySQL | `/var/log/mysql/error.log` |
| PostgreSQL | `/var/log/postgresql/` |
| Docker | `journalctl -u docker.service` |
| App 应用 | `/var/log/app/`, `/opt/app/logs/` |

### 7-Step Troubleshooting Workflow / 故障排查工作流

1. **System overview / 系统层面**: `health-check.sh --full` 获取全局状态
2. **Recent errors / 最近错误**: `journalctl -p err --since "1 hour ago"`
3. **Service logs / 服务日志**: `journalctl -u <service> --since "30 min ago"`
4. **Resource bottleneck / 资源瓶颈**: `top` / `iotop` / `iftop` 定位 CPU/IO/网络瓶颈
5. **Disk space / 磁盘空间**: `df -h` 确认未满
6. **File handles / 文件句柄**: `cat /proc/sys/fs/file-nr` and `lsof | wc -l`
7. **Network connectivity / 网络连通**: `curl -v <url>` / `telnet <host> <port>` / `traceroute <host>`

---

## Module 3: Service Management / 模块三：服务管理

### systemd Service Operations / systemd 服务操作

```bash
# Check service status / 查看服务状态
systemctl status <service>
# Example / 示例:
systemctl status nginx

# Start/Stop/Restart / 启动/停止/重启
systemctl start <service>          # Start a stopped service / 启动已停止的服务
systemctl stop <service>           # Stop a running service / 停止运行中的服务
systemctl restart <service>       # Stop then start (brief downtime) / 停止再启动（短暂中断）

# Reload config (no downtime) / 重载配置（不中断服务）
systemctl reload <service>        # Reloads config without stopping / 不停止服务重载配置

# Enable/Disable autostart / 开机自启
systemctl enable <service>        # Start automatically on boot / 开机自动启动
systemctl disable <service>       # Don't start on boot / 开机不启动

# List failed services / 查看所有失败的服务
systemctl --failed

# View service logs / 查看服务日志
journalctl -u <service> -n 50 --no-pager

# List running services / 列出所有活跃服务
systemctl list-units --type=service --state=running

# View service dependencies / 查看服务依赖
systemctl list-dependencies <service>
```

### Common Service Names / 常用服务名对照

| Application 应用 | Service Name 服务名 |
|------|--------|
| Nginx | `nginx` |
| Apache | `apache2` / `httpd` |
| MySQL | `mysql` / `mysqld` |
| PostgreSQL | `postgresql` |
| Redis | `redis` / `redis-server` |
| Docker | `docker` / `dockerd` |
| SSH | `sshd` |
| Cron | `cron` / `crond` |
| Firewall | `ufw` / `firewalld` |

### Process Management / 进程管理（非 systemd）

```bash
# Find process by keyword / 查找进程
pgrep -af <keyword>
# Example / 示例: pgrep -af nginx

# Terminate process / 终止进程
kill <PID>                         # SIGTERM: graceful stop / 优雅终止
kill -9 <PID>                      # SIGKILL: force kill (data loss risk!) / 强制终止（有数据丢失风险！）

# Kill by name / 按名称终止
pkill -f <pattern>
killall <process_name>

# Check which port a process uses / 查看进程占用的端口
ss -tlnp | grep <PID>              # Linux
lsof -i -P -n | grep <PID>        # macOS
```

**SIGTERM vs SIGKILL: / SIGTERM 和 SIGKILL 的区别：**
- `kill` (SIGTERM, signal 15): Asks the process to shut down gracefully. The process can clean up.
- `kill` (SIGTERM, 信号15): 请求进程优雅退出。进程可以清理资源。
- `kill -9` (SIGKILL, signal 9): Immediately kills the process. No cleanup. May cause data corruption.
- `kill -9` (SIGKILL, 信号9): 立即杀死进程。无法清理。可能导致数据损坏。
- **Always try `kill` first. Only use `kill -9` as last resort.**
- **始终先尝试 `kill`。`kill -9` 只作为最后手段。**

### Firewall Management / 防火墙管理

```bash
# UFW (Ubuntu)
ufw status                         # Check status / 查看状态
ufw allow 80/tcp                   # Allow port 80 / 允许端口 80
ufw deny 3306/tcp                  # Deny port 3306 / 拒绝端口 3306

# firewalld (CentOS/RHEL)
firewall-cmd --list-all            # List all rules / 列出所有规则
firewall-cmd --add-port=80/tcp --permanent   # Allow port 80 permanently / 永久允许端口 80
firewall-cmd --reload              # Apply changes / 应用更改

# iptables
iptables -L -n -v                  # List all rules / 列出所有规则
```

---

## Module 4: Docker & Container Management / 模块四：Docker / 容器管理

### Container Lifecycle / 容器生命周期

```bash
# List containers / 列出容器
docker ps                          # Running containers only / 只看运行中的
docker ps -a                       # All containers (including stopped) / 所有（含停止的）

# Start/Stop/Restart / 启动/停止/重启
docker start <container>           # Start a stopped container / 启动停止的容器
docker stop <container>            # Gracefully stop (10s timeout) / 优雅停止（10秒超时）
docker restart <container>         # Stop then start / 停止再启动

# Create and start / 创建并启动
docker run -d --name myapp -p 8080:80 nginx:latest
# -d = detached (background) / 后台运行
# --name = container name / 容器名
# -p 8080:80 = host port 8080 -> container port 80 / 宿主机8080映射到容器80

# Remove container / 删除容器
docker rm <container>              # Remove stopped container / 删除停止的容器
docker rm -f <container>           # Force remove (even if running) / 强制删除（含运行中的）

# Clean up all stopped containers / 清理所有停止的容器
docker container prune -f
```

### Container Operations / 容器运维

```bash
# View container logs / 查看容器日志
docker logs <container>                         # All logs / 所有日志
docker logs --tail 100 -f <container>           # Last 100 lines, follow / 最近100行，实时跟踪
docker logs --since 1h <container>              # Last 1 hour / 最近1小时
docker logs --since "2024-01-15T10:00:00" <container>  # Since specific time / 从指定时间

# Enter container / 进入容器
docker exec -it <container> bash               # Use bash shell / 使用 bash
docker exec -it <container> sh                 # Use sh (if no bash) / 使用 sh（无 bash 时）

# Resource usage / 查看容器资源使用
docker stats                                    # All containers, real-time / 所有容器，实时
docker stats <container>                        # Single container / 单个容器

# Container details / 查看容器详情
docker inspect <container>

# Container processes / 查看容器进程
docker top <container>

# Port mappings / 容器端口映射
docker port <container>
```

### Image Management / 镜像管理

```bash
# List images / 列出镜像
docker images

# Pull image / 拉取镜像
docker pull <image>:<tag>           # Example / 示例: docker pull nginx:1.25

# Build image / 构建镜像
docker build -t myapp:v1 .          # Build from Dockerfile in current directory

# Remove image / 删除镜像
docker rmi <image>

# Clean up dangling images / 清理悬空镜像（无标签的中间镜像）
docker image prune -f

# Image details / 镜像详情
docker inspect <image>

# Image layers / 镜像历史（查看构建层）
docker history <image>
```

### Docker Compose

```bash
# Start stack / 启动服务栈
docker compose up -d                # -d = detached / 后台运行

# Stop / 停止
docker compose down                 # Stop and remove containers / 停止并删除容器
docker compose down -v              # Also remove volumes / 同时删除数据卷

# Status / 查看状态
docker compose ps

# Logs / 查看日志
docker compose logs -f <service>    # Follow logs for a service / 跟踪某个服务的日志

# Restart single service / 重启单个服务
docker compose restart <service>

# Pull latest and rebuild / 拉取最新镜像并重建
docker compose pull
docker compose up -d --build

# Scale / 扩容
docker compose up -d --scale <service>=3   # Run 3 instances / 运行3个实例
```

### Docker System Maintenance / Docker 系统维护

```bash
# Docker disk usage / Docker 磁盘使用
docker system df

# Full cleanup (stopped containers, dangling images, unused networks, build cache)
# 全面清理（停止容器、悬空镜像、未用网络、构建缓存）
docker system prune -f

# Deep cleanup (also removes all unused images)
# 深度清理（含所有未使用镜像）— WARNING: re-download needed next time
# 警告：下次使用需要重新下载
docker system prune -a -f

# Clean build cache / 清理构建缓存
docker builder prune -f

# Clean volumes / 清理卷（WARNING: deletes data! / 警告：会删除数据！）
docker volume prune -f
```

**What each prune removes: / 各清理命令删除什么：**

| Command 命令 | Removes 删除内容 | Risk 风险 |
|------|------|------|
| `docker system prune -f` | Stopped containers, dangling images, unused networks, build cache | Low / 低 |
| `docker system prune -a -f` | Above + all unused images | Medium (need re-pull) / 中（需重新拉取） |
| `docker volume prune -f` | Unused volumes | **HIGH** (data loss!) / **高**（数据丢失！） |
| `docker image prune -f` | Dangling images only | Low / 低 |
| `docker builder prune -f` | Build cache | Low / 低 |

---

## Alert Thresholds Reference / 告警阈值参考

| Metric 指标 | Warning 警告 | Critical 严重 | Explanation 说明 |
|------|------|------|------|
| CPU usage | >70% | >90% | Server may become unresponsive / 服务器可能无响应 |
| Memory usage | >80% | >90% | OOM killer may trigger / 可能触发 OOM 杀进程 |
| Swap usage | >30% | >50% | Excessive swap = slow performance / 大量 Swap = 性能差 |
| Disk usage | >80% | >90% | Risk of write failure / 写入可能失败 |
| Inode usage | >80% | >90% | Cannot create new files / 无法创建新文件 |
| Zombie processes | >0 | >5 | May indicate bugs / 可能存在程序缺陷 |
| Load (1min) | >cores*0.7 | >cores | CPU overloaded / CPU 过载 |

---

## Common Scenarios (Playbook) / 常见场景

### "My server is slow / 服务器变慢了"
```bash
# Step 1: Check CPU / 第1步：检查 CPU
top -bn1 | head -20                # Look for high CPU% / 找高 CPU% 的进程

# Step 2: Check memory / 第2步：检查内存
free -m                            # Is swap being used heavily? / Swap 是否大量使用？

# Step 3: Check disk I/O / 第3步：检查磁盘 I/O
iostat -xz 1 3                     # High %util = disk bottleneck / %util 高 = 磁盘瓶颈

# Step 4: Check load / 第4步：检查负载
cat /proc/loadavg                  # Compare with core count / 对比核心数
```

### "Disk is almost full / 磁盘快满了"
```bash
# Step 1: Which filesystem? / 第1步：哪个分区满了？
df -h

# Step 2: Find large files / 第2步：找大文件
du -ah / 2>/dev/null | sort -rh | head -20

# Step 3: Check inodes / 第3步：检查 inode
df -i

# Step 4: Clean up / 第4步：清理
docker system prune -f             # Clean Docker / 清理 Docker
journalctl --vacuum-size=100M      # Shrink system logs / 缩减系统日志
```

### "A service crashed / 服务挂了"
```bash
# Step 1: Check status / 第1步：查看状态
systemctl status <service>

# Step 2: View logs / 第2步：查看日志
journalctl -u <service> --since "30 min ago"

# Step 3: Restart / 第3步：尝试重启
systemctl restart <service>

# Step 4: Verify / 第4步：验证恢复
systemctl status <service>
curl -s http://localhost:<port>/   # Health check / 健康检查
```

### "Docker container keeps restarting / Docker 容器一直重启"
```bash
# Step 1: Check container status / 第1步：查看容器状态
docker ps -a                       # Look for "Restarting" / 找 "Restarting" 状态

# Step 2: View container logs / 第2步：查看容器日志
docker logs --tail 100 <container>

# Step 3: Inspect restart policy / 第3步：检查重启策略
docker inspect <container> | grep -A5 RestartPolicy

# Step 4: Run interactively to debug / 第4步：交互运行调试
docker run -it --rm <image> sh     # Run once, don't auto-restart / 运行一次，不自动重启
```

### "High memory usage / 内存占用过高"
```bash
# Step 1: Top memory processes / 第1步：找内存大户
ps aux --sort=-%mem | head -11

# Step 2: Check if swap is abused / 第2步：检查 Swap 是否被滥用
free -m

# Step 3: Check for memory leaks / 第3步：检查是否有内存泄漏
pidstat -r -p <PID> 1 10          # Watch RSS growth / 观察 RSS 增长
```

### "Too many network connections / 网络连接异常多"
```bash
# Step 1: Connection count by state / 第1步：按状态统计连接数
ss -ant | awk '{print $1}' | sort | uniq -c | sort -rn

# Step 2: Top IPs by connections / 第2步：连接数最多的 IP
ss -nt | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -20

# Step 3: Check if a port is flooded / 第3步：检查某端口是否被淹没
ss -tn | grep :80 | wc -l

# Step 4: Block abusive IPs / 第4步：封禁恶意 IP
iptables -A INPUT -s <bad_ip> -j DROP
```

---

## Notes & Pitfalls / 注意事项与陷阱

1. **macOS compatibility / macOS 兼容性**: The health-check.sh script auto-detects OS and uses appropriate commands. SKILL.md reference commands are primarily Linux-based. macOS differences: no `systemctl`, no `journalctl`, no `free`, no `/proc` filesystem. macOS uses `vm_stat`, `top -l 1`, `lsof`, `sysctl` instead.
2. **Permissions / 权限问题**: Some commands need `sudo` (e.g., `iptables`, `lsof` for other users' processes, Docker for non-docker group users).
3. **Log rotation / 日志轮转**: Before searching large log files, check size with `wc -l` to avoid hanging.
4. **Docker log bloat / Docker 日志膨胀**: Always configure `log-driver` and `log-opts` in production to limit log size. Add to `/etc/docker/daemon.json`: `{"log-driver": "json-file", "log-opts": {"max-size": "10m", "max-file": "3"}}`.
5. **`kill -9` risk / `kill -9` 风险**: Force kill may cause data loss. Always prefer `kill` (SIGTERM) first.
6. **`docker system prune -a` / 深度清理风险**: Removes ALL unused images. Next deploy will need to re-pull. Confirm before running.
7. **Container timezone / 容器时区**: Docker containers default to UTC. Logs may be 8 hours behind local time. Set timezone with `-e TZ=Asia/Shanghai` or mount `/etc/localtime`.
8. **macOS `/dev` disk 100%**: This is normal for devfs virtual filesystem, not an actual problem. Can be safely ignored in health check reports.

---

## Documentation / 文档

- [English README](README.md)
- [中文文档](README.zh-CN.md)
- [MIT License](LICENSE)
