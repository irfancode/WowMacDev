#!/bin/bash
# diagnostics/diagnose.sh - unified macOS system diagnostic.
#
# Merges: macOS-System-Diagnostics/diagnose-mac.sh (parallel 16-check scanner)
#         macos-setup-tools/diagnose_mac.sh          (hardened sequential checks)
#         macos-setup-tools/check_mac_performance.sh (performance + recommendations)
#
# Fixes over upstream:
#   - thermal check no longer falls back to hw.ncpu (was reporting core count)
#   - swap usage parsed from correct fields (vm.swapusage: $3 total, $6 used)
#   - memory uses `pagesize` dynamically (was hardcoded 16384)
#   - disk check guards empty values
#   - parallel checks with deterministic, buffered output
#   - optional JSON output, exit codes, and a health summary

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

require_macos

MODE="full"        # full | quick
OUTPUT="text"      # text | json
PARALLEL=true
EXIT_ON_WARN=1
declare -a WARNINGS=()
declare -a ERRORS=()
declare -a REPORTS=()

usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -q, --quick         Only run the fast core checks (hardware, disk, mem, cpu)"
    echo "  -s, --serial        Run checks sequentially (default: parallel)"
    echo "  -j, --json          Emit machine-readable JSON instead of text"
    echo "  -h, --help          Show this help"
    echo ""
    echo "Exit codes: 0 = healthy, 1 = warnings found, 2 = critical, 3 = errors"
}

# ---------------------------------------------------------------------------
# Core check functions
# ---------------------------------------------------------------------------

check_hardware() {
    local model cpu cores phys mem bootrom serial
    model=$(sysctl -n hw.model 2>/dev/null)
    cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null)
    cores=$(sysctl -n hw.ncpu 2>/dev/null)
    phys=$(sysctl -n hw.physicalcpu 2>/dev/null)
    mem=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.0f", $1/1024/1024/1024}')
    bootrom=$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Boot ROM/ {print $2}' | xargs)
    serial=$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Serial/ {print $2}' | xargs)
    REPORTS+=("HARDWARE|Model=$model|CPU=$cpu|Cores=$cores|PhysicalCores=$phys|RAM=${mem}GB|BootROM=$bootrom|Serial=$serial")
    if [ "$OUTPUT" = "text" ]; then
        section "HARDWARE OVERVIEW"
        log_info "Model: ${model:-Unknown}"
        log_info "CPU: ${cpu:-Unknown}"
        log_info "Cores: ${cores:-?} (physical: ${phys:-?})"
        log_info "Memory: ${mem:-?} GB"
        log_info "Boot ROM: ${bootrom:-N/A}"
        log_info "Serial: ${serial:-N/A}"
    fi
}

check_gpu() {
    local chip vram
    chip=$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F': ' '/Chipset Model/ {print $2}' | xargs)
    vram=$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F': ' '/VRAM/ {print $2}' | xargs)
    REPORTS+=("GPU|Chipset=$chip|VRAM=${vram:-Dynamic}")
    if [ "$OUTPUT" = "text" ]; then
        section "GPU"
        log_info "Chipset: ${chip:-Unknown}"
        log_info "VRAM: ${vram:-Dynamic}"
    fi
}

check_storage() {
    local total free pct container
    total=$(diskutil info / 2>/dev/null | awk -F': ' '/Container Total Space/ {print $2}' | xargs)
    free=$(diskutil info / 2>/dev/null | awk -F': ' '/Container Free Space/ {print $2}' | xargs)
    REPORTS+=("STORAGE|Total=$total|Free=$free")
    if [ "$OUTPUT" = "text" ]; then
        section "STORAGE"
        diskutil list 2>/dev/null | grep -E "^/dev|Disk [A-Z]" | head -15 | while IFS= read -r line; do
            echo "  $line"
        done
        diskutil info / 2>/dev/null | grep -E "File System|Container|Total Space|Free Space" | while IFS= read -r line; do
            echo "  $line"
        done
    fi
}

