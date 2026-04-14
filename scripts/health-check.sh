#!/usr/bin/env bash
# 服务器健康巡检脚本
# 用法: bash health-check.sh [--full|--quick]
# 支持 Linux 和 macOS
set -uo pipefail

MODE="${1:--quick}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}[OK]${NC}   $1"; }
warn() { echo -e "  ${YELLOW}[WARN]${NC} $1"; }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; }

OS_TYPE=$(uname -s)

echo "========================================="
echo "  服务器健康巡检  $(date '+%Y-%m-%d %H:%M:%S')"
echo "  系统: ${OS_TYPE}"
echo "========================================="

# --- 系统基本信息 ---
echo ""
echo "[系统信息]"
echo "  主机名:   $(hostname)"
echo "  内核:     $(uname -r)"
echo "  运行时间: $(uptime -p 2>/dev/null || uptime | sed 's/.*up/up/' | cut -d, -f1-3)"
echo "  当前用户: $(whoami)"

# --- CPU 检查 ---
echo ""
echo "[CPU]"
if [ "$OS_TYPE" = "Darwin" ]; then
  # macOS: top -l 1 输出格式: CPU usage: 5.2% user, 12.3% sys, 82.5% idle
  CPU_INFO=$(top -l 1 -n 0 2>/dev/null | grep "CPU usage")
  if [ -n "$CPU_INFO" ]; then
    CPU_IDLE=$(echo "$CPU_INFO" | awk -F', ' '{print $3}' | awk '{print $1}' | cut -d. -f1)
    CPU_USAGE=$((100 - ${CPU_IDLE:-0}))
    if [ "$CPU_USAGE" -gt 90 ]; then
      fail "CPU 使用率 ${CPU_USAGE}%"
    elif [ "$CPU_USAGE" -gt 70 ]; then
      warn "CPU 使用率 ${CPU_USAGE}%"
    else
      ok "CPU 使用率 ${CPU_USAGE}%"
    fi
  else
    echo "  无法获取 CPU 信息"
  fi
  echo "  CPU 核心数: $(sysctl -n hw.ncpu 2>/dev/null || echo 'N/A')"
  LOAD=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $2" "$3" "$4}')
  if [ -n "$LOAD" ]; then
    echo "  负载均值:   ${LOAD}"
  fi
elif [ "$OS_TYPE" = "Linux" ]; then
  if command -v top &>/dev/null; then
    CPU_IDLE=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $8}' | cut -d. -f1)
    CPU_USAGE=$((100 - ${CPU_IDLE:-0}))
    if [ "$CPU_USAGE" -gt 90 ]; then
      fail "CPU 使用率 ${CPU_USAGE}%"
    elif [ "$CPU_USAGE" -gt 70 ]; then
      warn "CPU 使用率 ${CPU_USAGE}%"
    else
      ok "CPU 使用率 ${CPU_USAGE}%"
    fi
  fi
  echo "  CPU 核心数: $(nproc 2>/dev/null || echo 'N/A')"
  if [ -f /proc/loadavg ]; then
    echo "  负载均值:   $(cat /proc/loadavg | awk '{print $1" "$2" "$3}')"
  fi
else
  echo "  不支持的系统: $OS_TYPE"
fi

