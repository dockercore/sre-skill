#!/usr/bin/env bash
# =============================================================================
# health-check.sh — Server Health Check Script / 服务器健康巡检脚本
# =============================================================================
#
# Description / 描述:
#   Automatically checks server health across 7 categories:
#   自动检查服务器的 7 大健康类别：
#   1. System Info    — hostname, kernel, uptime / 系统信息
#   2. CPU            — usage, cores, load average / CPU 状态
#   3. Memory         — RAM and swap usage / 内存和交换分区
#   4. Disk           — filesystem usage with alerts / 磁盘使用
#   5. Network        — listening ports, connections / 网络
#   6. Processes       — total count, zombies, top consumers / 进程
#   7. Docker         — daemon status, containers, images / Docker 状态
#
# Usage / 用法:
#   bash health-check.sh              # Quick mode (default) / 快速模式（默认）
#   bash health-check.sh --quick      # Quick mode / 快速模式
#   bash health-check.sh --full      # Full mode (includes network interfaces, container details)
#                                    # 完整模式（包含网络接口、容器详情）
#   bash health-check.sh --help      # Show help / 显示帮助
#
# Compatibility / 兼容性:
#   - Linux (Ubuntu/Debian/CentOS/RHEL) — full support
#   - macOS (Darwin) — auto-detected, uses equivalent commands
#
# License: MIT
# Author: dockercore
# =============================================================================

set -uo pipefail

# ---------------------------------------------------------------------------
# Color codes for terminal output / 终端输出颜色码
# ---------------------------------------------------------------------------
RED='\033[0;31m'       # Critical / 严重
GREEN='\033[0;32m'     # OK / 正常
YELLOW='\033[1;33m'    # Warning / 警告
CYAN='\033[0;36m'      # Header / 标题
BOLD='\033[1m'         # Bold / 加粗
NC='\033[0m'           # Reset / 重置

# ---------------------------------------------------------------------------
# Helper functions / 辅助函数
# ---------------------------------------------------------------------------
ok()   { echo -e "  ${GREEN}[OK]${NC}   $1"; }
warn() { echo -e "  ${YELLOW}[WARN]${NC} $1"; WARN_COUNT=$((WARN_COUNT + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAIL_COUNT=$((FAIL_COUNT + 1)); }

# ---------------------------------------------------------------------------
# Show help / 显示帮助信息
# ---------------------------------------------------------------------------
show_help() {
  cat << 'HELP'
health-check.sh — Server Health Check Script / 服务器健康巡检脚本

USAGE / 用法:
  bash health-check.sh [OPTIONS]

OPTIONS / 选项:
  --quick, -q    Quick mode (default). Shows essential health info.
                 快速模式（默认）。显示基本健康信息。
  --full, -f     Full mode. Also shows network interfaces and Docker container details.
                 完整模式。额外显示网络接口和 Docker 容器详情。
  --help, -h     Show this help message.
                 显示此帮助信息。

OUTPUT LEGEND / 输出图例:
  [OK]           Normal — no action needed / 正常，无需操作
  [WARN]         Warning — should be investigated soon / 警告，应尽快排查
  [FAIL]         Critical — must fix immediately / 严重，必须立即处理

ALERT THRESHOLDS / 告警阈值:
  CPU usage:     WARN > 70%    FAIL > 90%
  Memory usage:  WARN > 80%    FAIL > 90%
  Swap usage:    WARN > 30%    FAIL > 50%
  Disk usage:    WARN > 80%    FAIL > 90%

EXAMPLES / 示例:
  bash health-check.sh                  # Quick check / 快速检查
  bash health-check.sh --full           # Detailed check / 详细检查
  bash health-check.sh --full 2>&1 | tee health-report.txt  # Save report / 保存报告

COMPATIBILITY / 兼容性:
  Linux (Ubuntu/Debian/CentOS/RHEL) — full support
  macOS (Darwin) — auto-detected, equivalent commands used

LICENSE: MIT
HELP
}

# ---------------------------------------------------------------------------
# Counters for summary / 统计计数器
# ---------------------------------------------------------------------------
WARN_COUNT=0
FAIL_COUNT=0

# ---------------------------------------------------------------------------
# Parse arguments / 解析参数
# ---------------------------------------------------------------------------
MODE="--quick"
for arg in "$@"; do
  case "$arg" in
    --quick|-q)  MODE="--quick" ;;
    --full|-f)   MODE="--full" ;;
    --help|-h)   show_help; exit 0 ;;
    *)           echo "Unknown argument: $arg"; show_help; exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Detect operating system / 检测操作系统