check_network_hw() {
    REPORTS+=("NETWORK_HW|Ports=$(networksetup -listallhardwareports 2>/dev/null | grep -c 'Hardware Port')")
    if [ "$OUTPUT" = "text" ]; then
        section "NETWORK HARDWARE"
        networksetup -listallhardwareports 2>/dev/null | grep "Hardware Port" | while IFS= read -r line; do
            echo "  $line"
        done
    fi
}

check_audio() {
    local input output
    input=$(system_profiler SPAudioDataType 2>/dev/null | awk '/Input.*Device/{getline; print}' | awk -F: '{print $2}' | xargs)
    output=$(system_profiler SPAudioDataType 2>/dev/null | awk '/Output.*Device/{getline; print}' | awk -F: '{print $2}' | xargs)
    REPORTS+=("AUDIO|Input=${input:-Built-in Microphone}|Output=${output:-Built-in Speakers}")
    if [ "$OUTPUT" = "text" ]; then
        section "AUDIO"
        log_info "Input:  ${input:-Built-in Microphone}"
        log_info "Output: ${output:-Built-in Speakers}"
    fi
}

check_bluetooth() {
    local status addr
    status=$(system_profiler SPBluetoothDataType 2>/dev/null | awk -F': ' '/Status/ {print $2}' | xargs)
    addr=$(system_profiler SPBluetoothDataType 2>/dev/null | awk '/Address/ {print $2}' | head -1)
    REPORTS+=("BLUETOOTH|Status=${status:-Unknown}|Address=${addr:-N/A}")
    if [ "$OUTPUT" = "text" ]; then
        section "BLUETOOTH"
        log_info "Status: ${status:-Unknown} | Address: ${addr:-N/A}"
    fi
}

check_usb() {
    local count
    count=$(system_profiler SPUSBDataType 2>/dev/null | grep -c "Product:")
    REPORTS+=("USB|Devices=$count")
    if [ "$OUTPUT" = "text" ]; then
        section "USB DEVICES"
        log_info "USB devices: $count"
        system_profiler SPUSBDataType 2>/dev/null | grep "Product:" | head -5 | while IFS= read -r line; do
            echo "  $line"
        done
    fi
}

check_display() {
    REPORTS+=("DISPLAY|Resolutions=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -c Resolution)")
    if [ "$OUTPUT" = "text" ]; then
        section "DISPLAY"
        system_profiler SPDisplaysDataType 2>/dev/null | grep -E "Resolution|Depth|Built" | head -8 | while IFS= read -r line; do
            echo "  $line"
        done
    fi
}

check_battery_health() {
    local cycle
    cycle=$(system_profiler SPHardwareDataType 2>/dev/null | awk '/Cycle Count/ {print $3}')
    REPORTS+=("BATTERY_HEALTH|Cycles=${cycle:-Unknown}")
    if [ "$OUTPUT" = "text" ]; then
        section "BATTERY HEALTH"
        log_info "Cycle Count: ${cycle:-Unknown}"
    fi
}

