#!/bin/bash
# diagnostics/lib/common.sh - shared helpers for the WowMacDev diagnostics toolkit.
#
# Sources merged: macOS-System-Diagnostics, macos-setup-tools.
# Provides color-safe logging, macOS guard, and formatting used by every script.

if [ -n "${WOWMACDEV_COMMON_LOADED:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
export WOWMACDEV_COMMON_LOADED=1

# ---------------------------------------------------------------------------
# Colors (disabled when output is not a TTY or NO_COLOR is set)
# ---------------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    C_RESET='\033[0m'
    C_RED='\033[0;31m'
    C_GREEN='\033[0;32m'
    C_YELLOW='\033[1;33m'
    C_BLUE='\033[0;34m'
    C_PURPLE='\033[0;35m'
    C_CYAN='\033[0;36m'
    C_BOLD='\033[1m'
else
    C_RESET=''
    C_RED=''
    C_GREEN=''
    C_YELLOW=''
    C_BLUE=''
    C_PURPLE=''
    C_CYAN=''
    C_BOLD=''
fi

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
log_info()  { echo -e "${C_GREEN}[INFO]${C_RESET} $*"; }
log_warn()  { echo -e "${C_YELLOW}[WARN]${C_RESET} $*"; }
log_error() { echo -e "${C_RED}[ERROR]${C_RESET} $*"; }
log_step()  { echo -e "${C_CYAN}── $*${C_RESET}"; }

# ---------------------------------------------------------------------------
# macOS guard. Call early in every macOS-only script.
# ---------------------------------------------------------------------------
require_macos() {
    if [ "$(uname)" != "Darwin" ]; then
        echo "Error: This tool is for macOS only" >&2
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Command availability guard with a friendly message.
# ---------------------------------------------------------------------------
require_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "Required command not found: $cmd"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# A safe section banner that prints cleanly even when piped.
# ---------------------------------------------------------------------------
section() {
    echo ""
    echo -e "${C_BLUE}=== $* ===${C_RESET}"
}

# ---------------------------------------------------------------------------
# True-color aware separator (falls back gracefully).
# ---------------------------------------------------------------------------
hr() {
    printf '%s\n' "----------------------------------------------------------------------"
}

# ---------------------------------------------------------------------------
# Resolve a "yes"/"no"/"true"/"false"/"1"/"0" value into a normalized boolean.
# ---------------------------------------------------------------------------
is_true() {
    case "${1,,}" in
        yes|true|1|on) return 0 ;;
        *) return 1 ;;
    esac
}
