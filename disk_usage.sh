#!/bin/bash

if [[ "$(uname)" != "Darwin" && "$(uname)" != "Linux" ]]; then
    echo "Error: This script is for macOS/Linux only"
    exit 1
fi

directory="${1:-$HOME}"

if [[ ! -d "$directory" ]]; then
    echo "Error: Directory '$directory' does not exist"
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
find "$directory" -type f -size +5M -not -path "*/.Trash*" -not -path "*/.Spotlight-V100*" -not -path "*/.fseventsd*" -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null | while read -r f; do
    ls -lh "$f" 2>/dev/null | awk '{print $5, $9}'
done | sort -hr | head -n 10
