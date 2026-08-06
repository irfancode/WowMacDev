#!/bin/bash
# diagnostics/performance.sh - focused performance scan + recommendations.
#
# Merged from: macos-setup-tools/check_mac_performance.sh
# Fixes over upstream:
#   - swap usage parsed from correct vm.swapusage fields ($3 total, $6 used)
#   - powermetrics guarded so it doesn't hang waiting for sudo password
#   - iostat called with valid macOS arguments
#   - all arithmetic guarded against empty values

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

require_macos

# ---------------------------------------------------------------------------
# Report collectors
# ---------------------------------------------------------------------------
declare -a WARNINGS=()

print_header() {
    echo -e "${C_GREEN}=== $1 ===${C_RESET}"
}

print_warning() {
    echo -e "${C_YELLOW}⚠ $1${C_RESET}"
}

print_error() {
    echo -e "${C_RED}✖ $1${C_RESET}"
}

echo "=========================================="
echo "WowMacDev Performance Diagnostic"
echo "=========================================="
echo ""

print_header "TOP CPU CONSUMING PROCESSES"
ps aux | head -1
ps aux | tail -n +2 | sort -k3 -nr | head -10
echo ""

print_header "MEMORY USAGE"
vm_stat | head -10
echo ""

print_header "DISK SPACE"
df -h | grep -E '^/dev/'
echo ""

print_header "SWAP USAGE"
swapinfo=$(sysctl -n vm.swapusage 2>/dev/null)
if [ -n "$swapinfo" ]; then
    echo "  $swapinfo"
    swap_total=$(echo "$swapinfo" | awk '{gsub(/M/,"",$3); print $3}')
    swap_used=$(echo "$swapinfo" | awk '{gsub(/M/,"",$6); print $6}')
    if [ -n "$swap_total" ] && [ -n "$swap_used" ] && [ "$swap_total" -gt 0 ] 2>/dev/null; then
        swap_pct=$((swap_used * 100 / swap_total))
        if [ "$swap_pct" -gt 50 ]; then
            WARNINGS+=("High swap usage: ${swap_pct}%")
        fi
    fi
else
    echo "  No swap usage"
fi
echo ""

print_header "SYSTEM LOAD"
uptime
echo ""

print_header "TOP MEMORY CONSUMING PROCESSES"
ps aux | head -1
ps aux | tail -n +2 | sort -k4 -nr | head -10
echo ""

print_header "HIGH CPU PROCESSES (>50%)"
ps aux | head -1
ps aux | tail -n +2 | awk '$3 > 50 {print $0}'
echo ""

print_header "DISK I/O STATS"
if command -v iostat >/dev/null 2>&1; then
    iostat 1 2 2>/dev/null | tail -10
else
    echo "iostat not available"
fi
echo ""

print_header "THERMAL STATE"
if [ "$(id -u)" = "0" ]; then
    if command -v powermetrics >/dev/null 2>&1; then
        powermetrics --samplers smc -n1 2>/dev/null | grep -i "CPU die temperature" || echo "Temperature data unavailable"
    else
        echo "powermetrics not available"
    fi
else
    echo "Run with sudo for CPU temperature (sudo $0)"
fi
echo ""

print_header "LOGIN ITEMS (Startup Programs)"
osascript -e 'tell application "System Events" to get name of every login item' 2>/dev/null \
    || echo "Cannot fetch login items (grant Automation permission)"
echo ""

print_header "SPOTLIGHT INDEXING STATUS"
mdutil -s / 2>/dev/null || echo "Spotlight status unavailable"
echo ""

print_header "BATTERY INFO"
system_profiler SPPowerDataType 2>/dev/null | grep -A5 "Battery Information" \
    || echo "Not a laptop or no battery info"
echo ""

# ---------------------------------------------------------------------------
# ANALYSIS & RECOMMENDATIONS
# ---------------------------------------------------------------------------
echo "=========================================="
echo "ANALYSIS & RECOMMENDATIONS"
echo "=========================================="

load_1m=$(uptime | awk -F'load averages?: ' '{print $2}' | awk '{print $1}' | tr -d ',')
cpu_count=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)

if [ -n "$load_1m" ] && [ -n "$cpu_count" ]; then
    threshold=$(awk -v cores="$cpu_count" 'BEGIN{print cores * 0.7}')
    if awk -v load="$load_1m" -v threshold="$threshold" 'BEGIN{exit !(load > threshold)}'; then
        WARNINGS+=("High load average ($load_1m) exceeds 70% of CPU cores ($cpu_count)")
        print_warning "High load average ($load_1m) - exceeds 70% of CPU cores ($cpu_count)"
        echo "  → Check for runaway processes or heavy background tasks"
    fi
fi

if [ -n "$swapinfo" ] && [ -n "$swap_total" ] && [ -n "$swap_used" ] && [ "$swap_total" -gt 0 ] 2>/dev/null; then
    swap_pct=$((swap_used * 100 / swap_total))
    if [ "$swap_pct" -gt 50 ]; then
        WARNINGS+=("High swap usage: ${swap_pct}% (${swap_used}MB used of ${swap_total}MB)")
        print_warning "High swap usage: ${swap_pct}% (${swap_used}MB used of ${swap_total}MB)"
        echo "  → Consider closing memory-intensive apps or adding RAM"
    fi
fi

disk_usage=$(df -h / 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
if [ -n "$disk_usage" ] && [ "$disk_usage" -gt 90 ] 2>/dev/null; then
    WARNINGS+=("Low disk space: ${disk_usage}% used on root volume")
    print_warning "Low disk space: ${disk_usage}% used on root volume"
    echo "  → Free up space by removing large files or uninstalling apps"
fi

free_pages=$(vm_stat 2>/dev/null | awk '/Pages free:/ {gsub(/\./,"",$3);print $3}')
inactive_pages=$(vm_stat 2>/dev/null | awk '/Pages inactive:/ {gsub(/\./,"",$3);print $3}')
page_size=$(pagesize 2>/dev/null || echo 16384)
if [ -n "$free_pages" ] && [ -n "$inactive_pages" ]; then
    total_free_mb=$(( (free_pages + inactive_pages) * page_size / 1024 / 1024 ))
    if [ "$total_free_mb" -lt 2048 ] 2>/dev/null; then
        WARNINGS+=("Low free memory: ${total_free_mb} MB free")
        print_warning "Low free memory: ${total_free_mb} MB free"
        echo "  → Close unused applications to free memory"
    fi
fi

high_cpu_count=$(ps aux 2>/dev/null | tail -n +2 | awk '$3 > 50 {count++} END {print count+0}')
if [ -n "$high_cpu_count" ] && [ "$high_cpu_count" -gt 0 ]; then
    WARNINGS+=("Found $high_cpu_count process(es) with CPU > 50%")
    print_warning "Found $high_cpu_count process(es) with CPU > 50%"
    echo "  → Identify and quit unnecessary high-CPU apps"
fi

if [ ${#WARNINGS[@]} -eq 0 ]; then
    echo -e "${C_GREEN}✓ No performance issues detected.${C_RESET}"
fi

echo ""
echo "Check complete. Review the diagnostics above."
echo "=========================================="

[ ${#WARNINGS[@]} -gt 0 ] && exit 1
exit 0