# --- 内存检查 ---
echo ""
echo "[内存]"
if [ "$OS_TYPE" = "Darwin" ]; then
  # macOS: 使用 vm_stat
  if command -v vm_stat &>/dev/null; then
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
      fail "内存使用率 ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M)"
    elif [ "$MEM_PCT" -gt 80 ]; then
      warn "内存使用率 ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M)"
    else
      ok "内存使用率 ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M)"
    fi
    echo "  可用内存:   ${MEM_AVAIL}M"
    # macOS Swap
    SWAP_LINE=$(sysctl vm.swapusage 2>/dev/null || true)
    if [ -n "$SWAP_LINE" ]; then
      SWAP_USED=$(echo "$SWAP_LINE" | grep "used" | sed "s/.*used = //" | cut -d. -f1 | tr -d ' ')
      SWAP_TOTAL=$(echo "$SWAP_LINE" | grep "total" | sed "s/.*total = //" | cut -d. -f1 | tr -d ' ')
      if [ -n "$SWAP_TOTAL" ] && [ "$SWAP_TOTAL" -gt 0 ] 2>/dev/null; then
        SWAP_PCT=$((SWAP_USED * 100 / SWAP_TOTAL))
        if [ "$SWAP_PCT" -gt 50 ]; then
          warn "Swap 使用率 ${SWAP_PCT}% (${SWAP_USED}M/${SWAP_TOTAL}M)"
        else
          ok "Swap 使用率 ${SWAP_PCT}% (${SWAP_USED}M/${SWAP_TOTAL}M)"
        fi
      else
        ok "Swap 未使用或未配置"
      fi
    else
      ok "Swap 未使用或未配置"
    fi
  else
    echo "  vm_stat 不可用，跳过内存检查"
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
      fail "内存使用率 ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M)"
    elif [ "$MEM_PCT" -gt 80 ]; then
      warn "内存使用率 ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M)"
    else
      ok "内存使用率 ${MEM_PCT}% (${MEM_USED}M/${MEM_TOTAL}M)"
    fi
    echo "  可用内存:   ${MEM_AVAIL}M"
    SWAP_INFO=$(free -m | awk '/^Swap:/ {print $2,$3}')
    SWAP_TOTAL=$(echo "$SWAP_INFO" | awk '{print $1}')
    SWAP_USED=$(echo "$SWAP_INFO" | awk '{print $2}')
    if [ "$SWAP_TOTAL" -gt 0 ] && [ "$SWAP_USED" -gt 0 ]; then
      SWAP_PCT=$((SWAP_USED * 100 / SWAP_TOTAL))
      if [ "$SWAP_PCT" -gt 50 ]; then
        warn "Swap 使用率 ${SWAP_PCT}% (${SWAP_USED}M/${SWAP_TOTAL}M)"
      else
        ok "Swap 使用率 ${SWAP_PCT}% (${SWAP_USED}M/${SWAP_TOTAL}M)"
      fi
    else
      ok "Swap 未使用或未配置"
    fi
  else
    echo "  free 命令不可用，跳过内存检查"
  fi
fi

# --- 磁盘检查 ---
echo ""
echo "[磁盘]"
df -h 2>/dev/null | tail -n +2 | while IFS= read -r line; do
  PCT=$(echo "$line" | awk '{print $5}' | tr -d '%')
  # 跳过无法解析为数字的行
  if ! echo "$PCT" | grep -qE '^[0-9]+$'; then
    continue
  fi
  MOUNT=$(echo "$line" | awk '{print $NF}')
  SIZE=$(echo "$line" | awk '{print $2}')
  USED=$(echo "$line" | awk '{print $3}')
  AVAIL=$(echo "$line" | awk '{print $4}')
  if [ "$PCT" -gt 90 ]; then
    fail "挂载: ${MOUNT}  大小: ${SIZE}  已用: ${USED}  可用: ${AVAIL}  使用率: ${PCT}%"
  elif [ "$PCT" -gt 80 ]; then
    warn "挂载: ${MOUNT}  大小: ${SIZE}  已用: ${USED}  可用: ${AVAIL}  使用率: ${PCT}%"
  else
    ok "挂载: ${MOUNT}  大小: ${SIZE}  已用: ${USED}  可用: ${AVAIL}  使用率: ${PCT}%"
  fi
done

# --- 网络检查 ---
echo ""
echo "[网络]"
if [ "$OS_TYPE" = "Darwin" ]; then
  # macOS: 用 netstat / lsof
  LISTENING=$(lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | awk 'NR>1{print $9}' | rev | cut -d: -f1 | rev | sort -un | head -20)
  PORT_COUNT=$(echo "$LISTENING" | grep -cE '^[0-9]+$' 2>/dev/null || echo 0)
  ok "监听端口数: ${PORT_COUNT}"
  if [ "$PORT_COUNT" -gt 0 ]; then
    echo "  端口列表:   $(echo $LISTENING | tr '\n' ' ')"
  fi