# ---------------------------------------------------------------------------
OS_TYPE=$(uname -s)    # "Linux" or "Darwin" (macOS)

# ---------------------------------------------------------------------------
# Print header / 打印标题
# ---------------------------------------------------------------------------
echo "========================================="
echo -e "  ${BOLD}Server Health Check / 服务器健康巡检${NC}"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "  System / 系统: ${OS_TYPE}"
echo "  Mode / 模式: ${MODE}"
echo "========================================="

# ===========================================================================
# [1] System Information / 系统基本信息
# ===========================================================================
echo ""
echo -e "  ${CYAN}[1] System Info / 系统信息${NC}"
echo "  ─────────────────────────────────────"
echo "  主机名 (Hostname):     $(hostname)"
echo "  内核 (Kernel):          $(uname -r)"
echo "  运行时间 (Uptime):     $(uptime -p 2>/dev/null || uptime | sed 's/.*up/up/' | cut -d, -f1-3)"
echo "  当前用户 (User):       $(whoami)"

# ===========================================================================
# [2] CPU Check / CPU 检查
# ===========================================================================
echo ""
echo -e "  ${CYAN}[2] CPU / 处理器${NC}"
echo "  ─────────────────────────────────────"
if [ "$OS_TYPE" = "Darwin" ]; then
  # macOS: top -l 1 outputs "CPU usage: 5.2% user, 12.3% sys, 82.5% idle"
  CPU_INFO=$(top -l 1 -n 0 2>/dev/null | grep "CPU usage")
  if [ -n "$CPU_INFO" ]; then
    CPU_IDLE=$(echo "$CPU_INFO" | awk -F', ' '{print $3}' | awk '{print $1}' | cut -d. -f1)
    CPU_USAGE=$((100 - ${CPU_IDLE:-0}))
    if [ "$CPU_USAGE" -gt 90 ]; then
      fail "CPU 使用率 (Usage) ${CPU_USAGE}% — 服务器可能无响应！/ Server may be unresponsive!"
    elif [ "$CPU_USAGE" -gt 70 ]; then
      warn "CPU 使用率 (Usage) ${CPU_USAGE}% — 建议排查高负载进程 / Check high-load processes"
    else
      ok "CPU 使用率 (Usage) ${CPU_USAGE}%"
    fi
  else
    echo "  ⚠ 无法获取 CPU 信息 / Cannot get CPU info"
  fi
  CPU_CORES=$(sysctl -n hw.ncpu 2>/dev/null || echo 'N/A')
  echo "  CPU 核心数 (Cores):    ${CPU_CORES}"
  LOAD=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $2" "$3" "$4}')
  if [ -n "$LOAD" ]; then
    echo "  负载均值 (Load Avg):   ${LOAD}"
    echo "  └ 1min / 5min / 15min (对比核心数 ${CPU_CORES} 判断负载是否过高)"
    echo "    └ Load < 核心数 = 健康 / Load < cores = healthy"
  fi
elif [ "$OS_TYPE" = "Linux" ]; then
  if command -v top &>/dev/null; then
    CPU_IDLE=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $8}' | cut -d. -f1)
    CPU_USAGE=$((100 - ${CPU_IDLE:-0}))
    if [ "$CPU_USAGE" -gt 90 ]; then
      fail "CPU 使用率 (Usage) ${CPU_USAGE}% — 服务器可能无响应！"
    elif [ "$CPU_USAGE" -gt 70 ]; then
      warn "CPU 使用率 (Usage) ${CPU_USAGE}% — 建议排查高负载进程"
    else
      ok "CPU 使用率 (Usage) ${CPU_USAGE}%"
    fi
  fi
  CPU_CORES=$(nproc 2>/dev/null || echo 'N/A')
  echo "  CPU 核心数 (Cores):    ${CPU_CORES}"
  if [ -f /proc/loadavg ]; then
    LOAD=$(cat /proc/loadavg | awk '{print $1" "$2" "$3}')
    echo "  负载均值 (Load Avg):   ${LOAD}"
    echo "  └ 1min / 5min / 15min (对比核心数 ${CPU_CORES} 判断负载是否过高)"
  fi
