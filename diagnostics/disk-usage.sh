#!/bin/bash
# diagnostics/disk-usage.sh - disk space forensics (largest dirs & files).
#
# Merged from: macos-setup-tools/disk_usage.sh (the only disk forensics tool).
# Works on macOS and Linux.
#
# Fixes over upstream:
#   - filenames containing spaces are handled correctly (NUL-delimited find)
#   - sort fallback for systems without GNU `sort -h`

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

directory="${1:-$HOME}"

if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' does not exist" >&2
    exit 1
fi

echo "========================================="
echo "  Disk Usage Analysis"
echo "  Directory: $directory"
echo "========================================="
echo ""

echo "=== Top 10 Largest Directories ==="
du -ah "$directory" 2>/dev/null | sort -hr | head -n 10
echo ""

echo "=== Top 10 Largest Files (>5M) ==="
# NUL-delimited to survive spaces in names. Uses stat bytes for size.
find "$directory" -type f -size +5M \
    -not -path "*/.Trash*" \
    -not -path "*/.Spotlight-V100*" \
    -not -path "*/.fseventsd*" \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -print0 2>/dev/null | while IFS= read -r -d '' f; do
    size=$(stat -f "%z" "$f" 2>/dev/null || stat -c "%s" "$f" 2>/dev/null)
    [ -n "$size" ] && printf "%s\t%s\n" "$size" "$f"
done | sort -rn | head -n 10 | while IFS=$'\t' read -r size file; do
    # humanize
    h=$(awk -v n="$size" 'BEGIN{ if(n>=1073741824) printf "%.1fG", n/1073741824; else if(n>=1048576) printf "%.1fM", n/1048576; else printf "%.0fK", n/1024 }')
    echo "  $h  $file"
done

echo ""
echo "Tip: node_modules and .git directories are excluded by default."
