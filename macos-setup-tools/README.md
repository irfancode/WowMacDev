# macOS Setup & Diagnostic Utilities

A collection of bash scripts for macOS setup, diagnostics, and performance monitoring optimized for MacBook Pro M5 and newer.

![macOS](https://img.shields.io/badge/macOS-12%2B-brightgreen)
![Bash](https://img.shields.io/badge/Bash-5%2B-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## Scripts Overview

| Script | Purpose |
|--------|--------|
| `macbook_setup.sh` | Complete macOS customization & setup |
| `diagnose_mac.sh` | System hardware/software diagnostics |
| `check_mac_performance.sh` | Performance monitoring & analysis |
| `disk_usage.sh` | Disk space analyzer |

## Requirements

- macOS 12+ (Monterey or later)
-bash 5+
- Administrator privileges for some operations

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/macOS-Setup-Tools.git
cd macOS-Setup-Tools
chmod +x *.sh
```

## Quick Start

### 1. Run MacBook Setup (First Time)

```bash
./macbook_setup.sh
```

This will customize:
- ✅ Battery percentage in menu bar
- ✅ Dock auto-hide, magnification, icon size
- ✅ Finder settings (show hidden files, path bar)
- ✅ Menu bar items (WiFi, Bluetooth)
- ✅ Trackpad (tap to click, 3-finger drag)
- ✅ Hot corners (Mission Control, Desktop)
- ✅ Screenshots (save location, format)
- ✅ Safari (homepage, developer mode)
- ✅ Stage Manager
- ✅ Keyboard & scroll settings

### 2. Run Diagnostics

```bash
./diagnose_mac.sh
```

**Output:**
```
[HARDWARE OVERVIEW]
[INFO] Model: MacBookPro18,1
[INFO] CPU: Apple M5 Pro
[INFO] CPU Cores: 10 (Physical: 10)
[INFO] Memory: 32 GB
[INFO] Serial: C02XG0xxxxx

[STORAGE]
[INFO] Macintosh HD
[INFO]   File System: APFS
[INFO]   Total Space: 1 TB
[INFO]   Free Space: 512 GB
```

### 3. Check Performance

```bash
./check_mac_performance.sh
```

**Output:**
```
=== TOP CPU CONSUMING PROCESSES ===
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
irfan     1234 12.5  5.2 123456 7890 ?        S    10:00   2:30 Safari

=== MEMORY USAGE ===
Mach Virtual Memory Total:    32256 MB
Pages free:                        2048
Pages active:                      8192
...

=== ANALYSIS & RECOMMENDATIONS ===
⚠ High swap usage: 65% (2048MB used of 3144MB)
  → Consider closing memory-intensive apps or adding RAM
```

### 4. Disk Usage Analysis

```bash
./disk_usage.sh                    # Analyze HOME directory
./disk_usage.sh /Applications    # Analyze specific directory
```

**Output:**
```
=========================================
  Disk Usage Analysis
  Directory: /Users/irfan
=========================================

=== Top 10 Largest Directories ===
4.2G    ./Library
2.1G    ./Documents
1.8G    ./Downloads

=== Top 10 Largest Files (>5M) ===
2.4G    ./Library/Application Support/Adobe/...
1.2G    ./Downloads/Xcode_15.dmg
...
```

## Screenshots

### macbook_setup.sh

![Dock Settings](docs/setup-dock.png)
*Customized Dock with auto-hide and magnification*

![Menu Bar](docs/setup-menubar.png)
*Battery percentage and menu bar items*

### diagnose_mac.sh

![Hardware Overview](docs/diag-hardware.png)
*Complete hardware diagnostics*

### check_mac_performance.sh

![Performance](docs/perf-monitoring.png)
*Performance monitoring with alerts*

## Features

### macbook_setup.sh
- 20-step automated customization
- Safe defaults restoration
- Visual feedback with colors
- Manual steps list for advanced settings
- Requires restart notification

### diagnose_mac.sh
- 17 system checks in parallel
- Color-coded output (INFO/WARN/ERROR)
- Battery health analysis
- Network connectivity check
- Thermal monitoring

### check_mac_performance.sh
- Top CPU/Memory processes
- Swap usage analysis
- Disk I/O stats
- Login items review
- Smart recommendations

### disk_usage.sh
- Human-readable output
- Custom directory support
- Safe directory exclusions
- Sorted results

## Troubleshooting

### Permission Denied
```bash
sudo ./macbook_setup.sh
```

### Script Not Executable
```bash
chmod +x *.sh
```

### Already Running Issues
```bash
killall SystemUIServer Dock Finder
```

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature`)
3. Commit changes (`git commit -m 'Add feature'`)
4. Push to branch (`git push origin feature`)
5. Create Pull Request

## License

MIT License - See [LICENSE](LICENSE)

## Author

**Irfan** - [GitHub Profile](https://github.com/irfan)

## Acknowledgments

- [GregsGadgets](https://www.youtube.com/c/gregsgadgets) - Original setup inspiration
- [Apple Support](https://support.apple.com) - System Settings references