else
  echo "  ⚠ 不支持的系统 (Unsupported OS): $OS_TYPE"
fi

# ===========================================================================
# [3] Memory Check / 内存检查
# ===========================================================================
echo ""
echo -e "  ${CYAN}[3] Memory / 内存${NC}"
echo "  ─────────────────────────────────────"
if [ "$OS_TYPE" = "Darwin" ]; then
  if command -v vm_stat &>/dev/null; then
    # macOS: vm_stat reports page counts. Each page = 4096 bytes.
    PAGES_FREE=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
    PAGES_ACTIVE=$(vm_stat | grep "Pages active" | awk '{print $3}' | tr -d '.')
    PAGES_INACTIVE=$(vm_stat | grep "Pages inactive" | awk '{print $3}' | tr -d '.')
    PAGES_WIRED=$(vm_stat | grep "Pages wired down" | awk '{print $4}' | tr -d '.')
    PAGES_SPEC=$(vm_stat | grep "Pages speculative" | awk '{print $3}' | tr -d '.')
    PAGE_SIZE=4096
    MEM_TOTAL_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo 0)
    MEM_TOTAL=$((MEM_TOTAL_BYTES / 1024 / 1024))
    MEM_USED=$(( (PAGES_ACTIVE + PAGES_WIRED + PAGES_SPEC) * PAGE_SIZE / 1024 / 1024))
    MEM_AVAIL=$(( (PAGES_FREE + PAGES_INACTIVE) * PAGE_SIZE / 1024 / 1024 ))
    if [ "$MEM_TOTAL" -gt 0 ]; then
      MEM_PCT=$((MEM_USED * 100 / MEM_TOTAL))
    else
      MEM_PCT=0
    fi
    if [ "$MEM_PCT" -gt 90 ]; then
      fail "内存使用率 (Memory) ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M) — 可能触发 OOM 杀进程！"
    elif [ "$MEM_PCT" -gt 80 ]; then
      warn "内存使用率 (Memory) ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M) — 建议排查内存大户"
    else
      ok "内存使用率 (Memory) ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M)"
    fi
    echo "  可用内存 (Available):  ${MEM_AVAIL}M (含可回收缓存 / includes reclaimable cache)"
    # macOS Swap
    SWAP_LINE=$(sysctl vm.swapusage 2>/dev/null || true)
    if [ -n "$SWAP_LINE" ]; then
      SWAP_USED=$(echo "$SWAP_LINE" | grep "used" | sed "s/.*used = //" | cut -d. -f1 | tr -d ' ')
      SWAP_TOTAL=$(echo "$SWAP_LINE" | grep "total" | sed "s/.*total = //" | cut -d. -f1 | tr -d ' ')
      if [ -n "$SWAP_TOTAL" ] && [ "$SWAP_TOTAL" -gt 0 ] 2>/dev/null; then
        SWAP_PCT=$((SWAP_USED * 100 / SWAP_TOTAL))
        if [ "$SWAP_PCT" -gt 50 ]; then
          fail "Swap 使用率 ${SWAP_PCT}% (${SWAP_USED}M/${SWAP_TOTAL}M) — 内存严重不足！"
        elif [ "$SWAP_PCT" -gt 30 ]; then
          warn "Swap 使用率 ${SWAP_PCT}% (${SWAP_USED}M/${SWAP_TOTAL}M) — 大量使用 Swap 影响性能"
        else
          ok "Swap 使用率 ${SWAP_PCT}% (${SWAP_USED}M/${SWAP_TOTAL}M)"
        fi
      else
        ok "Swap 未使用或未配置 (Not used or not configured)"
      fi
    else
      ok "Swap 未使用或未配置 (Not used or not configured)"
    fi
  else
    echo "  ⚠ vm_stat 不可用，跳过内存检查 / vm_stat unavailable, skipping"
  fi
