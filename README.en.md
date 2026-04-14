# SRE Skill — Server Operations Toolkit

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![OS: Linux](https://img.shields.io/badge/OS-Linux%20%7C%20macOS-green.svg)](https://www.linux.org/)
[![Platform: Ubuntu/Debian/CentOS/RHEL/macOS](https://img.shields.io/badge/Platform-Ubuntu%20%7C%20Debian%20%7C%20CentOS%20%7C%20RHEL%20%7C%20macOS-lightgrey.svg)]()

A comprehensive, beginner-friendly server operations toolkit covering **monitoring**, **log analysis**, **service management**, and **Docker/container management**. Designed for anyone — from first-day Linux users to seasoned sysadmins.

---

## Table of Contents

1. [What is This?](#what-is-this)
2. [Quick Start](#quick-start)
3. [Prerequisites](#prerequisites)
4. [Module 1: Server Monitoring & Health Check](#module-1-server-monitoring--health-check)
5. [Module 2: Log Analysis & Troubleshooting](#module-2-log-analysis--troubleshooting)
6. [Module 3: Service Management](#module-3-service-management)
7. [Module 4: Docker & Container Management](#module-4-docker--container-management)
8. [Alert Thresholds Reference](#alert-thresholds-reference)
9. [Common Scenarios (Playbook)](#common-scenarios-playbook)
10. [FAQ](#faq)
11. [Contributing](#contributing)
12. [License](#license)
13. [Language / 语言](#language--语言)

---

## What is This?

**SRE** stands for **Site Reliability Engineering**. It is a discipline that applies software engineering principles to infrastructure and operations problems. In plain English: SRE is about keeping your servers running smoothly, finding problems before they cause outages, and fixing them quickly when they do break.

This toolkit — **sre-skill** — gives you a single place to learn and run every common server operations task. It includes:

- A **one-command health check script** that scans your entire server in seconds
- **Monitoring commands** for CPU, memory, disk, network, and processes
- **Log analysis techniques** to find out what went wrong and why
- **Service management** tools to start, stop, and configure services
- **Docker/container management** to run and maintain containerized applications

**Who is this for?** Anyone with a Linux server. Whether you just got your first VPS or you have been running production servers for years, this toolkit has something for you.

**What systems does it support?** Linux (Ubuntu, Debian, CentOS, RHEL) and macOS (Darwin). The health check script automatically detects your operating system and uses the right commands for each platform.

---

## Quick Start

Follow these steps to get up and running in under 2 minutes. Every step includes the exact command to type and what you should see.

### Step 1: Clone the Repository

"Cloning" means downloading a copy of the project code to your computer. You need `git` installed (it usually is on most Linux servers).

```bash
# Clone the project from GitHub to your machine
git clone git@github.com:dockercore/sre-skill.git

# Enter the project directory
cd sre-skill
```

**Expected output:**

```
Cloning into 'sre-skill'...
remote: Enumerating objects: 30, done.
remote: Counting objects: 100% (30/30), done.
remote: Compressing objects: 100% (20/20), done.
remote: Total 30 (delta 10), reused 24 (delta 8), pack-reused 0
Receiving objects: 100% (30/30), 12.45 KiB | 2.07 MiB/s, done.
Resolving deltas: 100% (10/10), done.
```

### Step 2: Run the Health Check (Quick Mode)

The quick mode gives you a fast overview of your server health. It checks CPU, memory, disk, network, processes, and Docker in just a few seconds.

```bash
# Run the health check script in quick mode (default)
bash scripts/health-check.sh --quick
```

**Expected output (example on a healthy Linux server):**

```
=========================================
  Server Health Check  2026-04-14 14:30:00
  System: Linux
=========================================

[System Info]
  Hostname:   my-server
  Kernel:     5.15.0-91-generic
  Uptime:     up 42 days
  Current User: root

[CPU]
  [OK]   CPU Usage 23%
  CPU Cores: 4
  Load Average: 0.45 0.38 0.42

[Memory]
  [OK]   Memory Usage 45% (1800M/4096M)
  Available: 2100M
  [OK]   Swap Usage 2% (48M/2048M)

[Disk]
  [OK]   Mount: /  Size: 50G  Used: 20G  Avail: 28G  Usage: 42%
  [OK]   Mount: /home  Size: 100G  Used: 35G  Avail: 60G  Usage: 36%

[Network]
  [OK]   Listening Ports: 5
  Port List: 22 80 443 3306 8080
  ESTABLISHED: 28

[Process]
  [OK]   Total Processes: 127
  [OK]   No zombie processes

[Top 5 CPU Processes]
  nginx        root       2.3%  1.1%
  mysqld       mysql      1.8%  4.2%
  node         appuser    1.2%  3.5%
  python3      appuser    0.9%  2.8%
  sshd         root       0.1%  0.2%

[Top 5 Memory Processes]
  mysqld       mysql      1.8%  4.2%
  node         appuser    1.2%  3.5%
  python3      appuser    0.9%  2.8%
  nginx        root       2.3%  1.1%
  systemd      root       0.0%  0.8%

[Failed Services]
  [OK]   No failed services

[Docker]
  [OK]   Docker daemon is running
  Running Containers: 3
  Stopped Containers: 1
  Images: 7

=========================================
  Check Complete
=========================================
```

### Step 3: Run the Full Health Check

Full mode adds extra detail: network interface information and Docker container details.

```bash
# Run the full health check with extended information
bash scripts/health-check.sh --full
```

In full mode, you will see additional sections like:

```
[Network Interfaces]
  lo               UNKNOWN        127.0.0.1/8
  eth0             UP             192.168.1.100/24

  [Container Details]
  NAMES           STATUS              PORTS
  myapp           Up 3 hours          0.0.0.0:8080->80/tcp
  redis           Up 3 hours          0.0.0.0:6379->6379/tcp
  db              Up 3 hours          0.0.0.0:3306->3306/tcp
```

**Understanding the output symbols:**

| Symbol | Meaning | What to do |
|--------|---------|------------|
| `[OK]` | Everything looks normal | No action needed |
| `[WARN]` | Approaching a problem threshold | Investigate soon |
| `[FAIL]` | Critical problem detected | Fix immediately |

---

## Prerequisites

Most of the tools used by this toolkit come pre-installed on Linux servers. Here is what you need and how to install anything missing.

### Essential Tools (Usually Pre-installed)

| Tool | Purpose | How to Install if Missing |
|------|---------|---------------------------|
| `bash` | Runs the health check script | Pre-installed on virtually all Linux/macOS |
| `top` | CPU monitoring | Pre-installed |
| `free` | Memory monitoring (Linux) | Pre-installed on Linux |
| `df` | Disk usage | Pre-installed |
| `ps` | Process listing | Pre-installed |
| `ss` | Network socket stats (Linux) | Pre-installed on modern Linux |
| `grep` | Search text in files | Pre-installed |
| `awk` | Process text data | Pre-installed |
| `curl` | Test network connectivity | Pre-installed on most systems |

### Optional but Recommended Tools

| Tool | Purpose | Install Command (Ubuntu/Debian) | Install Command (CentOS/RHEL) |
|------|---------|--------------------------------|-------------------------------|
| `sysstat` | CPU/memory I/O stats (`mpstat`, `iostat`, `pidstat`) | `sudo apt install sysstat` | `sudo yum install sysstat` |
| `iftop` | Real-time bandwidth monitoring | `sudo apt install iftop` | `sudo yum install iftop` |
| `nload` | Network traffic visualization | `sudo apt install nload` | `sudo yum install nload` |
| `iotop` | Disk I/O monitoring | `sudo apt install iotop` | `sudo yum install iotop` |
| `lsof` | List open files and ports | `sudo apt install lsof` | `sudo yum install lsof` |
| `docker` | Container management | See [official docs](https://docs.docker.com/engine/install/) | See [official docs](https://docs.docker.com/engine/install/) |
| `docker compose` | Multi-container apps | Included with Docker Desktop / Docker plugin | Included with Docker plugin |

### macOS Notes

On macOS, the toolkit uses different commands automatically:
- `vm_stat` instead of `free` (memory stats)
- `top -l 1` instead of `top -bn1` (CPU snapshot)
- `lsof` instead of `ss` (network ports)
- `sysctl` instead of `/proc` filesystem (system info)

Install missing macOS tools with Homebrew:

```bash
# Install Homebrew first if you do not have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install useful tools
brew install sysstat    # for iostat
brew install iftop      # for bandwidth monitoring
```

> **Note:** On macOS, you may see `/dev` showing 100% disk usage. This is the devfs virtual filesystem and is completely normal — it does NOT mean your disk is full. You can safely ignore it.

---

## Module 1: Server Monitoring & Health Check

This module teaches you how to monitor every aspect of your server. You will learn what each metric means, how to check it, and what values are healthy versus dangerous.

### Running the Health Check Script

The health check script (`scripts/health-check.sh`) is your one-command server dashboard. It checks everything automatically.

```bash
# Quick mode — fast overview, ideal for daily checks
bash scripts/health-check.sh --quick

# Full mode — includes network interfaces and Docker container details
bash scripts/health-check.sh --full

# Default (no argument) is the same as --quick
bash scripts/health-check.sh
```

### Understanding the Health Check Output — Section by Section

#### System Info Section

```
[System Info]
  Hostname:   my-server
  Kernel:     5.15.0-91-generic
  Uptime:     up 42 days
  Current User: root
```

- **Hostname**: The name of your server on the network. Useful when you manage multiple servers.
- **Kernel**: The version of the Linux kernel. Important for security patches — keep this updated.
- **Uptime**: How long the server has been running since the last reboot. A very long uptime (hundreds of days) can mean you have not applied kernel security updates (which require a reboot).
- **Current User**: The user account running the check. `root` means full admin privileges.

#### CPU Section

```
[CPU]
  [OK]   CPU Usage 23%
  CPU Cores: 4
  Load Average: 0.45 0.38 0.42
```

- **CPU Usage**: The percentage of time the CPU is busy doing work (not idle). 23% means the CPU is working about a quarter of the time.
- **CPU Cores**: The number of processing units. More cores means the server can handle more simultaneous work.
- **Load Average**: Three numbers showing the average number of processes waiting to use the CPU over the last 1 minute, 5 minutes, and 15 minutes.

**What is Load Average?** Think of it like a line at a store. If you have 4 cashiers (cores) and the load average is 4.0, every cashier is busy but no one is waiting. If the load average is 8.0, every cashier is busy AND there are 4 people waiting in line. A load average higher than your core count means the CPU is overwhelmed.

| Load Average vs Cores | Meaning |
|----------------------|---------|
| Load < Core count | Server is healthy, plenty of CPU capacity |
| Load = Core count | Server is fully utilized, still OK |
| Load > Core count | Server is overloaded, tasks are waiting |

#### Memory Section

```
[Memory]
  [OK]   Memory Usage 45% (1800M/4096M)
  Available: 2100M
  [OK]   Swap Usage 2% (48M/2048M)
```

- **Memory Usage**: How much RAM is being used. 1800M out of 4096M total means the server is using about 1.8 GB out of 4 GB.
- **Available**: Memory that can be used immediately by applications. This includes truly free memory PLUS memory used for caches that can be freed instantly.
- **Swap Usage**: Swap is disk space used as overflow when RAM is full. Using swap is much slower than RAM. High swap usage means your server needs more RAM.

**Understanding "Used" vs "Free" vs "Available" Memory on Linux:**

Linux uses spare RAM to cache disk data (making your system faster). This can make it look like memory is almost full when it is actually fine. The key number is **available** memory — this is what your applications can actually use.

| Term | What it means |
|------|--------------|
| **Used** | Memory actively used by applications |
| **Free** | Memory not being used for anything (usually very low on a healthy Linux system) |
| **Available** | Memory that can be given to apps immediately = Free + reclaimable cache |
| **Buffers** | Memory holding disk block data temporarily |
| **Cache** | Memory holding file contents to speed up future reads |
| **Swap** | Disk space used when RAM was full (slow!) |

#### Disk Section

```
[Disk]
  [OK]   Mount: /  Size: 50G  Used: 20G  Avail: 28G  Usage: 42%
  [WARN] Mount: /data  Size: 100G  Used: 83G  Avail: 12G  Usage: 85%
```

- **Mount**: The directory where this disk partition is attached (e.g., `/` is the root, `/data` is a separate data partition).
- **Size**: Total capacity of the disk partition.
- **Used/Avail**: How much is used and how much is free.
- **Usage**: Percentage used. Above 80% triggers a warning; above 90% is critical.

#### Network Section

```
[Network]
  [OK]   Listening Ports: 5
  Port List: 22 80 443 3306 8080
  ESTABLISHED: 28
```

- **Listening Ports**: Services waiting for incoming connections. Common ports: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3306 (MySQL), 8080 (alternative HTTP).
- **ESTABLISHED**: Currently active connections. A very high number could mean a traffic spike or an attack.

#### Process Section

```
[Process]
  [OK]   Total Processes: 127
  [OK]   No zombie processes

[Top 5 CPU Processes]
  nginx        root       2.3%  1.1%
  mysqld       mysql      1.8%  4.2%
```

- **Total Processes**: How many programs are running. A typical server has 100-300.
- **Zombie Processes**: Programs that have finished but their parent has not cleaned them up. They use no resources but a large number indicates a bug. Any zombie > 0 is a warning.
- **Top 5 CPU/Memory Processes**: The biggest resource consumers, helping you quickly identify what is eating up your server.

#### Docker Section

```
[Docker]
  [OK]   Docker daemon is running
  Running Containers: 3
  Stopped Containers: 1
  Images: 7
```

- **Docker daemon is running**: The Docker background service is active and ready.
- **Running/Stopped Containers**: How many app containers are active vs. stopped.
- **Images**: The number of container images stored on disk. Unused images waste disk space.

### Individual Monitoring Commands

Below are all the individual commands you can run to check specific parts of your server, with detailed explanations.

#### CPU Monitoring

**Check current CPU usage:**

```bash
# Show CPU usage percentages (user, system, idle)
# "user" = time spent running application code
# "system" = time spent running kernel code
# "idle" = time the CPU was doing nothing
top -bn1 | grep "Cpu(s)" | awk '{print "User: "$2", System: "$4", Idle: "$8}'
```

**Expected output:**

```
User: 5.2, System: 2.1, Idle: 92.7
```

**Check CPU core count:**

```bash
# Display the number of CPU cores available
# This tells you how many simultaneous tasks the server can handle
nproc
```

**Expected output:**

```
4
```

**Check load average:**

```bash
# Display the 1-minute, 5-minute, and 15-minute load averages
# Three numbers: short-term, medium-term, long-term system load
cat /proc/loadavg
```

**Expected output:**

```
0.45 0.38 0.42 2/287 12345
```

The first three numbers (0.45, 0.38, 0.42) are the load averages. Compare them to your core count (from `nproc`). If load is consistently above your core count, the server is overloaded.

**Per-core CPU usage:**

```bash
# Show CPU usage for each individual core
# Requires the sysstat package: sudo apt install sysstat
# The "1 1" means: sample every 1 second, do 1 sample
mpstat -P ALL 1 1
```

**Expected output:**

```
Linux 5.15.0-91-generic (my-server)   04/14/2026  _x86_64_  (4 CPU)

02:40:01 PM  CPU    %usr   %nice    %sys   %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
02:40:02 PM  all   5.25    0.00    2.10      0.25    0.00    0.10    0.00    0.00    0.00   92.30
02:40:02 PM    0   8.00    0.00    3.00      0.00    0.00    0.50    0.00    0.00    0.00   88.50
02:40:02 PM    1   4.00    0.00    1.50      0.50    0.00    0.00    0.00    0.00    0.00   94.00
02:40:02 PM    2   6.00    0.00    2.00      0.00    0.00    0.00    0.00    0.00    0.00   92.00
02:40:02 PM    3   3.00    0.00    2.00      0.50    0.00    0.00    0.00    0.00    0.00   94.50
```

**Top 10 CPU-consuming processes:**

```bash
# List the top 10 processes sorted by CPU usage (highest first)
# Shows: user, PID, CPU%, MEM%, command
ps aux --sort=-%cpu | head -11
```

**Expected output:**

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      1234  8.5  2.1 123456 51200 ?        Ss   10:00   3:45 nginx: master process
mysql     2345  5.2  8.3 987654 204800 ?       Sl   10:01   2:30 /usr/sbin/mysqld
appuser   3456  3.1  5.5 567890 135168 ?       Sl   10:05   1:20 node app.js
```

#### Memory Monitoring

**Memory overview (in megabytes):**

```bash
# Display memory usage in megabytes
# "total" = all RAM installed
# "used" = RAM currently in use by applications
# "free" = completely unused RAM (often low on Linux because Linux uses spare RAM for cache)
# "available" = RAM that can be given to apps right now (this is the important number!)
free -m
```

**Expected output:**

```
              total        used        free      shared  buff/cache   available
Mem:           4096        1800         200         128        2096        2100
Swap:          2048          48        2000
```

**Detailed memory info:**

```bash
# Show the first 20 lines of detailed memory statistics from the kernel
# This includes things like buffer sizes, cache sizes, slab memory, etc.
cat /proc/meminfo | head -20
```

**Expected output:**

```
MemTotal:         4194304 kB
MemFree:           204800 kB
MemAvailable:     2150400 kB
Buffers:           102400 kB
Cached:           1996800 kB
SwapCached:          4096 kB
Active:           1800000 kB
Inactive:         1600000 kB
...
```

**Top 10 memory-consuming processes:**

```bash
# List the top 10 processes sorted by memory usage (highest first)
ps aux --sort=-%mem | head -11
```

**Expected output:**

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
mysql     2345  5.2  8.3 987654 204800 ?       Sl   10:01   2:30 /usr/sbin/mysqld
appuser   3456  3.1  5.5 567890 135168 ?       Sl   10:05   1:20 node app.js
root      4567  0.5  3.2 345678  78600 ?       S    10:10   0:15 python3 worker.py
```

**Continuously watch memory (updates every 2 seconds):**

```bash
# Watch memory usage in real-time, refreshing every 2 seconds
# Press Ctrl+C to stop
watch -n2 free -m
```

#### Disk Monitoring

**Disk usage overview (excluding virtual filesystems):**

```bash
# Show disk usage for real partitions only
# "-h" = human-readable sizes (GB/MB instead of bytes)
# "-T" = show filesystem type (ext4, xfs, etc.)
# "-x tmpfs -x devtmpfs" = exclude virtual memory filesystems
df -hT -x tmpfs -x devtmpfs
```

**Expected output:**

```
Filesystem     Type      Size  Used Avail Use% Mounted on
/dev/sda1      ext4       50G   20G   28G  42% /
/dev/sda2      ext4      100G   83G   12G  85% /data
/dev/sdb1      xfs       500G  120G  380G  24% /backup
```

**Inode usage (important!):**

```bash
# Show inode (file metadata) usage for each partition
# Even if disk space is free, running out of inodes means you cannot create new files
# This can happen with millions of tiny files
df -i -x tmpfs -x devtmpfs
```

**Expected output:**

```
Filesystem      Inodes  IUsed   IFree IUse% Mounted on
/dev/sda1      3200000  45000 3155000    2% /
/dev/sda2      6400000 120000 6280000    2% /data
```

**Find the 10 largest directories under a path:**

```bash
# Calculate disk usage of all files/dirs under /path and show the top 10 largest
# "2>/dev/null" hides "permission denied" errors
# Replace /path with the directory you want to check, e.g., /var/log or /home
du -ah /path 2>/dev/null | sort -rh | head -10
```

**Expected output:**

```
25G     /var/log
15G     /var/log/nginx
12G     /var/log/nginx/access.log
8G     /var/lib/mysql
5G     /var/lib/docker
3G     /var/cache
```

**Mount details:**

```bash
# Show all mounted filesystems in a tree layout
# Useful to see which disks are attached where
findmnt
```

**Disk I/O statistics:**

```bash
# Show disk input/output statistics
# "-xz" = extended stats, show devices that are idle
# "1 3" = sample every 1 second, do 3 samples
# Requires sysstat package
iostat -xz 1 3
```

**Expected output:**

```
Linux 5.15.0-91-generic (my-server)   04/14/2026  _x86_64_ (4 CPU)

avg-cpu:  %user   %nice    %sys   %iowait    %steal   %idle
           5.25    0.00    2.10      0.25      0.00   92.40

Device            r/s     w/s     rMB/s     wMB/s   rrqm/s   wrqm/s  %util
sda             10.50    5.20      0.12      0.05     0.10     0.50   1.20
sdb              2.30    1.10      0.03      0.01     0.00     0.10   0.30
```

- **%util**: The percentage of time the disk was busy. Above 80-90% means the disk is a bottleneck.
- **r/s, w/s**: Read and write operations per second.
- **rMB/s, wMB/s**: Data read and written per second in MB.

#### Network Monitoring

**Show all listening TCP ports:**

```bash
# List all TCP ports that have a service listening on them
# "-t" = TCP, "-l" = listening, "-n" = numeric (no DNS lookup), "-p" = show process
ss -tlnp
```

**Expected output:**

```
State    Recv-Q   Send-Q     Local Address:Port    Peer Address:Port   Process
LISTEN   0        128              0.0.0.0:22           0.0.0.0:*       users:(("sshd",pid=1234,fd=3))
LISTEN   0        511              0.0.0.0:80           0.0.0.0:*       users:(("nginx",pid=2345,fd=6))
LISTEN   0        511              0.0.0.0:443          0.0.0.0:*       users:(("nginx",pid=2345,fd=7))
LISTEN   0        128              0.0.0.0:3306         0.0.0.0:*       users:(("mysqld",pid=3456,fd=10))
LISTEN   0        128                 [::]:8080            [::]:*       users:(("node",pid=4567,fd=12))
```

**Network connection statistics:**

```bash
# Show summary of all network connections by state
ss -s
```

**Expected output:**

```
Total: 150
TCP:   28 (estab 25, closed 2, orphaned 0, timewait 1)
Transport Total   IP        IPv6
RAW       0       0         0
UDP       3       2         1
TCP       26      22        4
INET      29      24        5
```

**Connection count by state:**

```bash
# Count how many connections are in each TCP state
# ESTABLISHED = active connection
# TIME-WAIT = connection that just closed, waiting to clean up
# CLOSE-WAIT = remote side closed, local app has not — often a bug
ss -ant | awk '{print $1}' | sort | uniq -c | sort -rn
```

**Expected output:**

```
     25 ESTAB
      5 TIME-WAIT
      3 CLOSE-WAIT
      2 LISTEN
```

**Network interface traffic stats:**

```bash
# Show RX (received) and TX (transmitted) bytes/packets for eth0
# Useful to see how much data is flowing through an interface
ip -s link show eth0
```

**Expected output:**

```
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:1a:2b:3c:4d:5e brd ff:ff:ff:ff:ff:ff
    RX:  bytes  packets  errors  dropped overrun mcast
         1.2GB   950000   0       0       0       0
    TX:  bytes  packets  errors  dropped carrier collsns
         800MB   620000   0       0       0       0
```

**Top 10 IPs by connection count:**

```bash
# Show which remote IP addresses have the most connections to your server
# Useful for spotting attacks (one IP with thousands of connections)
ss -nt | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10
```

**Expected output:**

```
     45 192.168.1.50
     12 10.0.0.100
      8 203.0.113.42
      5 172.16.0.25
      2 198.51.100.10
```

**Real-time bandwidth monitoring (requires iftop):**

```bash
# Show real-time network bandwidth usage by connection
# Press "q" to quit
# Requires: sudo apt install iftop
sudo iftop -i eth0
```

#### Process Monitoring

**Show full process tree:**

```bash
# Display all running processes in a tree format
# Shows parent-child relationships so you can see which process started which
ps auxf
```

**Find zombie processes:**

```bash
# Zombie processes are dead but their entry remains in the process table
# The "Z" state means zombie. Any zombie is a potential problem.
ps aux | awk '$8=="Z"'
```

**Expected output (if zombies exist):**

```
user      5678  0.0  0.0      0     0 ?        Z    10:00   0:00 [myapp] <defunct>
```

**Processes with the most open file handles:**

```bash
# Count open files per process — too many open files can cause "Too many open files" errors
lsof 2>/dev/null | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
```

**Expected output:**

```
    450 nginx
    320 mysqld
    180 node
    150 python3
     50 sshd
```

**System-wide open file handle count:**

```bash
# Show total open file handles and the system limit
# Format: open_handles  unused_handles  max_handles
cat /proc/sys/fs/file-nr
```

**Expected output:**

```
1024    0       65536
```

If the first number approaches the third number, your system may run out of file handles. Increase the limit with `sysctl -w fs.file-max=100000`.

**Detailed per-process resource monitoring:**

```bash
# Watch a specific process's CPU and memory usage over time
# Replace <PID> with the actual process ID number
# "1 5" means: sample every 1 second, do 5 samples
# Requires sysstat package
pidstat -p <PID> 1 5
```

---

## Module 2: Log Analysis & Troubleshooting

### What Are Logs and Why Do They Matter?

Logs are text files where your server and applications record everything that happens: who connected, what errors occurred, when services started or stopped, and much more. Think of logs as a detailed diary of your server's life.

When something goes wrong — a website returns an error, a service crashes, the server becomes slow — logs are almost always the first place to look for answers. They tell you **what** happened, **when** it happened, and often **why**.

### System Logs with journalctl

On modern Linux systems that use systemd (most do), `journalctl` is the primary tool for viewing system logs.

```bash
# Show the last 50 system log entries
# "--no-pager" prevents the output from pausing page by page
journalctl -n 50 --no-pager
```

**Expected output:**

```
Apr 14 14:30:01 my-server systemd[1]: Started Session 123 of user root.
Apr 14 14:30:05 my-server sshd[5678]: Accepted publickey for root from 192.168.1.50 port 54322
Apr 14 14:31:00 my-server CRON[6789]: (root) CMD (/usr/local/bin/backup.sh)
Apr 14 14:35:12 my-server nginx[2345]: 192.168.1.100 - "GET /api/health" 200
```

**Filter by time range:**

```bash
# Show logs from a specific date range
journalctl --since "2026-04-14 10:00" --until "2026-04-14 12:00"
```

**Filter by priority level:**

```bash
# Show only error-level and worse messages from the last hour
# Priority levels: 0=emerg, 1=alert, 2=crit, 3=err, 4=warning, 5=notice, 6=info, 7=debug
journalctl -p err --since "1 hour ago"
```

**Expected output:**

```
Apr 14 14:15:03 my-server mysqld[2345]: InnoDB: Cannot allocate memory for the buffer pool
Apr 14 14:20:45 my-server nginx[3456]: connect() failed (111: Connection refused) while connecting to upstream
```

**Filter by service:**

```bash
# Show logs for a specific service from the last hour
journalctl -u nginx.service --since "1 hour ago"
```

**Follow logs in real-time:**

```bash
# Watch new log entries as they appear (like "tail -f")
# Press Ctrl+C to stop
journalctl -f
```

**View kernel error and warning messages:**

```bash
# Show kernel-level error and warning messages with human-readable timestamps
# "-T" = timestamp, "-l err,warn" = filter by level
dmesg -T -l err,warn | tail -20
```

**Expected output:**

```
[Apr14 14:10] EXT4-fs warning: mounted filesystem with errors, running e2fsck recommended
[Apr14 14:12] out of memory: kill process 3456 (node) score 500
```

### Common Log File Paths

Not all logs go through journalctl. Many applications write to their own log files.

| Service | Log Path | What it contains |
|---------|----------|-----------------|
| System (Debian/Ubuntu) | `/var/log/syslog` | General system messages |
| System (CentOS/RHEL) | `/var/log/messages` | General system messages |
| Authentication (Debian/Ubuntu) | `/var/log/auth.log` | Login attempts, sudo usage |
| Authentication (CentOS/RHEL) | `/var/log/secure` | Login attempts, sudo usage |
| Nginx access | `/var/log/nginx/access.log` | All HTTP requests |
| Nginx errors | `/var/log/nginx/error.log` | HTTP errors and server issues |
| MySQL | `/var/log/mysql/error.log` | Database errors |
| PostgreSQL | `/var/log/postgresql/` | Database logs (directory) |
| Docker | `journalctl -u docker.service` | Docker daemon logs |
| Application (common) | `/var/log/app/` or `/opt/app/logs/` | Custom application logs |

### Searching Logs with grep and awk

**Search for a keyword across all log files:**

```bash
# Search for the word "ERROR" in all .log files under /var/log/
# "-r" = recursive (search subdirectories), "-n" = show line numbers
# "tail -20" = show only the last 20 results (log files can be huge)
grep -rn "ERROR" /var/log/ --include="*.log" | tail -20
```

**Expected output:**

```
/var/log/nginx/error.log:45:2026/04/14 14:30:05 [error] connect() failed (111: Connection refused)
/var/log/app/app.log:128:2026-04-14 14:35:12 ERROR Database connection timeout
```

**Search logs within a time range (using awk):**

```bash
# Print all log lines between two timestamps
# Works when the log file has timestamps at the start of each line
# Replace the timestamps with your actual time range
awk '/2026-04-14 10:00/,/2026-04-14 11:00/' /var/log/app/app.log
```

**Count error types by hour:**

```bash
# Extract the hour from ERROR lines and count how many errors per hour
# "-F'[: ]'" = split on colons and spaces, so $1 is the date, $2 is the hour
grep "ERROR" /var/log/app.log | awk -F'[: ]' '{print $1" "$2":00"}' | sort | uniq -c | sort -rn | head -10
```

**Expected output:**

```
     45 2026-04-14 14:00
     32 2026-04-14 10:00
     12 2026-04-14 09:00
```

### Nginx Log Analysis Examples

Nginx access logs follow a standard format. Here are practical analysis commands.

**HTTP status code distribution:**

```bash
# Count how many requests resulted in each HTTP status code
# $9 in the default combined log format is the status code (200, 404, 500, etc.)
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn
```

**Expected output:**

```
   4500 200     # OK — successful requests
    300 304     # Not Modified — cached responses
    150 404     # Not Found — missing pages/files
     50 500     # Internal Server Error — server-side bugs
     20 301     # Moved Permanently — redirects
```

**Find slow requests (over 5 seconds):**

```bash
# Show requests that took more than 5 seconds to respond
# $NF (last field) in the default format is the response time in seconds
# "tail -20" shows the most recent 20 slow requests
awk '$NF > 5 {print $0}' /var/log/nginx/access.log | tail -20
```

**Expected output:**

```
192.168.1.100 - - [14/Apr/2026:14:30:05 +0000] "GET /api/heavy-query" 200 12345 "-" "Mozilla/5.0" 8.5
10.0.0.50 - - [14/Apr/2026:14:32:10 +0000] "POST /api/upload" 200 54321 "-" "curl/7.68" 6.2
```

**Top 20 IPs by request count (spot attacks or heavy users):**

```bash
# Count how many requests came from each IP address
# A single IP with thousands of requests may be a bot or attacker
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -20
```

**Expected output:**

```
   8500 192.168.1.100     # This IP has way more requests than others — investigate!
    450 10.0.0.50
    320 203.0.113.42
    150 172.16.0.25
```

### 7-Step Troubleshooting Workflow

When something goes wrong, follow this systematic approach instead of guessing randomly.

#### Step 1: Get the Big Picture

```bash
# Run the full health check to see the overall server state
bash scripts/health-check.sh --full
```

This tells you at a glance if CPU, memory, disk, or network is under stress. Start here before diving into details.

#### Step 2: Check Recent Errors

```bash
# Look for error-level system messages from the last hour
journalctl -p err --since "1 hour ago"
```

This reveals if any service crashed, if the kernel reported problems, or if hardware is failing.

#### Step 3: Check the Specific Service's Logs

```bash
# Look at logs for the service that is having trouble
# Replace "nginx.service" with your service name
journalctl -u nginx.service --since "30 min ago"
```

Service-specific logs usually contain the exact error message explaining what went wrong.

#### Step 4: Identify Resource Bottlenecks

```bash
# Check CPU usage in real-time (press "q" to quit)
top

# Check disk I/O bottlenecks (requires iotop, press "q" to quit)
sudo iotop

# Check network bandwidth (requires iftop, press "q" to quit)
sudo iftop -i eth0
```

If one resource (CPU, disk I/O, or network) is maxed out, that is your bottleneck.

#### Step 5: Check Disk Space

```bash
# Make sure no disk partition is full
df -h
```

A full disk causes all kinds of mysterious failures: services cannot write logs, databases cannot save data, Docker cannot create containers.

#### Step 6: Check File Handles

```bash
# See how many file handles are open vs. the system limit
cat /proc/sys/fs/file-nr

# Count total open files
lsof 2>/dev/null | wc -l
```

Running out of file handles causes "Too many open files" errors, which crash services.

#### Step 7: Test Network Connectivity

```bash
# Test if a URL is reachable (replace with your actual URL)
curl -v https://example.com

# Test if a specific port is open on a remote host
# Replace with the host and port you need to check
telnet db-server 3306

# Trace the network path to a host (see where packets get stuck)
traceroute example.com
```

Network issues can be caused by firewalls, DNS problems, or network outages between your server and the destination.

### Real-World Troubleshooting Scenarios

**Scenario: "My website is returning 502 Bad Gateway"**

This usually means the web server (Nginx) cannot reach the application behind it.

```bash
# Step 1: Is the app process running?
pgrep -af node           # Check if Node.js app is running
pgrep -af python         # Check if Python app is running
pgrep -af php-fpm        # Check if PHP-FPM is running

# Step 2: Check Nginx error log for the specific error
tail -50 /var/log/nginx/error.log

# Step 3: Is the app listening on the expected port?
ss -tlnp | grep 8080    # Replace 8080 with your app's port

# Step 4: Restart the app if it crashed
systemctl restart your-app.service
```

**Scenario: "Database connection refused"**

```bash
# Is MySQL running?
systemctl status mysql

# Is it listening on the right port?
ss -tlnp | grep 3306

# Check MySQL error log
tail -50 /var/log/mysql/error.log

# Can the app server reach the database?
telnet db-server 3306
```

**Scenario: "SSH connection refused"**

```bash
# Is sshd running?
systemctl status sshd

# Is the firewall blocking port 22?
ufw status              # Ubuntu
firewall-cmd --list-all # CentOS

# Check sshd log for errors
journalctl -u sshd --since "1 hour ago"
```

---

## Module 3: Service Management

### What is systemd?

**systemd** is the system and service manager used by virtually all modern Linux distributions. It starts services at boot, monitors them while they run, and restarts them if they crash. Think of it as the "control center" for everything running on your server.

A **service** (also called a "unit" or "daemon") is a program that runs in the background. For example, `nginx` serves web pages, `sshd` allows SSH connections, and `docker` manages containers — all as background services.

### systemctl Commands (with Examples)

**Check if a service is running:**

```bash
# Show the current status of the Nginx web server
# This tells you if it is running, its process ID, and recent log entries
systemctl status nginx
```

**Expected output:**

```
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2026-04-14 10:00:00 UTC; 4h 30min ago
       Docs: man:nginx(8)
   Main PID: 1234 (nginx)
      Tasks: 5 (limit: 4915)
     Memory: 12.5M
        CPU: 1.200s
     CGroup: /system.slice/nginx.service
             ├─1234 "nginx: master process /usr/sbin/nginx -g daemon on;"
             └─1235 "nginx: worker process"
```

Key fields:
- **Loaded**: The service configuration file was found and loaded.
- **Active: active (running)**: The service is running right now.
- **Main PID**: The process ID of the main service process.
- **Memory**: How much RAM the service is using.

**Start a service:**

```bash
# Start Nginx (if it is currently stopped)
systemctl start nginx
```

**Stop a service:**

```bash
# Stop Nginx gracefully (lets it finish current requests)
systemctl stop nginx
```

**Restart a service:**

```bash
# Stop and then start Nginx (brief downtime)
# Use this when you have changed the configuration
systemctl restart nginx
```

**Reload a service configuration (no downtime):**

```bash
# Reload Nginx configuration without stopping the service
# This is better than restart because there is no downtime
# Not all services support reload — check the service documentation
systemctl reload nginx
```

**Enable a service to start at boot:**

```bash
# Make Nginx start automatically when the server boots
# "enable" does NOT start the service now — it only sets it to start on next boot
systemctl enable nginx
```

**Disable a service from starting at boot:**

```bash
# Prevent Nginx from starting automatically on boot
# This does NOT stop a currently running service
systemctl disable nginx
```

**Enable and start in one command:**

```bash
# Enable Nginx for boot AND start it right now
systemctl enable --now nginx
```

**List all failed services:**

```bash
# Show all services that have crashed or failed to start
systemctl --failed
```

**Expected output (when failures exist):**

```
UNIT              LOAD   ACTIVE SUB     DESCRIPTION
mysql.service     loaded failed failed  MySQL Community Server
php-fpm.service   loaded failed failed  The PHP FastCGI Process Manager
```

**View service logs:**

```bash
# Show the last 50 log entries for Nginx
journalctl -u nginx -n 50 --no-pager
```

**List all running services:**

```bash
# Show every service that is currently active and running
systemctl list-units --type=service --state=running
```

**Expected output:**

```
UNIT                    LOAD   ACTIVE SUB     DESCRIPTION
cron.service            loaded active running Regular background program
docker.service          loaded active running Docker Application Container Engine
nginx.service           loaded active running A high performance web server
sshd.service            loaded active running OpenBSD Secure Shell server
```

**View service dependencies:**

```bash
# Show what other services a service depends on
# Useful for understanding why a service will not start (maybe a dependency is down)
systemctl list-dependencies nginx
```

### Common Service Name Reference

Different Linux distributions sometimes use different names for the same service.

| Application | Ubuntu/Debian Service Name | CentOS/RHEL Service Name |
|-------------|---------------------------|--------------------------|
| Nginx | `nginx` | `nginx` |
| Apache | `apache2` | `httpd` |
| MySQL | `mysql` | `mysqld` |
| PostgreSQL | `postgresql` | `postgresql` |
| Redis | `redis-server` | `redis` |
| Docker | `docker` | `docker` |
| SSH | `sshd` | `sshd` |
| Cron | `cron` | `crond` |
| Firewall | `ufw` | `firewalld` |

### Process Management (Non-systemd)

Sometimes you need to manage processes directly, without systemd.

**Find a process by name or keyword:**

```bash
# Search for all processes matching "nginx"
# "-a" = show full command line, "-f" = match against full command line
pgrep -af nginx
```

**Expected output:**

```
1234 nginx: master process /usr/sbin/nginx -g daemon on;
1235 nginx: worker process
```

**Terminate a process gracefully (SIGTERM):**

```bash
# Ask process 5678 to shut down cleanly
# SIGTERM (signal 15) lets the process save data and exit gracefully
kill 5678
```

**Force-kill a process (SIGKILL):**

```bash
# Immediately terminate process 5678 with no chance to save data
# USE AS A LAST RESORT — the process cannot clean up, data may be lost
kill -9 5678
```

**SIGTERM vs SIGKILL — What is the difference?**

| Signal | Number | What happens | When to use |
|--------|--------|-------------|-------------|
| SIGTERM | 15 | The process receives a "please exit" signal. It can save data, close connections, and exit cleanly. | Always try this first |
| SIGKILL | 9 | The kernel immediately kills the process. It has NO chance to save data or close connections. | Only when SIGTERM did not work and the process is stuck |

**Kill processes by name:**

```bash
# Kill all processes matching a pattern
# "-f" = match the full command line
pkill -f "python worker.py"

# Kill all processes with an exact name
killall nginx
```

**Check which port a process is using:**

```bash
# Find which process is listening on port 8080
# Replace <PID> with a process ID to check a specific process
ss -tlnp | grep 8080
```

### Firewall Management

A firewall controls which network connections are allowed in and out of your server. Different Linux distributions use different firewall tools.

#### UFW (Ubuntu)

UFW (Uncomplicated Firewall) is the default firewall tool on Ubuntu. It makes firewall management simple.

```bash
# Check current firewall status and rules
ufw status

# Allow HTTP traffic on port 80
ufw allow 80/tcp

# Allow HTTPS traffic on port 443
ufw allow 443/tcp

# Block MySQL port from external access (only allow local connections)
ufw deny 3306/tcp

# Allow SSH (important! do this before enabling the firewall or you may lock yourself out)
ufw allow 22/tcp

# Enable the firewall
ufw enable

# Delete a rule
ufw delete allow 80/tcp
```

**Expected output for `ufw status`:**

```
Status: active
To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
3306/tcp                   DENY        Anywhere
```

#### firewalld (CentOS/RHEL)

```bash
# List all current firewall rules
firewall-cmd --list-all

# Allow HTTP traffic permanently (survives reboot)
firewall-cmd --add-port=80/tcp --permanent

# Allow HTTPS traffic permanently
firewall-cmd --add-port=443/tcp --permanent

# Reload the firewall to apply new permanent rules
firewall-cmd --reload

# Remove a port rule
firewall-cmd --remove-port=8080/tcp --permanent
firewall-cmd --reload
```

**Expected output for `firewall-cmd --list-all`:**

```
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0
  sources:
  services: ssh dhcpv6-client
  ports: 80/tcp 443/tcp
```

#### iptables (Low-level, All Linux)

```bash
# List all current iptables rules with details
# "-L" = list, "-n" = numeric (no DNS), "-v" = verbose
iptables -L -n -v
```

**Expected output:**

```
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source       destination
 500  25000 ACCEPT     tcp  --  *      *       0.0.0.0/0   0.0.0.0/0   tcp dpt:22
 300  15000 ACCEPT     tcp  --  *      *       0.0.0.0/0   0.0.0.0/0   tcp dpt:80
 200  10000 ACCEPT     tcp  --  *      *       0.0.0.0/0   0.0.0.0/0   tcp dpt:443
```

> **Warning:** iptables changes take effect immediately but are lost on reboot unless you save them. On Ubuntu, use `iptables-persistent`. On CentOS, use `iptables-services`.

---

## Module 4: Docker & Container Management

### What is Docker?

Docker is a tool that lets you package an application and all its dependencies into a standardized unit called a **container**. A container is like a lightweight virtual machine — it runs in its own isolated environment but shares the host's kernel, making it much faster and more efficient than a full VM.

Think of it this way:
- **Virtual Machine**: A full computer (with its own operating system) running inside your server. Heavy, slow to start, uses lots of resources.
- **Container**: Just the application and its dependencies, sharing the server's kernel. Lightweight, starts in seconds, uses minimal resources.

Key Docker terms:
- **Image**: A read-only template with instructions for creating a container (like a recipe).
- **Container**: A running instance of an image (like a cake baked from the recipe).
- **Dockerfile**: A text file with instructions to build an image.
- **Registry**: A storage for images (Docker Hub is the default public registry).
- **Volume**: A persistent storage location that survives container restarts.

### Container Lifecycle

**List containers:**

```bash
# Show all running containers
docker ps

# Show ALL containers including stopped ones
docker ps -a
```

**Expected output for `docker ps`:**

```
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS        PORTS                    NAMES
a1b2c3d4e5f6   nginx:latest   "/docker-entrypoint.…"   3 hours ago    Up 3 hours    0.0.0.0:8080->80/tcp     myapp
f6e5d4c3b2a1   redis:7        "redis-server"           3 hours ago    Up 3 hours    0.0.0.0:6379->6379/tcp   redis
```

**Start a stopped container:**

```bash
# Start a container that was previously stopped
docker start myapp
```

**Stop a running container:**

```bash
# Gracefully stop a container (sends SIGTERM, then SIGKILL after 10 seconds)
docker stop myapp
```

**Restart a container:**

```bash
# Stop and start a container
docker restart myapp
```

**Create and start a new container:**

```bash
# Run Nginx in the background (-d), name it "myapp", map host port 8080 to container port 80
# "-d" = detached (run in background)
# "--name myapp" = give the container a name
# "-p 8080:80" = map host port 8080 to container port 80
# "nginx:latest" = the image to use
docker run -d --name myapp -p 8080:80 nginx:latest
```

**Expected output:**

```
a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef1234
```

(This long string is the container ID.)

**Remove a stopped container:**

```bash
# Remove a container that is already stopped
docker rm myapp

# Force-remove a running container (stops it first, then removes)
docker rm -f myapp
```

**Clean up all stopped containers:**

```bash
# Remove all containers that are not running
# "-f" = do not ask for confirmation
docker container prune -f
```

**Expected output:**

```
Deleted Containers:
b2c3d4e5f6g7, c3d4e5f6g7h8, d4e5f6g7h8i9

Total reclaimed space: 150MB
```

### Container Operations

**View container logs:**

```bash
# Show all logs for a container
docker logs myapp

# Show the last 100 lines and keep watching for new log entries ("follow" mode)
# Press Ctrl+C to stop watching
docker logs --tail 100 -f myapp

# Show logs from the last hour only
docker logs --since 1h myapp
```

**Expected output:**

```
192.168.1.100 - - [14/Apr/2026:14:30:05 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.68.0"
192.168.1.100 - - [14/Apr/2026:14:30:06 +0000] "GET /favicon.ico HTTP/1.1" 404 555 "-" "curl/7.68.0"
```

**Execute a command inside a running container:**

```bash
# Open an interactive bash shell inside the container
# "-i" = interactive, "-t" = allocate a pseudo-terminal
# Type "exit" to leave the container shell
docker exec -it myapp bash

# If the container does not have bash, try sh instead
docker exec -it myapp sh

# Run a single command without opening a shell
docker exec myapp cat /etc/hostname
```

**Monitor container resource usage:**

```bash
# Show real-time CPU, memory, and network usage for all running containers
# Press Ctrl+C to stop
docker stats

# Show stats for a specific container only
docker stats myapp
```

**Expected output:**

```
CONTAINER ID   NAME      CPU %   MEM USAGE / LIMIT   MEM %   NET I/O           BLOCK I/O
a1b2c3d4e5f6   myapp     0.25%   5.5MiB / 512MiB    1.07%   1.2kB / 0B        0B / 0B
f6e5d4c3b2a1   redis     0.10%   3.2MiB / 256MiB    1.25%   850B / 0B         0B / 0B
```

**Inspect container details:**

```bash
# Show detailed configuration of a container in JSON format
# Includes: IP address, mounted volumes, environment variables, image, etc.
docker inspect myapp
```

**Check container port mappings:**

```bash
# Show which host ports are mapped to which container ports
docker port myapp
```

**Expected output:**

```
80/tcp -> 0.0.0.0:8080
```

This means: container port 80 is accessible on host port 8080.

### Image Management

**List images:**

```bash
# Show all Docker images stored on this server
docker images
```

**Expected output:**

```
REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
nginx         latest    a1b2c3d4e5f6   2 days ago     187MB
redis         7         f6e5d4c3b2a1   5 days ago     130MB
myapp         v1        b2c3d4e5f6g7   1 week ago     450MB
```

**Pull (download) an image:**

```bash
# Download the latest Nginx image from Docker Hub
docker pull nginx:latest

# Download a specific version
docker pull redis:7.2
```

**Build an image from a Dockerfile:**

```bash
# Build an image from the Dockerfile in the current directory
# "-t myapp:v1" = tag the image as "myapp:v1"
# "." = use the current directory as the build context
docker build -t myapp:v1 .
```

**Remove an image:**

```bash
# Delete an image from your server
# You cannot remove an image that is used by any container (even stopped ones)
docker rmi nginx:latest
```

**Remove dangling images (unused build layers):**

```bash
# "Dangling" images are intermediate build layers that are no longer referenced
# They waste disk space and are safe to remove
docker image prune -f
```

**View image build history:**

```bash
# Show each layer of an image and the command that created it
# Useful for understanding how an image was built and how large each layer is
docker history myapp:v1
```

### Docker Compose

Docker Compose lets you define and manage multi-container applications with a single `docker-compose.yml` file.

**Start all services defined in docker-compose.yml:**

```bash
# Start all services in the background (-d = detached)
# Must be run in a directory containing docker-compose.yml
docker compose up -d
```

**Expected output:**

```
[+] Running 3/3
 ✔ Container myapp   Started   0.5s
 ✔ Container redis   Started   0.3s
 ✔ Container db      Started   0.8s
```

**Stop and remove all services:**

```bash
# Stop all containers and remove them, along with their networks
# Volumes are preserved by default (add "--volumes" to also remove volumes)
docker compose down
```

**Check service status:**

```bash
# Show the status of all services defined in docker-compose.yml
docker compose ps
```

**View logs for a specific service:**

```bash
# Follow (stream) logs for the "myapp" service
# Press Ctrl+C to stop
docker compose logs -f myapp
```

**Restart a single service:**

```bash
# Restart only the "myapp" service, leaving others running
docker compose restart myapp
```

**Pull latest images and rebuild:**

```bash
# Download the latest images from the registry
docker compose pull

# Rebuild and restart services (useful after code changes)
docker compose up -d --build
```

**Scale a service (run multiple instances):**

```bash
# Run 3 instances of the "worker" service
# Make sure your app is designed to run multiple instances safely
docker compose up -d --scale worker=3
```

### Docker System Maintenance

Over time, Docker uses more and more disk space with old images, stopped containers, and build cache. Regular cleanup is essential.

**Check Docker disk usage:**

```bash
# Show how much disk space Docker is using, broken down by type
docker system df
```

**Expected output:**

```
TYPE            TOTAL   ACTIVE  SIZE      RECLAIMABLE
Images          7       3       1.5GB     800MB (53%)
Containers      4       3       50MB      25MB (50%)
Local Volumes   2       2       500MB    0B (0%)
Build Cache     15      0       200MB    200MB (100%)
```

**What each prune command removes:**

| Command | What it removes | What it keeps |
|---------|-----------------|---------------|
| `docker system prune -f` | Stopped containers, dangling images, unused networks, build cache | Running containers, images used by containers, named volumes |
| `docker system prune -a -f` | Everything above PLUS all images not used by a running container | Running containers and their images, named volumes |
| `docker image prune -f` | Dangling images only (untagged intermediate layers) | Tagged images, images in use |
| `docker image prune -a -f` | All images not used by any container | Images currently in use |
| `docker container prune -f` | All stopped containers | Running containers |
| `docker volume prune -f` | Volumes not used by any container | Volumes in use |
| `docker builder prune -f` | Build cache only | Everything else |

**Warning about `docker system prune -a -f`:** This deletes ALL images that are not currently used by a running container. The next time you need one of those images, you will have to download it again. Use this only when you really need to free disk space.

```bash
# Light cleanup — safe for production
docker system prune -f

# Deep cleanup — removes unused images too (be careful!)
docker system prune -a -f

# Clean up build cache only
docker builder prune -f

# Clean up unused volumes (WARNING: this deletes data in unused volumes!)
docker volume prune -f
```

### Common Docker Troubleshooting

**Problem: Container won't start — keeps restarting**

```bash
# Check the container's exit code and logs
# "-a" = include stopped containers
docker ps -a | grep myapp

# View the logs to find the error
docker logs myapp

# Inspect the container for the exit code
# Look for "State" -> "ExitCode" in the output
# Common exit codes:
#   0 = exited normally
#   1 = application error
#   137 = killed by OOM (out of memory)
#   139 = segmentation fault
docker inspect myapp | grep -A5 "State"
```

**Problem: Docker logs are taking up too much disk space**

Docker container logs can grow without limit by default. To fix this:

```bash
# Check how much space Docker is using
docker system df

# Option 1: Configure log rotation in /etc/docker/daemon.json
# Add these settings:
# {
#   "log-driver": "json-file",
#   "log-opts": {
#     "max-size": "10m",    # Rotate when log file reaches 10MB
#     "max-file": "3"       # Keep at most 3 rotated log files
#   }
# }
# Then restart Docker: sudo systemctl restart docker

# Option 2: Manually truncate a specific container's log file
# First find the log path:
docker inspect --format='{{.LogPath}}' myapp
# Then truncate it (this does not stop the container):
sudo truncate -s 0 /var/lib/docker/containers/abc123/abc123-json.log
```

**Problem: Docker is using too much disk space**

```bash
# Step 1: See what is using the space
docker system df

# Step 2: Remove all stopped containers
docker container prune -f

# Step 3: Remove unused images
docker image prune -a -f

# Step 4: Remove build cache
docker builder prune -f

# Step 5: If still too full, remove unused volumes (CAUTION: deletes data!)
docker volume prune -f

# Nuclear option: remove everything Docker is not actively using
docker system prune -a --volumes -f
```

**Problem: Container timezone is wrong**

By default, Docker containers use UTC. To fix:

```bash
# Set the container timezone when running
# Replace "America/New_York" with your timezone
docker run -d --name myapp -e TZ=America/New_York -p 8080:80 nginx:latest

# Or mount the host's timezone file
docker run -d --name myapp -v /etc/localtime:/etc/localtime:ro -p 8080:80 nginx:latest
```

---

## Alert Thresholds Reference

Use this table to understand when you should worry about a metric.

| Metric | Warning | Critical | Plain English Explanation |
|--------|---------|----------|--------------------------|
| CPU usage | >70% | >90% | Warning: the CPU is busy. Critical: the CPU is overwhelmed and tasks are queuing up. |
| Memory usage | >80% | >90% | Warning: RAM is getting full. Critical: almost no RAM left — the system will start using slow swap space. |
| Swap usage | >30% | >50% | Warning: the system is using disk as RAM overflow. Critical: heavy swap usage will make everything very slow. |
| Disk usage | >80% | >90% | Warning: disk is filling up. Critical: very little space left — services may fail, you cannot write files. |
| Inode usage | >80% | >90% | Warning: file metadata slots are filling up. Critical: you cannot create new files even if space exists (happens with millions of tiny files). |
| Zombie processes | >0 | >5 | Warning: a process died but was not cleaned up. Critical: many zombies indicate a bug in the parent application. |
| System load (1min) | >cores * 0.7 | >cores | Warning: CPU is getting busy. Critical: more work than the CPU can handle. Example: with 4 cores, warning at 2.8, critical at 4.0. |

---

## Common Scenarios (Playbook)

Step-by-step guides for the most common server problems.

### Scenario 1: "My Server is Slow"

```bash
# Step 1: Run the health check to get a quick overview
bash scripts/health-check.sh

# Step 2: Check if CPU is overloaded
# Look at load average — if it is higher than your core count, CPU is the bottleneck
top -bn1 | head -5

# Step 3: Check if memory is full (causing slow swap usage)
free -m
# If "available" is very low and swap is high, memory is the bottleneck

# Step 4: Check if disk I/O is slow
iostat -xz 1 3
# If "%util" is high (above 80-90%), disk is the bottleneck

# Step 5: Find the top CPU-consuming process
ps aux --sort=-%cpu | head -5

# Step 6: Find the top memory-consuming process
ps aux --sort=-%mem | head -5

# Step 7: If a specific process is the problem, consider restarting it
# systemctl restart <service-name>
```

### Scenario 2: "Disk is Almost Full"

```bash
# Step 1: Check which partitions are full
df -h

# Step 2: Find the largest directories on the full partition
# Replace "/" with the mount point that is full
du -ah / 2>/dev/null | sort -rh | head -20

# Step 3: Common space hogs to check
# Log files:
du -sh /var/log/*
# Docker:
docker system df
# Temporary files:
du -sh /tmp/*

# Step 4: Clean up based on what you find
# Clean old logs (keep the last 7 days):
find /var/log -name "*.log" -mtime +7 -delete

# Clean Docker (safe cleanup):
docker system prune -f

# Clean old Docker images not in use:
docker image prune -a -f

# Clean journal logs older than 3 days:
sudo journalctl --vacuum-time=3d
```

### Scenario 3: "A Service Crashed"

```bash
# Step 1: Check which services have failed
systemctl --failed

# Step 2: Look at the failed service's logs
# Replace "mysql" with your service name
journalctl -u mysql --since "1 hour ago"

# Step 3: Try to restart the service
systemctl restart mysql

# Step 4: Check if it stays running
systemctl status mysql

# Step 5: If it keeps crashing, look for the root cause in the logs
# Common causes: out of memory, configuration error, missing files, port conflict
journalctl -u mysql -p err --since "1 hour ago"

# Step 6: Check if the port is already in use by something else
ss -tlnp | grep 3306
```

### Scenario 4: "Docker Container Keeps Restarting"

```bash
# Step 1: Check the container status
docker ps -a | grep myapp

# Step 2: View the container logs to find the error
docker logs --tail 50 myapp

# Step 3: Check if it was killed for out-of-memory
docker inspect myapp | grep -A5 "State"
# Look for "OOMKilled": true

# Step 4: Check Docker events for the restart reason
docker events --since 30m --until 0s --filter container=myapp

# Step 5: If OOMKilled, increase memory limit
# Stop the container, then run with more memory:
docker run -d --name myapp --memory=1g -p 8080:80 myapp-image

# Step 6: If it is a different error, fix the application issue and rebuild
# docker compose up -d --build
```

### Scenario 5: "High Memory Usage"

```bash
# Step 1: Check overall memory
free -m
# Focus on "available" — this is what apps can actually use

# Step 2: Find the biggest memory consumers
ps aux --sort=-%mem | head -11

# Step 3: Check if swap is being heavily used (sign of memory pressure)
free -m | grep Swap

# Step 4: Check if any process is leaking memory (growing over time)
# Watch memory usage of a specific process over time:
pidstat -p <PID> 1 10    # 10 samples, 1 second apart

# Step 5: If a process is using too much memory, restart it
systemctl restart <service-name>

# Step 6: For Docker containers, set memory limits
# docker run --memory=512m --memory-swap=1g ...
```

### Scenario 6: "Too Many Network Connections"

```bash
# Step 1: Count connections by state
ss -ant | awk '{print $1}' | sort | uniq -c | sort -rn

# Step 2: If TIME-WAIT is very high, the server is creating many short-lived connections
# This can exhaust ephemeral ports

# Step 3: If CLOSE-WAIT is high, your application is not closing connections properly
# This is a bug in the application code

# Step 4: Find which IPs have the most connections
ss -nt | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -20

# Step 5: If one IP has an unusually high number of connections, it may be an attack
# Block it with the firewall:
# ufw deny from 203.0.113.42    # Ubuntu
# firewall-cmd --add-rich-rule='rule family="ipv4" source address="203.0.113.42" reject' --permanent  # CentOS
# firewall-cmd --reload

# Step 6: Check current connection count
ss -s
```

---

## FAQ

### 1. What does SRE mean?

**SRE** stands for **Site Reliability Engineering**. It is a set of practices for keeping systems running reliably. SREs use automation, monitoring, and incident response procedures to minimize downtime. Think of it as a disciplined approach to server operations.

### 2. I just got my first Linux server. Where do I start?

1. Log in via SSH: `ssh username@your-server-ip`
2. Update your system: `sudo apt update && sudo apt upgrade -y` (Ubuntu/Debian) or `sudo yum update -y` (CentOS/RHEL)
3. Run the health check: `bash scripts/health-check.sh --full`
4. Read through the output to understand your server's current state
5. Set up a firewall: `sudo ufw allow 22/tcp && sudo ufw enable` (Ubuntu)
6. Bookmark this README for reference!

### 3. Do I need root/sudo to use this toolkit?

Most monitoring commands work without root. However, some commands require `sudo`:
- `ss -tlnp` (showing process names for all ports)
- `iptables` / `ufw` / `firewall-cmd` (firewall management)
- `docker` commands (your user must be in the `docker` group or use `sudo`)
- `iotop` (disk I/O monitoring)

### 4. The health check shows [WARN] or [FAIL]. What do I do?

- **[WARN]** means a metric is approaching a problem level. You should investigate soon but it is not an emergency. Follow the relevant playbook scenario above.
- **[FAIL]** means a critical threshold has been exceeded. Fix this as soon as possible. See the "Common Scenarios" section for step-by-step guides.

### 5. What is the difference between memory "used" and memory "available"?

On Linux, "used" includes memory used for disk cache, which can be freed instantly if applications need it. "Available" is the real number you should look at — it tells you how much memory can be used right now. A server with 90% "used" memory but plenty of "available" memory is perfectly healthy.

### 6. What is swap and should I worry about it?

Swap is a portion of your hard disk used as overflow when RAM is full. Because disks are much slower than RAM, using swap makes your server slow. If your server is using a lot of swap, it needs more RAM or you need to reduce memory usage by optimizing or restarting applications.

### 7. What are zombie processes and are they dangerous?

A zombie process is a process that has finished execution but still has an entry in the process table because its parent has not acknowledged its termination. They use almost no resources (just a process table entry). A few zombies are harmless, but many zombies (hundreds) can exhaust the process table. The real issue is that zombies indicate a bug in the parent program. To fix them, restart the parent process.

### 8. Docker commands give "permission denied". How do I fix this?

By default, Docker requires root access. Two options:
1. Use `sudo` before every Docker command: `sudo docker ps`
2. Add your user to the Docker group (preferred): `sudo usermod -aG docker $USER`, then log out and log back in. **Warning**: This gives the user root-equivalent access via Docker.

### 9. My server's load average is high but CPU usage is low. Why?

This can happen when many processes are waiting for disk I/O (not CPU). The load average counts processes waiting for any resource, including disk. Check disk I/O with `iostat -xz 1 3` — if `%util` is high, your disk is the bottleneck, not the CPU.

### 10. How do I know if my server has been hacked?

Warning signs include:
- Unfamiliar processes running (check with `ps auxf`)
- Unusual network connections to foreign IPs (check with `ss -nt`)
- Unknown users or SSH keys in `~/.ssh/authorized_keys`
- Missing or modified log files in `/var/log/`
- New firewall rules you did not create (check with `ufw status` or `iptables -L -n`)

Run `journalctl -u sshd --since "24 hours ago"` to check for suspicious SSH login attempts.

### 11. How often should I run the health check?

- **Daily**: Run `--quick` mode as part of your morning routine
- **Weekly**: Run `--full` mode for a complete picture
- **After changes**: Run after any major configuration change, deployment, or update
- **Automate**: Set up a cron job to run it daily and email you the results:
  ```bash
  # Add this to crontab (crontab -e) to run daily at 8 AM:
  0 8 * * * /path/to/sre-skill/scripts/health-check.sh --quick | mail -s "Daily Health Check" admin@example.com
  ```

### 12. Can I use this toolkit on macOS?

Yes! The health check script automatically detects macOS and uses the appropriate commands (`vm_stat`, `sysctl`, `lsof`, etc.). However, macOS does not have systemd, so the service management and journalctl commands do not apply. Most other monitoring commands work with macOS-compatible alternatives.

### 13. How do I clean up Docker without breaking anything?

Start with the safest command and work up:
1. `docker system prune -f` — removes stopped containers, dangling images, unused networks, build cache. Safe.
2. `docker image prune -f` — removes only dangling (untagged) images. Very safe.
3. `docker image prune -a -f` — removes all images not used by a running container. Safe if your containers use specific tags.
4. `docker system prune -a -f` — everything above plus unused images. Careful: next `docker run` may need to re-download images.
5. `docker volume prune -f` — removes unused volumes. **CAUTION**: this deletes data!

---

## Contributing

We welcome contributions! Here is how you can help:

1. **Fork** the repository on GitHub
2. **Clone** your fork: `git clone git@github.com:your-username/sre-skill.git`
3. **Create a branch** for your changes: `git checkout -b my-new-feature`
4. **Make your changes** and test them
5. **Commit** with a clear message: `git commit -m "Add: description of my feature"`
6. **Push** to your fork: `git push origin my-new-feature`
7. **Open a Pull Request** on GitHub with a description of your changes

### Contribution Ideas

- Add new monitoring commands or scenarios
- Improve macOS compatibility
- Add support for other operating systems
- Fix bugs or improve documentation
- Add new health check features
- Translate documentation to other languages

### Code Style

- Shell scripts should be compatible with bash
- Use `set -uo pipefail` for safety
- Comment your code — explain WHY, not just WHAT
- Test on both Linux and macOS when possible

---

## Multi-Agent Integration Guide

> This guide is for beginners, walking you step-by-step through integrating and using the SRE Ops-Toolkit skill across three major AI agents.
> All commands can be copied and pasted directly.

---

### Table of Contents

1. [Claude Code (Anthropic) Integration](#1-claude-code-anthropic-integration)
2. [Hermes Agent (Nous Research) Integration](#2-hermes-agent-nous-research-integration)
3. [OpenClaw Integration](#3-openclaw-integration)
4. [Comparison Summary](#4-comparison-summary)

---

### 1. Claude Code (Anthropic) Integration

#### 1.1 Overview

Claude Code is Anthropic's command-line AI programming assistant that allows you to interact with Claude directly in the terminal. By adding a `CLAUDE.md` configuration file in your project root directory, Claude Code can automatically recognize SRE Ops-Toolkit skill instructions, enabling server health checks, troubleshooting, and other operations tasks.

**Key Advantages:**
- Supports one-shot execution (Print Mode) and interactive conversation (Interactive Mode)
- Customizable slash commands and dedicated agents
- Works with tmux for long-running, multi-turn debugging sessions

#### 1.2 Installation & Configuration

**Step 1: Create CLAUDE.md in your project root**

`CLAUDE.md` is Claude Code's project-level instruction file, automatically read when Claude starts.

```bash
# Navigate to your project directory
cd /path/to/your-project

# Create CLAUDE.md
cat > CLAUDE.md << 'EOF'
# SRE Ops-Toolkit Skill Configuration

## Available Skill Commands

### Server Health Check
- Run full health check: execute ops-toolkit's health-check command to check CPU, memory, disk, network, and other metrics
- Check specific services: perform health checks on particular services (e.g., nginx, mysql, redis)

### Troubleshooting
- Analyze system logs: check key logs under /var/log and extract error information
- Network connectivity test: perform ping, traceroute, port scanning, and other network diagnostics

### Resource Analysis
- Memory usage analysis: list top memory-consuming processes and identify memory leaks
- Disk space analysis: check usage on each mount point and clean up temporary files

## Work Guidelines
- Must confirm before executing dangerous operations
- Output inspection results in a structured format (table + summary)
- Provide specific remediation suggestions when anomalies are detected
EOF
```

**Step 2: Create custom slash commands**

Slash commands let you trigger a health check with `/health-check` in one click, without writing long prompts every time.

```bash
# Create .claude/commands directory
mkdir -p .claude/commands

# Create health-check slash command
cat > .claude/commands/health-check.md << 'EOF'
Run an SRE server health check, performing the following checks:

1. System basic info (hostname, kernel version, uptime)
2. CPU usage and load
3. Memory usage (including Swap)
4. Disk space and usage
5. Key service status (nginx, mysql, redis)
6. Recent errors and warnings in system logs

Organize the results into a table and provide a summary and risk alerts at the end.
Arguments: $ARGUMENTS
EOF
```

> **Note:** `$ARGUMENTS` will be replaced with "check web nodes" when you type `/health-check check web nodes`.

**Step 3: Create a custom SRE Agent**

A custom Agent can pre-configure a role, allowing Claude to focus on SRE operations scenarios.

```bash
# Create .claude/agents directory
mkdir -p .claude/agents

# Create SRE Operator Agent
cat > .claude/agents/sre-operator.md << 'EOF'
You are a senior SRE operations engineer, skilled in Linux server management and troubleshooting.

## Responsibilities
- Perform server health checks
- Analyze system logs and metrics
- Identify root causes of failures and provide remediation plans
- Produce structured inspection reports

## Work Principles
1. Observe before acting: collect information first, then provide recommendations
2. Safety first: require double confirmation for restart, delete, and similar operations
3. Data-driven: all judgments based on actual metrics, no guessing
4. Report format: use tables + severity markers (✅ Normal / ⚠️ Warning / ❌ Critical)

## Common Command Library
- System overview: `uname -a`, `uptime`, `hostnamectl`
- CPU analysis: `top -bn1`, `mpstat`, `nproc`
- Memory analysis: `free -h`, `vmstat`, `ps aux --sort=-%mem | head`
- Disk analysis: `df -h`, `du -sh /var/log`, `iostat`
- Network check: `ss -tlnp`, `netstat -an | grep ESTABLISHED | wc -l`
- Service status: `systemctl status <service>`, `journalctl -u <service> --since "1 hour ago"`
- Log analysis: `journalctl -p err --since "1 hour ago"`, `dmesg -T | grep -i error`
EOF
```

#### 1.3 Basic Usage

**Print Mode (one-shot execution)**

Suitable for CI/CD pipelines, scheduled tasks, and other automation scenarios. Outputs results directly after execution.

```bash
# Basic health check: have Claude run a server health check and analyze the results
claude -p "Run a server health check and analyze the results" --allowedTools 'Read,Bash' --max-turns 10

# Health check with parameters: specify check scope
claude -p "Perform a health check on nginx and mysql services, focusing on connection count and response time" --allowedTools 'Read,Bash' --max-turns 10

# Output results to a file (suitable for archiving)
claude -p "Run a full health check, output a JSON format report" --allowedTools 'Read,Bash' --max-turns 10 > /tmp/health-report-$(date +%Y%m%d).txt
```

> **Parameter explanations:**
> - `-p`: Print mode, non-interactive, outputs results directly
> - `--allowedTools`: Restricts the tools Claude can use (Read for reading files, Bash for executing commands)
> - `--max-turns`: Maximum interaction turns, prevents infinite loops

**Interactive Mode**

Suitable for troubleshooting scenarios that require multi-turn conversation.

```bash
# Start interactive mode directly
claude

# Enter commands after starting
> Run a server health check
> (Claude executes and returns results)
> Disk usage is over 80%, help me analyze which directories are using the most space
> (Claude continues analyzing)
```

**Using slash commands**

```bash
# After starting Claude, enter a slash command directly
claude
> /health-check

# Slash command with arguments
> /health-check focus on checking database nodes
```

#### 1.4 Advanced Usage

**Using tmux for multi-turn debugging**

During server troubleshooting, you may need long-running, multi-turn conversations. Using tmux prevents session loss from SSH disconnections.

```bash
# Create a tmux session
tmux new-session -d -s sre-debug

# Start Claude interactive mode in tmux
tmux send-keys -t sre-debug 'claude' Enter

# Attach to the tmux session
tmux attach -t sre-debug

# Perform multi-turn debugging in Claude
> Database connection timeout, help me troubleshoot
> Check mysql connection count configuration and current connection status
> Check the slow query log for recent slow queries
> Provide optimization recommendations

# Detach tmux (session keeps running in the background)
# Press Ctrl+B then D

# Reconnect
tmux attach -t sre-debug
```

**Using the custom SRE Agent**

```bash
# Start the dedicated SRE operations Agent via the agent parameter
claude --agent sre-operator

# Or switch in interactive mode
claude
> /agent sre-operator
> Production service response is slow, help me do a full health check
```

**Integrating scheduled health checks in CI/CD**

```bash
# crontab scheduled task: run health check every day at 9 AM
crontab -e
# Add the following line:
0 9 * * * cd /path/to/project && claude -p "Run a daily health check, output warnings when anomalies are found" --allowedTools 'Read,Bash' --max-turns 10 >> /var/log/sre-daily-check.log 2>&1
```

#### 1.5 Example Scenario

**Scenario: Production service alert, rapid troubleshooting**

```bash
# Step 1: One-click health check to quickly identify the problem
claude -p "Received CPU alert, immediately run a health check: check CPU load, top processes, anomalies in system logs" --allowedTools 'Read,Bash' --max-turns 10

# Step 2: If deeper investigation is needed, start interactive mode
tmux new -s incident-debug
claude --agent sre-operator
> CPU load is as high as 32, top process is java, PID 12345
> Analyze this Java process's thread stack and GC status
> Check for OOM Killer records
> Provide emergency handling plan

# Step 3: After resolution, archive the inspection report
claude -p "Generate a post-incident review report for this failure, including timeline, root cause, and remediation" --allowedTools 'Read,Bash' --max-turns 10 > /tmp/incident-report-$(date +%Y%m%d%H%M).md
```

---

### 2. Hermes Agent (Nous Research) Integration

#### 2.1 Overview

Hermes Agent is an AI agent platform developed by Nous Research that supports a skill system, allowing you to extend capabilities by installing or copying skill packages. SRE Ops-Toolkit, as an official Hermes DevOps skill, supports advanced features such as session loading, task delegation, scheduled health checks, and Gateway Mode.

**Key Advantages:**
- Native skill system, install and use immediately
- Supports `delegate_task` for parallel execution of multiple SRE tasks
- Built-in Cron Job support
- Gateway Mode can trigger health checks from Telegram/Discord/Slack

#### 2.2 Installation & Configuration

**Method 1: Install via command line (recommended)**

```bash
# Use hermes built-in install command
hermes skills install ops-toolkit

# Verify installation
hermes skills list | grep ops-toolkit
# Expected output: ops-toolkit    devops    SRE Operations Health Check Toolkit    ✅ Installed
```

**Method 2: Manually copy the skill package**

If you don't have network access or need to make custom modifications, you can install manually:

```bash
# Create skill directory
mkdir -p ~/.hermes/skills/devops/ops-toolkit/

# Copy skill files (assuming you already have the ops-toolkit skill package)
cp -r /path/to/ops-toolkit/* ~/.hermes/skills/devops/ops-toolkit/

# Verify directory structure
ls ~/.hermes/skills/devops/ops-toolkit/
# Expected output: skill.yaml  commands/  templates/  README.md
```

#### 2.3 Basic Usage

**Loading the skill in a session**

```bash
# Method 1: Load in interactive mode
hermes
> /skill ops-toolkit
# Output: ✅ Skill ops-toolkit loaded, available commands: health-check, troubleshoot, resource-analyze

# Method 2: Specify the skill at startup
hermes -s ops-toolkit
# Automatically loads the ops-toolkit skill after startup
```

**Running basic health checks**

```bash
# Start Hermes with the skill
hermes -s ops-toolkit

# Run a full health check
> Run a server health check

# Specify check items
> Only check disk and memory usage

# Check a specific service
> Check the health status of the redis cluster
```

#### 2.4 Advanced Usage

**Using delegate_task for parallel SRE task execution**

`delegate_task` is Hermes's core capability, allowing you to dispatch multiple SRE tasks for parallel execution, significantly improving inspection efficiency.

```bash
hermes -s ops-toolkit

# Parallel health check across multiple server dimensions
> delegate_task: Execute the following tasks simultaneously:
> 1. Check CPU and memory on all web nodes
> 2. Check disk and connection count on database nodes
> 3. Analyze system log errors on all nodes
> Aggregate the report when complete

# Or a more concise syntax
> delegate_task parallel check web-group and db-group, compare resource usage between the two groups
```

> **How it works:** Hermes splits the task into multiple subtasks, assigns them to different sub-agents for parallel execution, and then aggregates the results.

**Setting up scheduled health checks (Cron Job)**

Use Cron Jobs to implement automatic scheduled health checks without manual triggering.

```bash
# Create a scheduled health check script
cat > ~/.hermes/cron/health-check-hourly.sh << 'SCRIPT'
#!/bin/bash
# Hourly automatic health check script
hermes -s ops-toolkit -c "Run a server health check, only output anomalies and warnings" \
  --output /tmp/sre-hourly-$(date +%Y%m%d%H).md \
  --quiet

# If anomalies are found, send a notification (requires notification channel configuration)
if grep -q "❌" /tmp/sre-hourly-$(date +%Y%m%d%H).md; then
  hermes gateway notify --channel slack --message "⚠️ Anomalies found during health check, see /tmp/sre-hourly-$(date +%Y%m%d%H).md for details"
fi
SCRIPT

chmod +x ~/.hermes/cron/health-check-hourly.sh

# Add crontab
crontab -e
# Add: run every hour
0 * * * * ~/.hermes/cron/health-check-hourly.sh >> /var/log/hermes-cron.log 2>&1

# Simpler approach: run health check at 8 AM and 8 PM daily
# 0 8,20 * * * hermes -s ops-toolkit -c "Run daily health check" --output /tmp/sre-check-$(date +\%Y\%m\%d).md
```

**Gateway Mode: Trigger health checks from chat platforms**

Gateway Mode lets Hermes listen on messaging platforms, allowing you to trigger health checks from chat messages anytime, anywhere.

```bash
# Start Hermes Gateway
hermes gateway start --skills ops-toolkit

# Configure messaging platform connections
hermes gateway config --platform telegram --token "YOUR_TELEGRAM_BOT_TOKEN"
hermes gateway config --platform discord --webhook-url "YOUR_DISCORD_WEBHOOK_URL"
hermes gateway config --platform slack --webhook-url "YOUR_SLACK_WEBHOOK_URL"
```

Triggering health checks from chat platforms:

```
# Send messages in Telegram / Discord / Slack:
/health-check
/health-check
/check database

# Hermes automatically executes the health check upon receiving the message and returns the results
# Bot replies:
# ✅ CPU: 32% | ⚠️ Memory: 82% | ✅ Disk: 45% | ❌ MySQL: connection limit exceeded
# Recommendation: MySQL connections have reached 480/500, consider checking slow queries or increasing max_connections
```

#### 2.5 Example Scenario

**Scenario: Multi-cluster daily health check + instant alerting**

```bash
# Step 1: Start Hermes and load the skill
hermes -s ops-toolkit

# Step 2: Parallel health check across multiple clusters
> delegate_task: Simultaneously run health checks on the following clusters
> - cluster-cn-east: check CPU, memory, disk
> - cluster-cn-south: check service status and network
> - cluster-us-west: check database connections and slow queries
> Output a comparison report, highlighting anomalies

# Step 3: Set up Gateway for instant alerting
hermes gateway start --skills ops-toolkit --platform telegram --token "BOT_TOKEN"

# Step 4: View from your phone via Telegram anytime
# Send: /health-check cluster-cn-east
# Bot instantly returns health check results
```

---

### 3. OpenClaw Integration

#### 3.1 Overview

OpenClaw is an open-source AI Agent framework that supports local skill extensions and gateway mode. SRE Ops-Toolkit can be installed as a local skill in the OpenClaw workspace, allowing you to run health checks locally via `openclaw agent --local`, or trigger them remotely from messaging platforms via Gateway Mode.

**Key Advantages:**
- Pure local execution, no cloud dependencies
- Lightweight skill management
- Supports triggering from Telegram/Discord/Slack and other platforms

#### 3.2 Installation & Configuration

**Step 1: Copy the skill to the OpenClaw workspace**

```bash
# Create OpenClaw skill directory
mkdir -p ~/.openclaw/skills/ops-toolkit/

# Copy skill files
cp -r /path/to/ops-toolkit/* ~/.openclaw/skills/ops-toolkit/

# Confirm files have been copied
ls ~/.openclaw/skills/ops-toolkit/
# Expected output: skill.yaml  commands/  README.md
```

**Step 2: Verify the skill is installed**

```bash
# List installed skills
openclaw skills list

# Expected output:
# NAME          CATEGORY    STATUS
# ops-toolkit   devops      ✅ installed
```

If it doesn't appear, check that the directory path is correct:

```bash
# Confirm directory structure
tree ~/.openclaw/skills/ops-toolkit/
# Should contain the skill.yaml configuration file
```

#### 3.3 Basic Usage

**Running a local health check**

```bash
# Run a health check using local mode
openclaw agent --local --skill ops-toolkit --prompt "Run a server health check"

# Shorter syntax (if the skill is loaded by default)
openclaw agent --local "Check system resource usage"
```

**Interactive health check**

```bash
# Start local interactive mode
openclaw agent --local --interactive

# Enter commands after starting
> Run disk space analysis
> Check nginx and mysql service status
> Analyze error logs from the last hour
```

#### 3.4 Advanced Usage

**Gateway Mode: Trigger health checks from messaging platforms**

After configuring the OpenClaw Gateway, you can trigger health checks from Telegram/Discord/Slack via messages.

```bash
# Start OpenClaw Gateway
openclaw gateway start --skills ops-toolkit

# Configure messaging platforms
openclaw gateway config --channel telegram --token "YOUR_BOT_TOKEN"
openclaw gateway config --channel discord --webhook "YOUR_WEBHOOK_URL"
openclaw gateway config --channel slack --webhook "YOUR_WEBHOOK_URL"
```

After triggering from a chat platform, OpenClaw executes the health check and sends the results via message:

```bash
# Proactively send a health check report to a specified chat from the command line
openclaw message send --channel telegram --target @mychat --message "Health check report"

# Send a full report
openclaw message send --channel discord --target #ops-alerts --message "Daily health check report has been generated, please see the attachment"
```

**Chat platform interaction example**

```
User: /health-check
OpenClaw Bot: 🔍 Running server health check...
OpenClaw Bot: ✅ CPU: 28% | ✅ Memory: 65% | ⚠️ Disk /data: 78% | ✅ nginx: running | ✅ mysql: running
OpenClaw Bot: ⚠️ Note: /data partition usage is approaching the 80% threshold, consider cleaning up old logs.

User: /check mysql
OpenClaw Bot: 🔍 Checking MySQL...
OpenClaw Bot: ✅ Service status: running (uptime 45d)
OpenClaw Bot: ✅ Current connections: 320/500
OpenClaw Bot: ⚠️ Slow queries: 12 in the last hour (>1s)
OpenClaw Bot: ✅ Replication lag: 0s
```

**Scheduled health checks (Cron)**

```bash
# Create a scheduled health check script
cat > /tmp/openclaw-daily-check.sh << 'SCRIPT'
#!/bin/bash
REPORT=$(openclaw agent --local --skill ops-toolkit --prompt "Run a daily health check, only output anomalies" 2>/dev/null)

if [ -n "$REPORT" ]; then
  # Send to Telegram
  openclaw message send --channel telegram --target @sre-alerts --message "$REPORT"
fi
SCRIPT

chmod +x /tmp/openclaw-daily-check.sh

# Add crontab: run every day at 9 AM
crontab -e
# Add:
0 9 * * * /tmp/openclaw-daily-check.sh
```

#### 3.5 Example Scenario

**Scenario: Remote health check from Telegram and get a report**

```bash
# Step 1: Make sure OpenClaw Gateway is running
openclaw gateway start --skills ops-toolkit --channel telegram --token "BOT_TOKEN"

# Step 2: Open Telegram on your phone and send commands to the Bot
# /health-check
# /health-check full
# /check redis

# Step 3: If you need to proactively push a report
openclaw agent --local --skill ops-toolkit --prompt "Run a full health check" > /tmp/report.md
openclaw message send --channel telegram --target @mychat --message "📋 Today's health check report" --attach /tmp/report.md

# Step 4: Instant notification during incidents
openclaw agent --local --skill ops-toolkit --prompt "Disk alert detected, immediately analyze large files on /data partition" > /tmp/disk-alert.md
openclaw message send --channel slack --target #incident --message "🚨 Disk alert details" --attach /tmp/disk-alert.md
```

---

### 4. Comparison Summary

| Feature | Claude Code | Hermes Agent | OpenClaw |
|---------|-------------|--------------|----------|
| **Installation** | Project root `CLAUDE.md` | `hermes skills install` or manual copy | Manual copy to `~/.openclaw/skills/` |
| **One-shot execution** | `claude -p "command"` | `hermes -s ops-toolkit -c "command"` | `openclaw agent --local "command"` |
| **Interactive mode** | `claude` | `hermes` + `/skill ops-toolkit` | `openclaw agent --local --interactive` |
| **Parallel tasks** | Not natively supported | `delegate_task` natively supported | Not natively supported |
| **Scheduled health checks** | crontab + `claude -p` | Built-in Cron support | crontab + `openclaw agent --local` |
| **Messaging platform integration** | Not supported | Gateway Mode (Telegram/Discord/Slack) | Gateway Mode (Telegram/Discord/Slack) |
| **Custom commands** | Slash Command (`.claude/commands/`) | Skill built-in commands | Skill built-in commands |
| **Custom Agent** | `.claude/agents/` | Skill configuration | None |
| **Best suited for** | Dev environments, CI/CD | Multi-cluster ops, team collaboration | Lightweight local ops, messaging integration |
| **Learning curve** | ⭐ Easy | ⭐⭐ Moderate | ⭐ Easy |

#### Quick Selection Guide

- **Individual developers / small teams** → Choose **Claude Code**, simple setup, use directly in the terminal
- **Mid-to-large SRE teams** → Choose **Hermes Agent**, parallel tasks + scheduled health checks + messaging notifications all in one
- **Need messaging platform integration / pure local execution** → Choose **OpenClaw**, lightweight + Gateway Mode

---

> 💡 **Tip:** The three agents are not mutually exclusive — you can mix and match based on your scenario. For example: use Claude Code for quick troubleshooting during daily development, Hermes Agent for parallel production health checks, and OpenClaw Gateway for on-the-go monitoring from your phone.

---

## License

This project is licensed under the **MIT License**. You are free to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, subject to the following condition:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

See the [LICENSE](LICENSE) file for the full license text.

---

## Language / 语言

This README is available in:

- **English** (this file)
- **中文 (Chinese)**: [README.md](README.md)

---

**Made with care by [dockercore](https://github.com/dockercore)**
