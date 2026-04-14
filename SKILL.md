---
name: ops-toolkit
description: 服务器运维工具集 — 监控巡检、日志分析、服务管理、Docker容器管理
version: 1.0.0
category: devops
triggers:
  - 运维
  - 巡检
  - 监控
  - 服务器状态
  - 日志分析
  - 故障排查
  - 服务管理
  - docker管理
  - 容器管理
---

# ops-toolkit — 服务器运维工具集

全面的 Linux 服务器运维 skill，覆盖监控巡检、日志分析、服务管理、Docker 容器管理四大模块。

## 模块一：服务器监控与巡检

### 快速巡检（一键健康检查）

运行内置巡检脚本，自动检查 CPU、内存、磁盘、网络、进程、服务、Docker 状态：

```bash
# 快速模式（默认）—— 适合日常巡检
bash ~/.hermes/skills/devops/ops-toolkit/scripts/health-check.sh --quick

# 完整模式 —— 包含网络接口详情、容器详情等
bash ~/.hermes/skills/devops/ops-toolkit/scripts/health-check.sh --full
```

### CPU 监控

```bash
# 实时 CPU 使用率（采样1秒）
top -bn1 | grep "Cpu(s)" | awk '{print "用户: "$2", 系统: "$4", 空闲: "$8}'

# CPU 核心数
nproc

# 负载均值（1分钟/5分钟/15分钟）
cat /proc/loadavg

# 按核心查看 CPU 使用率
mpstat -P ALL 1 1    # 需要 sysstat 包

# 高 CPU 进程 Top 10
ps aux --sort=-%cpu | head -11
```

### 内存监控

```bash
# 内存使用概览（MB）
free -m

# 内存使用详情
cat /proc/meminfo | head -20

# 内存 Top 10 进程
ps aux --sort=-%mem | head -11

# 持续监控内存（每2秒刷新）
watch -n2 free -m
```

### 磁盘监控

```bash
# 磁盘使用概览
df -hT -x tmpfs -x devtmpfs

# Inode 使用率（文件系统耗尽时即使空间有余也会报错）
df -i -x tmpfs -x devtmpfs

# 大目录 Top 10（指定路径）
du -ah /path 2>/dev/null | sort -rh | head -10

# 挂载详情
findmnt

# 磁盘 I/O 统计
iostat -xz 1 3     # 需要 sysstat 包
```

### 网络监控

```bash
# 监听端口
ss -tlnp

# 网络连接统计
ss -s

# 各状态连接数
ss -ant | awk '{print $1}' | sort | uniq -c | sort -rn

# 网络接口流量
ip -s link show eth0

# 实时带宽监控
iftop -i eth0       # 需要 iftop
nload               # 需要 nload

# 网络连接 Top IP
ss -nt | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10
```

### 进程监控

```bash
# 进程树
ps auxf

# 僵尸进程
ps aux | awk '$8=="Z"'

# 占用文件句柄最多的进程
lsof 2>/dev/null | awk '{print $1}' | sort | uniq -c | sort -rn | head -10

# 系统打开文件句柄总数
cat /proc/sys/fs/file-nr

# 某进程的详细资源占用
pidstat -p <PID> 1 5    # 需要sysstat
```

---

## 模块二：日志分析与故障排查

### 系统日志

```bash
# 查看最近系统日志
journalctl -n 50 --no-pager

# 按时间范围查看
journalctl --since "2024-01-01" --until "2024-01-02"

# 按优先级过滤（0=emerg ... 7=debug）
journalctl -p err -n 50

# 按服务过滤
journalctl -u nginx.service --since "1 hour ago"

# 实时跟踪日志
journalctl -f

# 内核日志
dmesg -T -l err,warn | tail -20
```

### 通用日志搜索

```bash
# 在日志目录中搜索关键词
grep -rn "ERROR" /var/log/ --include="*.log" | tail -20

# 按时间区间搜索（需要日志有时间戳格式）
awk '/2024-01-15 10:00/,/2024-01-15 11:00/' /var/log/app.log

# 统计错误类型分布
grep "ERROR" /var/log/app.log | awk -F'[: ]' '{print $1}' | sort | uniq -c | sort -rn | head -10

# 提取 HTTP 状态码分布（nginx 示例）
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn

# 慢请求（超过5秒的请求）
awk '$NF > 5 {print $0}' /var/log/nginx/access.log | tail -20

# 查找 IP 访问频率（排查异常访问）
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -20
```

### 常见日志路径

| 服务 | 日志路径 |
|------|----------|
| 系统 | `/var/log/syslog` 或 `/var/log/messages` |
| 认证 | `/var/log/auth.log` 或 `/var/log/secure` |
| Nginx | `/var/log/nginx/access.log`, `/var/log/nginx/error.log` |
| MySQL | `/var/log/mysql/error.log` |
| PostgreSQL | `/var/log/postgresql/` |
| Docker | `journalctl -u docker.service` |
| 应用通用 | `/var/log/app/`, `/opt/app/logs/` |

### 故障排查工作流

1. **先看系统层面**: `health-check.sh --full` 获取全局状态
2. **查最近错误**: `journalctl -p err --since "1 hour ago"`
3. **查服务日志**: `journalctl -u <service> --since "30 min ago"`
4. **查资源瓶颈**: `top` / `iotop` / `iftop` 定位 CPU/IO/网络瓶颈
5. **查磁盘空间**: `df -h` 确认未满
6. **查文件句柄**: `cat /proc/sys/fs/file-nr` 和 `lsof | wc -l`
7. **查网络连通**: `curl -v <url>` / `telnet <host> <port>` / `traceroute <host>`