elif [ "$OS_TYPE" = "Linux" ]; then
  if command -v free &>/dev/null; then
    MEM_INFO=$(free -m | awk '/^Mem:/ {print $2,$3,$4,$6,$7}')
    MEM_TOTAL=$(echo "$MEM_INFO" | awk '{print $1}')
    MEM_USED=$(echo "$MEM_INFO" | awk '{print $2}')
    MEM_AVAIL=$(echo "$MEM_INFO" | awk '{print $3}')
    if [ "$MEM_TOTAL" -gt 0 ]; then
      MEM_PCT=$((MEM_USED * 100 / MEM_TOTAL))
    else
      MEM_PCT=0
    fi
    if [ "$MEM_PCT" -gt 90 ]; then
      fail "内存使用率 (Memory) ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M) — 可能触发 OOM 杀进程！"
    elif [ "$MEM_PCT" -gt 80 ]; then
      warn "内存使用率 (Memory) ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M) — 建议排查内存大户"
    else
      ok "内存使用率 (Memory) ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M)"
    fi
    echo "  可用内存 (Available):  ${MEM_AVAIL}M (含可回收缓存 / includes reclaimable cache)"
    SWAP_INFO=$(free -m | awk '/^Swap:/ {print $2,$3}')
    SWAP_TOTAL=$(echo "$SWAP_INFO" | awk '{print $1}')
    SWAP_USED=$(echo "$SWAP_INFO" | awk '{print $2}')
    if [ "$SWAP_TOTAL" -gt 0 ] && [ "$SWAP_USED" -gt 0 ]; then
      SWAP_PCT=$((SWAP_USED * 100 / SWAP_TOTAL))
      if [ "$SWAP_PCT" -gt 50 ]; then
        fail "Swap 使用率 ${SWAP_PCT}% (${SWAP_USED}M/${SWAP_TOTAL}M) — 内存严重不足！"
      elif [ "$SWAP_PCT" -gt 30 ]; then
        warn "Swap 使用率 ${SWAP_PCT}% (${SWAP_USED}M/${SWAP_TOTAL}M) — 大量使用 Swap 影响性能"
      else
        ok "Swap 使用率 ${SWAP_PCT}% (${SWAP_USED}M/${SWAP_TOTAL}M)"
      fi
    else
      ok "Swap 未使用或未配置 (Not used or not configured)"
    fi
  else
    echo "  ⚠ free 命令不可用，跳过内存检查 / free command unavailable, skipping"
  fi
fi

# ===========================================================================
# [4] Disk Check / 磁盘检查
# ===========================================================================
echo ""
echo -e "  ${CYAN}[4] Disk / 磁盘${NC}"
echo "  ─────────────────────────────────────"
# Unified approach for both Linux and macOS
df -h 2>/dev/null | tail -n +2 | while IFS= read -r line; do
  PCT=$(echo "$line" | awk '{print $5}' | tr -d '%')
  # Skip lines where percentage is not a number
  if ! echo "$PCT" | grep -qE '^[0-9]+$'; then
    continue
  fi
  MOUNT=$(echo "$line" | awk '{print $NF}')
  SIZE=$(echo "$line" | awk '{print $2}')
  USED=$(echo "$line" | awk '{print $3}')
  AVAIL=$(echo "$line" | awk '{print $4}')
  if [ "$PCT" -gt 90 ]; then
    fail "挂载 (Mount): ${MOUNT}  大小: ${SIZE}  已用: ${USED}  可用: ${AVAIL}  使用率: ${PCT}%"
  elif [ "$PCT" -gt 80 ]; then
    warn "挂载 (Mount): ${MOUNT}  大小: ${SIZE}  已用: ${USED}  可用: ${AVAIL}  使用率: ${PCT}%"
  else
    ok "挂载 (Mount): ${MOUNT}  大小: ${SIZE}  已用: ${USED}  可用: ${AVAIL}  使用率: ${PCT}%"
  fi
done