elif [ "$OS_TYPE" = "Linux" ]; then
  if command -v ss &>/dev/null; then
    LISTENING_PORTS=$(ss -tlnp 2>/dev/null | grep LISTEN | awk '{print $4}' | rev | cut -d: -f1 | rev | sort -un | head -20)
    PORT_COUNT=$(echo "$LISTENING_PORTS" | grep -c . 2>/dev/null || echo 0)
    ok "监听端口数: ${PORT_COUNT}"
    echo "  端口列表:   $(echo $LISTENING_PORTS | tr '\n' ' ')"
    CONN_COUNT=$(ss -s 2>/dev/null | grep estab | awk '{print $2}' || echo "N/A")
    echo "  ESTABLISHED: ${CONN_COUNT}"
  elif command -v netstat &>/dev/null; then
    LISTENING=$(netstat -tlnp 2>/dev/null | grep LISTEN | wc -l)
    ok "监听端口数: ${LISTENING}"
  fi
fi

if [ "$MODE" = "--full" ]; then
  echo ""
  echo "[网络接口]"
  if command -v ip &>/dev/null; then
    ip -br addr 2>/dev/null | while IFS= read -r line; do
      echo "  $line"
    done
  elif command -v ifconfig &>/dev/null; then
    ifconfig 2>/dev/null | grep -E "^[a-z]" | while IFS= read -r line; do
      echo "  $line"
    done
  fi
fi

# --- 进程检查 ---
echo ""
echo "[进程]"
PROC_COUNT=$(ps aux 2>/dev/null | wc -l)
ZOMBIE=$(ps aux 2>/dev/null | awk '$8=="Z"' | wc -l)
ok "进程总数: $((PROC_COUNT - 1))"
if [ "$ZOMBIE" -gt 0 ]; then
  fail "僵尸进程: ${ZOMBIE} 个"
else
  ok "无僵尸进程"
fi

echo ""
echo "[Top 5 CPU 进程]"
if [ "$OS_TYPE" = "Darwin" ]; then
  ps aux -r 2>/dev/null | head -6 | awk 'NR>1{printf "  %-12s %-8s %5s%% %5s%%\n",substr($11,1,12),$1,$3,$4}' | head -5
else
  ps aux --sort=-%cpu 2>/dev/null | head -6 | awk 'NR>1{printf "  %-12s %-8s %5s%% %5s%%\n",substr($11,1,12),$1,$3,$4}' | head -5
fi
echo ""
echo "[Top 5 内存进程]"
if [ "$OS_TYPE" = "Darwin" ]; then
  ps aux -m 2>/dev/null | head -6 | awk 'NR>1{printf "  %-12s %-8s %5s%% %5s%%\n",substr($11,1,12),$1,$3,$4}' | head -5
else
  ps aux --sort=-%mem 2>/dev/null | head -6 | awk 'NR>1{printf "  %-12s %-8s %5s%% %5s%%\n",substr($11,1,12),$1,$3,$4}' | head -5
fi

# --- 服务检查（systemd） ---
if [ "$OS_TYPE" = "Linux" ] && command -v systemctl &>/dev/null; then
  echo ""
  echo "[失败的服务]"
  FAILED=$(systemctl --failed --no-legend 2>/dev/null)
  if [ -z "$FAILED" ]; then
    ok "无失败服务"
  else
    echo "$FAILED" | while IFS= read -r line; do
      fail "$line"
    done
  fi
fi

# --- Docker 检查 ---
if command -v docker &>/dev/null; then
  echo ""
  echo "[Docker]"
  if docker info &>/dev/null; then
    ok "Docker 守护进程运行中"
    CONTAINERS=$(docker ps -q | wc -l)
    STOPPED=$(docker ps -qf "status=exited" | wc -l)
    IMAGES=$(docker images -q | wc -l)
    echo "  运行容器:   ${CONTAINERS}"
    echo "  停止容器:   ${STOPPED}"
    echo "  镜像数:     ${IMAGES}"
    if [ "$MODE" = "--full" ]; then
      echo ""
      echo "  [容器详情]"
      docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | head -20
    fi
  else
    fail "Docker 守护进程未运行"
  fi
fi

echo ""
echo "========================================="
echo "  巡检完成"
echo "========================================="
