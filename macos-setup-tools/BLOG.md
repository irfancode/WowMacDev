---
title: "My macOS Setup & Diagnostic Toolkit"
description: "A complete collection of bash scripts to automate macOS setup, diagnostics, and performance monitoring"
date: 2026-04-30
hero: images/hero.png
author: Irfan
tags: ["macOS", "bash", "productivity", "diagnostics"]
---

# My macOS Setup & Diagnostic Toolkit

After setting up multiple MacBooks, I realized I was manually applying the same customizations every time. So I built a toolkit to automate everything—from initial setup to ongoing diagnostics.

![macOS Utilities](images/banner.png)

## The Problem

Every time I get a new MacBook Pro, I spend hours:
1. Enabling battery percentage in menu bar
2. Customizing the Dock (auto-hide, magnification)
3. Configuring Finder settings
4. Setting up Hot Corners
5. Checking hardware health
6. Monitoring performance

**Sound familiar?** That's exactly why I created these scripts.

## The Solution

Four bash scripts that handle everything:

| Script | What It Does |
|--------|-------------|
| `macbook_setup.sh` | 20-step automated macOS customization |
| `diagnose_mac.sh` | Complete system diagnostics |
| `check_mac_performance.sh` | Real-time performance monitoring |
| `disk_usage.sh` | Find large files & directories |

## Script 1: macbook_setup.sh

This is my go-to script for fresh MacBook setups. It automates 20 customizations:

```bash
./macbook_setup.sh
```

**What it customizes:**

1. **Battery** - Shows percentage in menu bar
2. **Dock** - Auto-hide, magnification, 48px icons
3. **Finder** - Show hidden files, path bar, list view
4. **Menu Bar** - WiFi, Bluetooth icons
5. **Trackpad** - Tap to click, 3-finger drag
6. **Hot Corners** - Mission Control, Desktop, Notification Center, Screen Saver
7. **Screenshots** - Save to ~/Pictures/Screenshots as PNG
8. **Safari** - Homepage to Google, developer mode
9. **Stage Manager** - Enable window management
10. **Keyboard** - Faster key repeat rate

### Before & After

| Setting | Default | After Script |
|--------|---------|-------------|
| Battery % | Hidden | ✅ Visible |
| Dock icons | 64px | 48px |
| Auto-hide | Off | Instant (0ms) |
| Hidden files | Hidden | Visible |
| Screenshot location | Desktop | ~/Pictures/Screenshots |

![Dock Comparison](images/dock-before.png) → ![Dock Comparison](images/dock-after.png)

## Script 2: diagnose_mac.sh

Running system diagnostics in seconds:

```bash
./diagnose_mac.sh
```

**Output:**
```
[INFO] === HARDWARE OVERVIEW ===
[INFO] Model: MacBookPro18,1 (MacBook Pro M5)
[INFO] CPU: Apple M5 Pro (10-core)
[INFO] Memory: 32 GB
[INFO] Serial: C02XG0xxxxx

[INFO] === STORAGE ===
[INFO]   File System: APFS
[INFO]   Total Space: 1 TB
[INFO]   Free Space: 512 GB

[INFO] === BATTERY HEALTH ===
[INFO] Cycle Count: 45
```

**17 Checks Include:**
- Hardware overview (CPU, RAM, Serial)
- GPU info (Chipset, VRAM)
- Storage analysis
- Network hardware
- Audio input/output
- Bluetooth status
- USB devices
- Display resolution
- Battery health
- Disk usage
- Memory availability
- Network connectivity
- Thermal state

### Real-World Use

I run this every month to track:
- Battery cycle count degradation
- Disk space trends
- Memory pressure

## Script 3: check_mac_performance.sh

Real-time performance alerts:

```bash
./check_mac_performance.sh
```

**Key Features:**

1. **Top CPU Processes**
   ```bash
   USER       PID %CPU %MEM    COMMAND
   irfan     1234 45.2  8.1  Safari
   irfan     5678 23.1  4.2  VS Code
   ```

2. **Memory Analysis**
   - Free pages, inactive pages
   - Memory pressure indicator

3. **Swap Monitoring**
   - Alerts when swap > 50% used

4. **Smart Recommendations**
   ```
   ⚠ High swap usage: 65%
     → Consider closing memory-intensive apps
   
   ⚠ Found 2 processes with CPU > 50%
     → Identify and quit unnecessary apps
   ```

### Alert Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| Swap usage | > 50% | > 80% |
| Disk usage | > 80% | > 90% |
| Free memory | < 2 GB | < 1 GB |
| High CPU processes | > 0 | > 3 |

## Script 4: disk_usage.sh

Find what's eating your disk:

```bash
./disk_usage.sh                    # Analyze home
./disk_usage.sh /Applications    # Analyze Apps
```

**Output:**
```
=== Top 10 Largest Directories ===
4.2G    ./Library
2.1G    ./Documents
1.8G    ./Downloads

=== Top 10 Largest Files (>5M) ===
2.4G    ./Adobe/Library/Caches
1.2G    ./Downloads/Xcode_15.dmg
```

**Exclusions:**
- `.Trash`
- `.Spotlight-V100`
- `.fseventsd`
- `.git`
- `node_modules`

## Technical Details

### Error Handling

Every script includes:
- OS verification (macOS only)
- Command existence checks
- Empty variable guards
- Proper stderr handling

Example:
```bash
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is for macOS only"
    exit 1
fi
```

### Colors

Consistent color scheme across all scripts:
- ✅ Green (`\033[0;32m`) - Success/INFO
- ⚠ Yellow (`\033[1;33m`) - Warnings
- ✖ Red (`\033[0;31m`) - Errors

### Parallel Execution

Some scripts use parallel execution for speed:
```bash
check_hardware &
check_disk &
check_memory &
wait
```

## Installation

```bash
git clone https://github.com/irfan/macOS-Setup-Tools.git
cd macOS-Setup-Tools
chmod +x *.sh

# Run setup
./macbook_setup.sh

# Run diagnostics
./diagnose_mac.sh
```

## Results

After using these scripts on my M5 MacBook Pro:

| Metric | Before | After |
|--------|--------|-------|
| Setup time | 45 min | 2 min |
| Dock clutter | 12 icons | 6 icons |
| Screenshot finding | Hard | Easy (folder) |
| Diagnostics | Manual | Automated |

## Future Plans

- [ ] Add `brew bundle` support
- [ ] iStat Menu config export
- [ ] Backup/restore preferences
- [ ] Menu bar app (SwiftUI)

## Get Involved

- ⭐ Star the repo
- 🍴 Fork and customize
- 🐛 Report issues
- 💡 Submit PRs

---

**Download:** [GitHub Repository](https://github.com/irfan/macOS-Setup-Tools)

Questions? [@irfan](https://github.com/irfan)