# ===========================================================================
# [5] Network Check / 网络检查
# ===========================================================================
echo ""
echo -e "  ${CYAN}[5] Network / 网络${NC}"
echo "  ─────────────────────────────────────"
if [ "$OS_TYPE" = "Darwin" ]; then
  LISTENING=$(lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | awk 'NR>1{print $9}' | rev | cut -d: -f1 | rev | sort -un | head -20)
  PORT_COUNT=$(echo "$LISTENING" | grep -cE '^[0-9]+$' 2>/dev/null || echo 0)
  ok "监听端口数 (Listening ports): ${PORT_COUNT}"
  if [ "$PORT_COUNT" -gt 0 ]; then
    echo "  端口列表 (Port list):   $(echo $LISTENING | tr '\n' ' ')"
  fi
elif [ "$OS_TYPE" = "Linux" ]; then
  if command -v ss &>/dev/null; then
    LISTENING_PORTS=$(ss -tlnp 2>/dev/null | grep LISTEN | awk '{print $4}' | rev | cut -d: -f1 | rev | sort -un | head -20)
    PORT_COUNT=$(echo "$LISTENING_PORTS" | grep -c . 2>/dev/null || echo 0)
    ok "监听端口数 (Listening ports): ${PORT_COUNT}"
    echo "  端口列表 (Port list):   $(echo $LISTENING_PORTS | tr '\n' ' ')"
    CONN_COUNT=$(ss -s 2>/dev/null | grep estab | awk '{print $2}' || echo "N/A")
    echo "  ESTABLISHED 连接:       ${CONN_COUNT}"
  elif command -v netstat &>/dev/null; then
    LISTENING=$(netstat -tlnp 2>/dev/null | grep LISTEN | wc -l)
    ok "监听端口数 (Listening ports): ${LISTENING}"
  fi
fi

# Full mode: show network interfaces
if [ "$MODE" = "--full" ]; then
  echo ""
  echo "  网络接口 (Interfaces):"
  if command -v ip &>/dev/null; then
    ip -br addr 2>/dev/null | while IFS= read -r line; do
      echo "    $line"
    done
  elif command -v ifconfig &>/dev/null; then
    ifconfig 2>/dev/null | grep -E "^[a-z]" | while IFS= read -r line; do
      echo "    $line"
    done
  fi
fi

# ===========================================================================
# [6] Process Check / 进程检查
# ===========================================================================
echo ""
echo -e "  ${CYAN}[6] Processes / 进程${NC}"
echo "  ─────────────────────────────────────"
PROC_COUNT=$(ps aux 2>/dev/null | wc -l)
ok "进程总数 (Total processes): $((PROC_COUNT - 1))"
ZOMBIE=$(ps aux 2>/dev/null | awk '$8=="Z"' | wc -l)
if [ "$ZOMBIE" -gt 5 ]; then
  fail "僵尸进程 (Zombies): ${ZOMBIE} 个 — 可能存在程序缺陷！"
elif [ "$ZOMBIE" -gt 0 ]; then
  warn "僵尸进程 (Zombies): ${ZOMBIE} 个 — 偶尔出现通常无碍，持续增多需排查"
else
  ok "无僵尸进程 (No zombie processes)"
fi

# Top CPU processes
echo ""
echo "  Top 5 CPU 进程 (by CPU usage):"
if [ "$OS_TYPE" = "Darwin" ]; then
  ps aux -r 2>/dev/null | head -6 | awk 'NR==1{printf "    %-10s %-8s %6s %6s %s\n","COMMAND","USER","CPU%","MEM%","PID"; next} {printf "    %-10s %-8s %6s %6s %s\n",substr($11,1,10),$1,$3,$4,$2}' | head -6
else
  ps aux --sort=-%cpu 2>/dev/null | head -6 | awk 'NR==1{printf "    %-10s %-8s %6s %6s %s\n","COMMAND","USER","CPU%","MEM%","PID"; next} {printf "    %-10s %-8s %6s %6s %s\n",substr($11,1,10),$1,$3,$4,$2}' | head -6
fi

