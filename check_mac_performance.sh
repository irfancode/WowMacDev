#!/bin/bash

if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is for macOS only"
    exit 1
fi

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

print_header() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✖ $1${NC}"
}

echo "=========================================="
echo "Mac Performance Diagnostic Script"
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
if vm_stat 2>/dev/null | grep -q "Pageins"; then
    swapinfo=$(sysctl -n vm.swapusage 2>/dev/null || echo "Swap info unavailable")
    echo "$swapinfo"
else
    echo "No swap usage"
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
if command -v iostat &>/dev/null; then
    iostat 1 2 2>/dev/null | tail -10
else
    echo "iostat not available"
fi
echo ""

print_header "THERMAL STATE"
if command -v powermetrics &>/dev/null; then
    sudo powermetrics --samplers smc -n1 2>/dev/null | grep -i "CPU die temperature" || echo "Temperature data unavailable"
else
    echo "powermetrics not available"
fi
echo ""

print_header "LOGIN ITEMS (Startup Programs)"
osascript -e 'tell application "System Events" to get name of every login item' 2>/dev/null || echo "Cannot fetch login items"
echo ""

print_header "SPOTLIGHT INDEXING STATUS"
mdutil -s / 2>/dev/null || echo "Spotlight status unavailable"
echo ""

print_header "BATTERY INFO"
system_profiler SPPowerDataType 2>/dev/null | grep -A5 "Battery Information" || echo "Not a laptop or no battery info"
echo ""

echo "=========================================="
echo "ANALYSIS & RECOMMENDATIONS"
echo "=========================================="

load_1m_val=$(uptime | awk -F'load averages?: ' '{print $2}' | awk '{print $1}' | tr -d ',')
cpu_count=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)

if [ -n "$load_1m_val" ] && [ -n "$cpu_count" ]; then
    threshold=$(awk -v cores="$cpu_count" 'BEGIN{print cores * 0.7}')
    if awk -v load="$load_1m_val" -v threshold="$threshold" 'BEGIN{exit !(load > threshold)}'; then
        print_warning "High load average ($load_1m_val) - exceeds 70% of CPU cores ($cpu_count)"
        echo "  → Check for runaway processes or heavy background tasks"
    fi
fi

if vm_stat 2>/dev/null | grep -q "Pageins"; then
    swap_total=$(sysctl -n vm.swapusage 2>/dev/null | awk '{print $4}' | tr -d 'M')
    swap_used=$(sysctl -n vm.swapusage 2>/dev/null | awk '{print $7}' | tr -d 'M')
    if [ -n "$swap_total" ] && [ -n "$swap_used" ] && [ "$swap_total" -gt 0 ] 2>/dev/null; then
        swap_pct=$((swap_used * 100 / swap_total))
        if [ "$swap_pct" -gt 50 ]; then
            print_warning "High swap usage: ${swap_pct}% (${swap_used}MB used of ${swap_total}MB)"
            echo "  → Consider closing memory-intensive apps or adding RAM"
        fi
    fi
fi

disk_usage=$(df -h / 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
if [ -n "$disk_usage" ] && [ "$disk_usage" -gt 90 ] 2>/dev/null; then
    print_warning "Low disk space: ${disk_usage}% used on root volume"
    echo "  → Free up space by removing large files or uninstalling apps"
fi

free_pages=$(vm_stat 2>/dev/null | awk '/Pages free:/ {gsub(/\./,"",$3);print $3}')
inactive_pages=$(vm_stat 2>/dev/null | awk '/Pages inactive:/ {gsub(/\./,"",$3);print $3}')
page_size=$(pagesize 2>/dev/null || echo 16384)
total_free_mb=$(( (free_pages + inactive_pages) * page_size / 1024 / 1024 ))
if [ -n "$total_free_mb" ] && [ "$total_free_mb" -lt 2048 ] 2>/dev/null; then
    print_warning "Low free memory: ${total_free_mb} MB free"
    echo "  → Close unused applications to free memory"
fi

high_cpu_count=$(ps aux 2>/dev/null | tail -n +2 | awk '$3 > 50 {count++} END {print count+0}')
if [ "$high_cpu_count" -gt 0 ]; then
    print_warning "Found $high_cpu_count process(es) with CPU > 50%"
    echo "  → Identify and quit unnecessary high-CPU apps"
fi

echo ""
echo "Check complete. Review the diagnostics above."
echo "=========================================="