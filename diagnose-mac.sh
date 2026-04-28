#!/bin/bash

log_message() {
    local level="$1"
    local msg="$2"
    echo -e "\n[${level}] $msg"
}

check_hardware() {
    log_message "INFO" "=== HARDWARE OVERVIEW ==="
    model=$(sysctl -n hw.model 2>/dev/null)
    log_message "INFO" "Model: $model"
    log_message "INFO" "CPU: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || sysctl -n hw.ncpu)"
    log_message "INFO" "CPU Cores: $(sysctl -n hw.ncpu) (Physical: $(sysctl -n hw.physicalcpu))"
    log_message "INFO" "Memory: $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')"
    log_message "INFO" "Boot ROM: $(system_profiler SPHardwareDataType 2>/dev/null | grep 'Boot ROM' | awk -F: '{print $2}' | xargs)"
    log_message "INFO" "Serial: $(system_profiler SPHardwareDataType 2>/dev/null | grep 'Serial' | awk -F: '{print $2}' | xargs)"
}

check_gpu() {
    log_message "INFO" "=== GPU ==="
    chip=$(system_profiler SPDisplaysDataType 2>/dev/null | grep "Chipset Model" | awk -F: '{print $2}' | xargs)
    vram=$(system_profiler SPDisplaysDataType 2>/dev/null | grep "VRAM" | awk -F: '{print $2}' | xargs)
    log_message "INFO" "Chipset: ${chip:-Unknown}"
    log_message "INFO" "VRAM: ${vram:-Dynamic}"
}

check_storage() {
    log_message "INFO" "=== STORAGE ==="
    diskutil list 2>/dev/null | grep -E "^/dev|Disk [A-Z]" | head -15 | while read -r line; do
        log_message "INFO" "$line"
    done
    diskutil info / 2>/dev/null | grep -E "File System|Container|Total Space|Free Space" | while read -r line; do
        log_message "INFO" "  $line"
    done
}

check_network_hw() {
    log_message "INFO" "=== NETWORK HARDWARE ==="
    networksetup -listallhardwareports 2>/dev/null | grep -B1 "Device:" | grep "Hardware Port" | while read -r line; do
        log_message "INFO" "$line"
    done
}

check_audio() {
    log_message "INFO" "=== AUDIO ==="
    input=$(system_profiler SPAudioDataType 2>/dev/null | awk '/Input.*Device/{getline; print}' | awk -F: '{print $2}' | xargs)
    output=$(system_profiler SPAudioDataType 2>/dev/null | awk '/Output.*Device/{getline; print}' | awk -F: '{print $2}' | xargs)
    log_message "INFO" "Input: ${input:-Built-in Microphone}"
    log_message "INFO" "Output: ${output:-Built-in Speakers}"
}

check_bluetooth() {
    log_message "INFO" "=== BLUETOOTH ==="
    bt_status=$(system_profiler SPBluetoothDataType 2>/dev/null | grep "Status" | awk -F: '{print $2}' | xargs)
    bt_addr=$(system_profiler SPBluetoothDataType 2>/dev/null | grep "Address" | awk '{print $2}' | head -1)
    log_message "INFO" "Status: ${bt_status:-Unknown} | Address: ${bt_addr:-N/A}"
}

check_usb() {
    log_message "INFO" "=== USB DEVICES ==="
    usb_count=$(system_profiler SPUSBDataType 2>/dev/null | grep "Product:" | wc -l | tr -d ' ')
    log_message "INFO" "USB devices: $usb_count"
    system_profiler SPUSBDataType 2>/dev/null | grep "Product:" | head -5 | while read -r line; do
        log_message "INFO" "  $line"
    done
}

check_display() {
    log_message "INFO" "=== DISPLAY ==="
    system_profiler SPDisplaysDataType 2>/dev/null | grep -E "Resolution|Depth|Built" | head -8 | while read -r line; do
        log_message "INFO" "$line"
    done
}

check_battery_health() {
    log_message "INFO" "=== BATTERY HEALTH ==="
    cycle=$(system_profiler SPHardwareDataType 2>/dev/null | grep "Cycle Count" | awk '{print $3}')
    log_message "INFO" "Cycle Count: ${cycle:-Unknown}"
}

check_disk() {
    disk_usage=$(df -Ph . 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
    [ "$disk_usage" -gt 90 ] && log_message "ERROR" "Disk space critical! ${disk_usage}% used." || log_message "INFO" "Disk usage: ${disk_usage}%"
}

check_memory() {
    free_pages=$(vm_stat | awk '/Pages free:/ {gsub(/\./,"");print $3}')
    inactive_pages=$(vm_stat | awk '/Pages inactive:/ {gsub(/\./,"");print $3}')
    free_mem_gb=$(( (free_pages + inactive_pages) * 16384 / 1024 / 1024 / 1024 ))
    [ $free_mem_gb -lt 2 ] && log_message "WARN" "Low memory! ${free_mem_gb} GB free." || log_message "INFO" "Free memory: ${free_mem_gb} GB"
}

check_cpu() {
    top -l 1 -n 0 -s 0 2>/dev/null | awk '/^[[:space:]]+[0-9]/ && $3+0 > 50 {printf "[WARN] High CPU: %s [PID: %s] at %s%%\n",$2,$1,$3}'
}

check_system() {
    log_message "INFO" "Uptime: $(uptime | sed 's/.*up/up/')"
}

check_battery() {
    log_message "INFO" "Battery: $(pmset -g batt 2>/dev/null | grep -o '[0-9]*%' | head -1)"
}

check_network() {
    ping -c 1 -t 2 8.8.8.8 >/dev/null 2>&1 && log_message "INFO" "Network: Online" || log_message "WARN" "Network: Offline"
}

check_thermal() {
    thermal=$(sysctl -n machdep.xcpm.cpu_thermal_level 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null)
    if [ -n "$thermal" ] && [ "$thermal" -gt 0 ]; then
        [ "$thermal" -gt 5 ] && log_message "WARN" "Thermal level: $thermal [high]" || log_message "INFO" "Thermal level: $thermal"
    else
        log_message "INFO" "Thermal: N/A [sensor unavailable]"
    fi
}

log_message "INFO" "Starting macOS System Diagnosis..."

check_hardware &
check_disk &
check_memory &
check_cpu &
check_system &
check_battery &
check_battery_health &
check_network &
check_network_hw &
check_gpu &
check_display &
check_storage &
check_audio &
check_bluetooth &
check_usb &
check_thermal &
wait

log_message "INFO" "Diagnosis complete."