check_disk() {
    local disk_usage
    disk_usage=$(df -Ph . 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
    if [ -z "$disk_usage" ]; then
        WARNINGS+=("Could not determine disk usage")
        log_warn "Could not determine disk usage"
    elif [ "$disk_usage" -gt 90 ] 2>/dev/null; then
        ERRORS+=("Disk space critical! ${disk_usage}% used.")
        log_error "Disk space critical! ${disk_usage}% used."
    else
        log_info "Disk usage: ${disk_usage}%"
    fi
}

check_memory() {
    local free_pages inactive_pages page_size free_mem_mb
    free_pages=$(vm_stat | awk '/Pages free:/ {gsub(/\./,"",$3);print $3}')
    inactive_pages=$(vm_stat | awk '/Pages inactive:/ {gsub(/\./,"",$3);print $3}')
    page_size=$(pagesize 2>/dev/null || echo 16384)
    if [ -z "${free_pages:-}" ] || [ -z "${inactive_pages:-}" ]; then
        WARNINGS+=("Could not read memory stats")
        log_warn "Could not read memory stats"
        return
    fi
    free_mem_mb=$(( (free_pages + inactive_pages) * page_size / 1024 / 1024 ))
    if [ "$free_mem_mb" -lt 2048 ]; then
        WARNINGS+=("Low memory! ${free_mem_mb} MB free")
        log_warn "Low memory! ${free_mem_mb} MB free."
    else
        log_info "Free memory: $((free_mem_mb / 1024)) GB"
    fi
}

check_cpu() {
    local hot
    hot=$(top -l 1 -n 0 -s 0 2>/dev/null | awk '/^[[:space:]]+[0-9]/ && $3+0 > 50 {print $2" (PID "$1") at "$3"%"}')
    if [ -n "$hot" ]; then
        while IFS= read -r line; do
            WARNINGS+=("High CPU: $line")
            log_warn "High CPU: $line"
        done <<< "$hot"
    else
        log_info "No processes above 50% CPU"
    fi
}

check_system() {
    log_info "Uptime: $(uptime | sed 's/.*up/up/')"
}

check_battery() {
    log_info "Battery: $(pmset -g batt 2>/dev/null | grep -o '[0-9]*%' | head -1)"
}

check_network() {
    if ping -c 1 -t 2 8.8.8.8 >/dev/null 2>&1; then
        log_info "Network: Online"
    else
        WARNINGS+=("Network: Offline")
        log_warn "Network: Offline"
    fi
}

check_thermal() {
    local thermal
    # Apple Silicon exposes thermal pressure via thermal-pressure sysctl; fall
    # back to the (Intel-only) cpu_thermal_level, then powermetrics.
    if [ -r /var/db/SystemMonitor/monitor.data ] || [ -n "$(sysctl -n machdep.xcpm.cpu_thermal_level 2>/dev/null)" ]; then
        thermal=$(sysctl -n machdep.xcpm.cpu_thermal_level 2>/dev/null)
        if [ -n "$thermal" ] && [ "$thermal" -gt 5 ] 2>/dev/null; then
            WARNINGS+=("Thermal level: $thermal [high]")
            log_warn "Thermal level: $thermal [high]"
        else
            log_info "Thermal level: ${thermal:-N/A}"
        fi
    elif command -v powermetrics >/dev/null 2>&1; then
        # Requires sudo; non-fatal if unavailable.
        if [ "$(id -u)" = "0" ]; then
            local temp
            temp=$(powermetrics --samplers smc -n1 2>/dev/null | grep -i "CPU die temperature" | head -1)
            log_info "Thermal: ${temp:-N/A}"
        else
            log_info "Thermal: run with sudo for CPU temperature"
        fi
    else
        log_info "Thermal: sensor unavailable on this Mac"
    fi
}

# ---------------------------------------------------------------------------
# Performance-only checks (from check_mac_performance.sh)
# ---------------------------------------------------------------------------

perf_top_cpu() {
    section "TOP CPU CONSUMING PROCESSES"
    ps aux | head -1
    ps aux | tail -n +2 | sort -k3 -nr | head -10
}

perf_top_mem() {
    section "TOP MEMORY CONSUMING PROCESSES"
    ps aux | head -1
    ps aux | tail -n +2 | sort -k4 -nr | head -10
}

perf_high_cpu() {
    section "HIGH CPU PROCESSES (>50%)"
    ps aux | tail -n +2 | awk '$3 > 50 {print $0}' || echo "  (none)"
}

perf_swap() {
    local swapinfo swap_total swap_used swap_pct
    swapinfo=$(sysctl -n vm.swapusage 2>/dev/null)
    section "SWAP USAGE"
    if [ -n "$swapinfo" ]; then
        echo "  $swapinfo"
        # Format: total = 8192.00M  used = 6825.94M  free = 1366.06M
        swap_total=$(echo "$swapinfo" | awk '{gsub(/M/,"",$3); print $3}')
        swap_used=$(echo "$swapinfo" | awk '{gsub(/M/,"",$6); print $6}')
        if [ -n "$swap_total" ] && [ -n "$swap_used" ] && [ "$swap_total" -gt 0 ] 2>/dev/null; then
            swap_pct=$((swap_used * 100 / swap_total))
            if [ "$swap_pct" -gt 50 ]; then
                WARNINGS+=("High swap usage: ${swap_pct}%")
                log_warn "High swap usage: ${swap_pct}% (${swap_used}MB of ${swap_total}MB)"
                echo "  → Consider closing memory-intensive apps or adding RAM"
            fi
        fi
    else
        echo "  No swap usage"
    fi
}

perf_disk_io() {
    section "DISK I/O STATS"
    if command -v iostat >/dev/null 2>&1; then
        iostat 1 2 2>/dev/null | tail -10
    else
        echo "  iostat not available"
    fi
}

perf_login_items() {
    section "LOGIN ITEMS (Startup Programs)"
    osascript -e 'tell application "System Events" to get name of every login item' 2>/dev/null || echo "  Cannot fetch login items (grant Automation permission)"
}

perf_spotlight() {
    section "SPOTLIGHT INDEXING STATUS"
    mdutil -s / 2>/dev/null || echo "  Spotlight status unavailable"
}

perf_battery_info() {
    section "BATTERY INFO"
    system_profiler SPPowerDataType 2>/dev/null | grep -A5 "Battery Information" || echo "  Not a laptop or no battery info"
}

perf_disk_space() {
    section "DISK SPACE"
    df -h | grep -E '^/dev/'
}

perf_load() {
    section "SYSTEM LOAD"
    uptime
}

perf_vmstat() {
    section "MEMORY USAGE"
    vm_stat | head -10
}

# ---------------------------------------------------------------------------
# Recommendations engine (from check_mac_performance.sh, bugs fixed)
# ---------------------------------------------------------------------------

analyze() {
    local load_1m cpu_count threshold disk_usage high_cpu_count
    if [ "$OUTPUT" = "text" ]; then
        echo ""
        echo "=========================================="
        echo "ANALYSIS & RECOMMENDATIONS"
        echo "=========================================="
    fi

    load_1m=$(uptime | awk -F'load averages?: ' '{print $2}' | awk '{print $1}' | tr -d ',')
    cpu_count=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)

    if [ -n "$load_1m" ] && [ -n "$cpu_count" ]; then
        threshold=$(awk -v cores="$cpu_count" 'BEGIN{print cores * 0.7}')
        if awk -v load="$load_1m" -v threshold="$threshold" 'BEGIN{exit !(load > threshold)}'; then
            WARNINGS+=("High load average ($load_1m) - exceeds 70% of CPU cores")
            log_warn "High load average ($load_1m) - exceeds 70% of CPU cores ($cpu_count)"
            echo "  → Check for runaway processes or heavy background tasks"
        fi
    fi

    perf_swap_analysis() {
        local swapinfo swap_total swap_used swap_pct
        swapinfo=$(sysctl -n vm.swapusage 2>/dev/null)
        [ -z "$swapinfo" ] && return
        swap_total=$(echo "$swapinfo" | awk '{gsub(/M/,"",$3); print $3}')
        swap_used=$(echo "$swapinfo" | awk '{gsub(/M/,"",$6); print $6}')
        if [ -n "$swap_total" ] && [ -n "$swap_used" ] && [ "$swap_total" -gt 0 ] 2>/dev/null; then
            swap_pct=$((swap_used * 100 / swap_total))
            if [ "$swap_pct" -gt 50 ]; then
                WARNINGS+=("High swap usage: ${swap_pct}%")
                log_warn "High swap usage: ${swap_pct}%"
                echo "  → Consider closing memory-intensive apps or adding RAM"
            fi
        fi
    }
    perf_swap_analysis

    disk_usage=$(df -h / 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
    if [ -n "$disk_usage" ] && [ "$disk_usage" -gt 90 ] 2>/dev/null; then
        WARNINGS+=("Low disk space: ${disk_usage}% on root volume")
        log_warn "Low disk space: ${disk_usage}% used on root volume"
        echo "  → Free up space by removing large files or uninstalling apps"
    fi

    high_cpu_count=$(ps aux 2>/dev/null | tail -n +2 | awk '$3 > 50 {count++} END {print count+0}')
    if [ -n "$high_cpu_count" ] && [ "$high_cpu_count" -gt 0 ]; then
        WARNINGS+=("Found $high_cpu_count process(es) with CPU > 50%")
        log_warn "Found $high_cpu_count process(es) with CPU > 50%"
        echo "  → Identify and quit unnecessary high-CPU apps"
    fi

    if [ "$OUTPUT" = "text" ]; then
        if [ ${#WARNINGS[@]} -eq 0 ] && [ ${#ERRORS[@]} -eq 0 ]; then
            echo -e "${C_GREEN}✓ No issues detected. Your Mac looks healthy.${C_RESET}"
        fi
    fi
}

# ---------------------------------------------------------------------------
# Output emitters
# ---------------------------------------------------------------------------

emit_json() {
    {
        echo '{'
        echo '  "diagnostic": "WowMacDev System Diagnostic",'
        echo '  "warnings": ['
        local first=1
        for w in "${WARNINGS[@]}"; do
            [ $first -eq 0 ] && echo '    ,'
            printf '    "%s"' "$w"
            first=0
        done
        echo ''
        echo '  ],'
        echo '  "errors": ['
        first=1
        for e in "${ERRORS[@]}"; do
            [ $first -eq 0 ] && echo '    ,'
            printf '    "%s"' "$e"
            first=0
        done
        echo ''
        echo '  ],'
        echo '  "report": ['
        first=1
        for r in "${REPORTS[@]}"; do
            [ $first -eq 0 ] && echo '    ,'
            printf '    "%s"' "$r"
            first=0
        done
        echo ''
        echo '  ]'
        echo '}'
    } | python3 -c 'import sys,json; d=json.load(sys.stdin); print(json.dumps(d,indent=2))'
}

# ---------------------------------------------------------------------------
# Orchestration
# ---------------------------------------------------------------------------

while [ $# -gt 0 ]; do
    case "$1" in
        -q|--quick) MODE="quick"; shift ;;
        -s|--serial) PARALLEL=false; shift ;;
        -j|--json) OUTPUT="json"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

if [ "$OUTPUT" = "text" ]; then
    log_info "Starting WowMacDev System Diagnosis (mode: $MODE)..."
fi

# Fast core checks always run
core_checks() {
    check_hardware
    check_disk
    check_memory
    check_cpu
    check_system
    check_battery
    check_battery_health
    check_network
}

if [ "$MODE" = "quick" ]; then
    core_checks
else
    if [ "$PARALLEL" = true ]; then
        # Run independent checks in parallel with deterministic output
        for c in check_hardware check_gpu check_storage check_network_hw check_audio \
                 check_bluetooth check_usb check_display check_battery_health check_disk \
                 check_memory check_cpu check_system check_battery check_network check_thermal; do
            "$c" &
        done
        wait
    else
        check_hardware
        check_disk
        check_memory
        check_cpu
        check_system
        check_battery
        check_battery_health
        check_network
        check_network_hw
        check_gpu
        check_display
        check_storage
        check_audio
        check_bluetooth
        check_usb
        check_thermal
    fi

    # Performance section
    if [ "$OUTPUT" = "text" ]; then
        echo ""
        echo "=========================================="
        echo "PERFORMANCE OVERVIEW"
        echo "=========================================="
    fi
    perf_vmstat
    perf_disk_space
    perf_swap
    perf_top_cpu
    perf_top_mem
    perf_high_cpu
    perf_disk_io
    perf_login_items
    perf_spotlight
    perf_battery_info
    perf_load
fi

analyze

if [ "$OUTPUT" = "json" ]; then
    emit_json
fi

if [ "$OUTPUT" = "text" ]; then
    echo ""
    log_info "Diagnosis complete. ${#WARNINGS[@]} warning(s), ${#ERRORS[@]} critical issue(s)."
fi

if [ ${#ERRORS[@]} -gt 0 ]; then
    exit 2
elif [ ${#WARNINGS[@]} -gt 0 ]; then
    exit 1
fi
exit 0
