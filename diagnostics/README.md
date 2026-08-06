# WowMacDev — Diagnostics

Unified macOS diagnostic toolkit, merged from:

| Upstream repo | What it contributed |
|---|---|
| `macOS-System-Diagnostics` | 16-check parallel hardware/software scanner |
| `macos-setup-tools` | hardened sequential checks, performance scan + recommendations engine, disk forensics, 20-step macOS optimizer |

## Scripts

| Script | What it does | macOS/Linux |
|---|---|---|
| [`diagnose.sh`](diagnose.sh) | Full system health report: hardware, GPU, storage, network, audio, Bluetooth, USB, display, battery, thermal, memory, CPU + performance overview and recommendations. `--quick`, `--serial`, `--json`. | macOS |
| [`performance.sh`](performance.sh) | Focused performance scan: top CPU/MEM processes, swap, disk I/O, login items, Spotlight, battery + actionable recommendations. | macOS |
| [`disk-usage.sh`](disk-usage.sh) | Top-10 largest directories and files (spaces-in-filenames safe). | macOS & Linux |
| [`optimize.sh`](optimize.sh) | Opinionated 20-step macOS customization (Dock, Finder, Trackpad, hot corners, screenshots, Safari, Stage Manager…). `--dry-run` and `--yes` supported. | macOS |

## Quick start

```bash
# Full diagnosis (exit code: 0 healthy, 1 warnings, 2 critical)
./diagnose.sh

# Quick core check only
./diagnose.sh --quick

# Machine-readable output
./diagnose.sh --json

# Performance scan
./performance.sh

# Find what's eating your disk
./disk-usage.sh ~

# Preview macOS optimizations without applying
./optimize.sh --dry-run

# Actually apply them
./optimize.sh --yes
```

## Fixes applied during consolidation

- **Thermal check** no longer falls back to `hw.ncpu` (upstream reported the core count as a "thermal level" on Apple Silicon).
- **Swap analysis** now parses `vm.swapusage` correctly (`$3` total, `$6` used); upstream read the literal words `used`/`free` and could never trigger a warning.
- **Memory** uses `pagesize` dynamically instead of a hardcoded 16384-byte page (wrong on Intel).
- **Disk check** guards empty values (`df` failure no longer prints `integer expression expected`).
- **optimize.sh** removed the bare `set -e` that aborted mid-run on an unguarded `killall`; every `defaults write` and `killall` is now failure-tolerant.
- **powermetrics** only runs when root, so it can't hang waiting for a sudo password.
- **disk-usage.sh** handles filenames with spaces and no longer relies on GNU-only `sort -h`.