---

## 模块三：服务管理

### systemd 服务操作

```bash
# 查看服务状态
systemctl status <service>

# 启动/停止/重启
systemctl start <service>
systemctl stop <service>
systemctl restart <service>

# 重载配置（不中断服务）
systemctl reload <service>

# 开机自启
systemctl enable <service>
systemctl disable <service>

# 查看所有失败的服务
systemctl --failed

# 查看服务日志
journalctl -u <service> -n 50 --no-pager

# 列出所有活跃服务
systemctl list-units --type=service --state=running

# 查看服务依赖
systemctl list-dependencies <service>
```

### 常用服务名对照

| 应用 | 服务名 |
|------|--------|
| Nginx | `nginx` |
| Apache | `apache2` / `httpd` |
| MySQL | `mysql` / `mysqld` |
| PostgreSQL | `postgresql` |
| Redis | `redis` / `redis-server` |
| Docker | `docker` / `dockerd` |
| SSH | `sshd` |
| Cron | `cron` / `crond` |
| 防火墙 | `ufw` / `firewalld` |

### 进程管理（非 systemd）

```bash
# 查找进程
pgrep -af <keyword>

# 终止进程
kill <PID>
kill -9 <PID>         # 强制终止

# 按名称终止
pkill -f <pattern>
killall <process_name>

# 查看进程占用的端口
ss -tlnp | grep <PID>
```

### 防火墙管理

```bash
# UFW (Ubuntu)
ufw status
ufw allow 80/tcp
ufw deny 3306/tcp

# firewalld (CentOS/RHEL)
firewall-cmd --list-all
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --reload

# iptables
iptables -L -n -v
```

---

## 模块四：Docker / 容器管理

### 容器生命周期

```bash
# 列出容器
docker ps                     # 运行中的
docker ps -a                  # 所有（含停止的）

# 启动/停止/重启
docker start <container>
docker stop <container>
docker restart <container>

# 创建并启动
docker run -d --name myapp -p 8080:80 nginx:latest

# 删除容器
docker rm <container>                    # 停止的
docker rm -f <container>                 # 强制（含运行中的）

# 清理所有停止的容器
docker container prune -f
```

### 容器运维

```bash
# 查看容器日志
docker logs <container>
docker logs --tail 100 -f <container>     # 实时跟踪最近100行
docker logs --since 1h <container>         # 最近1小时

# 进入容器
docker exec -it <container> bash
docker exec -it <container> sh            # 无 bash 时用 sh

# 查看容器资源使用
docker stats                               # 所有容器实时
docker stats <container>                   # 单个容器

# 查看容器详情
docker inspect <container>

# 查看容器进程
docker top <container>

# 容器端口映射
docker port <container>
```

### 镜像管理

```bash
# 列出镜像
docker images

# 拉取镜像
docker pull <image>:<tag>

# 构建镜像
docker build -t myapp:v1 .

# 删除镜像
docker rmi <image>

# 清理悬空镜像
docker image prune -f

# 镜像详情
docker inspect <image>

# 镜像历史（查看构建层）
docker history <image>
```

### Docker Compose

```bash
# 启动服务栈
docker compose up -d

# 停止
docker compose down

# 查看状态
docker compose ps

# 查看日志
docker compose logs -f <service>

# 重启单个服务
docker compose restart <service>

# 拉取最新镜像并重建
docker compose pull
docker compose up -d --build

# 扩容
docker compose up -d --scale <service>=3
```

### Docker 系统维护

```bash
# Docker 磁盘使用
docker system df

# 全面清理（停止容器、悬空镜像、未用网络、构建缓存）
docker system prune -f

# 深度清理（含所有未使用镜像）
docker system prune -a -f

# 清理构建缓存
docker builder prune -f

# 清理卷
docker volume prune -f
```

---

## 告警阈值参考

| 指标 | 警告 | 严重 |
|------|------|------|
| CPU 使用率 | >70% | >90% |
| 内存使用率 | >80% | >90% |
| Swap 使用率 | >30% | >50% |
| 磁盘使用率 | >80% | >90% |
| Inode 使用率 | >80% | >90% |
| 僵尸进程 | >0 | >5 |
| 系统负载(1min) | >核数*0.7 | >核数 |

---

## 注意事项与陷阱

1. **macOS 兼容性**: 巡检脚本已适配 macOS（Darwin），自动检测系统类型使用对应命令。macOS 用 `vm_stat` 替代 `free`、`top -l 1` 替代 `top -bn1`、`lsof` 替代 `ss`、`sysctl` 替代 `/proc` 文件系统。SKILL.md 中的参考命令以 Linux 为主，macOS 用户请注意差异
2. **权限问题**: 部分命令需要 `sudo`（如 `iptables`、`lsof` 查看其他用户进程）
3. **日志轮转**: 大日志文件搜索前先用 `wc -l` 评估行数，避免卡死
4. **Docker 日志膨胀**: 生产环境务必配置 `log-driver` 和 `log-opts` 限制日志大小
5. **`kill -9` 风险**: 强制终止可能导致数据丢失，优先使用 `kill`（SIGTERM）
6. **`docker system prune -a`**: 会删除所有未被容器引用的镜像，执行前确认
7. **容器时区**: Docker 容器默认 UTC 时区，日志时间可能比本地时间少8小时

8. **macOS `/dev` 磁盘 100%**: 这是 devfs 虚拟文件系统的正常状态，不是实际问题，巡检报告中可忽略