# Top memory processes
echo ""
echo "  Top 5 内存进程 (by Memory usage):"
if [ "$OS_TYPE" = "Darwin" ]; then
  ps aux -m 2>/dev/null | head -6 | awk 'NR==1{printf "    %-10s %-8s %6s %6s %s\n","COMMAND","USER","CPU%","MEM%","PID"; next} {printf "    %-10s %-8s %6s %6s %s\n",substr($11,1,10),$1,$3,$4,$2}' | head -6
else
  ps aux --sort=-%mem 2>/dev/null | head -6 | awk 'NR==1{printf "    %-10s %-8s %6s %6s %s\n","COMMAND","USER","CPU%","MEM%","PID"; next} {printf "    %-10s %-8s %6s %6s %s\n",substr($11,1,10),$1,$3,$4,$2}' | head -6
fi

# ===========================================================================
# [7] Service Check (systemd only, Linux) / 服务检查
# ===========================================================================
if [ "$OS_TYPE" = "Linux" ] && command -v systemctl &>/dev/null; then
  echo ""
  echo -e "  ${CYAN}[7] Services / 服务状态${NC}"
  echo "  ─────────────────────────────────────"
  FAILED=$(systemctl --failed --no-legend 2>/dev/null)
  if [ -z "$FAILED" ]; then
    ok "无失败服务 (No failed services)"
  else
    FAIL_SERVICE_COUNT=$(echo "$FAILED" | wc -l)
    fail "${FAIL_SERVICE_COUNT} 个服务失败 (${FAIL_SERVICE_COUNT} failed service(s)):"
    echo "$FAILED" | while IFS= read -r line; do
      echo "    $line"
    done
  fi
fi

# ===========================================================================
# [8] Docker Check / Docker 检查
# ===========================================================================
if command -v docker &>/dev/null; then
  echo ""
  SECTION_NUM="8"
  if [ "$OS_TYPE" = "Darwin" ]; then
    SECTION_NUM="7"
  fi
  echo -e "  ${CYAN}[${SECTION_NUM}] Docker / 容器${NC}"
  echo "  ─────────────────────────────────────"
  if docker info &>/dev/null; then
    ok "Docker 守护进程运行中 (Daemon is running)"
    CONTAINERS=$(docker ps -q | wc -l)
    STOPPED=$(docker ps -qf "status=exited" | wc -l)
    IMAGES=$(docker images -q | wc -l)
    echo "  运行容器 (Running):    ${CONTAINERS}"
    echo "  停止容器 (Stopped):    ${STOPPED}"
    echo "  镜像数 (Images):       ${IMAGES}"
    if [ "$MODE" = "--full" ] && [ "$CONTAINERS" -gt 0 ]; then
      echo ""
      echo "  容器详情 (Container details):"
      docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" 2>/dev/null | head -20 | while IFS= read -r line; do
        echo "    $line"
      done
    fi
    DOCKER_DISK=$(docker system df 2>/dev/null | head -2 | tail -1 | awk '{print $3}')
    if [ -n "$DOCKER_DISK" ]; then
      echo "  Docker 磁盘 (Disk):    ${DOCKER_DISK}"
    fi
  else
    fail "Docker 守护进程未运行 (Daemon is not running)"
    echo "  └ 启动方式 (How to start): sudo systemctl start docker (Linux) / open -a Docker (macOS)"
  fi
fi

# ===========================================================================
# Summary / 巡检总结
# ===========================================================================
echo ""
echo "========================================="
echo -e "  ${BOLD}巡检总结 / Summary${NC}"
echo "========================================="
if [ "$FAIL_COUNT" -gt 0 ]; then
  echo -e "  ${RED}严重问题 (Critical): ${FAIL_COUNT} 项 — 必须立即处理！/ Must fix immediately!${NC}"
fi
if [ "$WARN_COUNT" -gt 0 ]; then
  echo -e "  ${YELLOW}警告 (Warnings): ${WARN_COUNT} 项 — 建议尽快排查 / Should investigate soon${NC}"
fi
if [ "$FAIL_COUNT" -eq 0 ] && [ "$WARN_COUNT" -eq 0 ]; then
  echo -e "  ${GREEN}所有检查通过 (All checks passed)${NC}"
fi
echo ""
echo "  巡检完成 (Check complete) — $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================="

# Exit with non-zero if critical issues found
if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
