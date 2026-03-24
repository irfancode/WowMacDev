#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_DIR="$SCRIPT_DIR/exports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$EXPORT_DIR"

echo "========================================"
echo "  Mac App Export Script"
echo "========================================"
echo ""

echo "[1/6] Exporting Homebrew formulas..."
if command -v brew &> /dev/null; then
    brew list --formula 2>/dev/null > "$EXPORT_DIR/homebrew_formulas_$TIMESTAMP.txt" || true
    brew list --formula 2>/dev/null > "$EXPORT_DIR/homebrew_formulas.txt" || true
    echo "  -> Found $(wc -l < "$EXPORT_DIR/homebrew_formulas.txt") formulas"
else
    echo "  -> Homebrew not found, skipping..."
    touch "$EXPORT_DIR/homebrew_formulas.txt"
fi

echo ""
echo "[2/6] Exporting Homebrew casks..."
if command -v brew &> /dev/null; then
    brew list --cask 2>/dev/null > "$EXPORT_DIR/homebrew_casks_$TIMESTAMP.txt" || true
    brew list --cask 2>/dev/null > "$EXPORT_DIR/homebrew_casks.txt" || true
    echo "  -> Found $(wc -l < "$EXPORT_DIR/homebrew_casks.txt") casks"
else
    echo "  -> Homebrew not found, skipping..."
    touch "$EXPORT_DIR/homebrew_casks.txt"
fi

echo ""
echo "[3/6] Exporting App Store apps..."
if command -v mas &> /dev/null; then
    mas list 2>/dev/null > "$EXPORT_DIR/app_store_apps_$TIMESTAMP.txt" || true
    mas list 2>/dev/null > "$EXPORT_DIR/app_store_apps.txt" || true
    echo "  -> Found $(wc -l < "$EXPORT_DIR/app_store_apps.txt") App Store apps"
else
    echo "  -> mas CLI not found. Install with: brew install mas"
    touch "$EXPORT_DIR/app_store_apps.txt"
fi

echo ""
echo "[4/6] Exporting /Applications..."
if [ -d "/Applications" ]; then
    ls /Applications/ | grep '\.app$' | sed 's/\.app$//' > "$EXPORT_DIR/system_applications_$TIMESTAMP.txt" || true
    ls /Applications/ | grep '\.app$' | sed 's/\.app$//' > "$EXPORT_DIR/system_applications.txt" || true
    echo "  -> Found $(wc -l < "$EXPORT_DIR/system_applications.txt") apps"
fi

echo ""
echo "[5/6] Exporting ~/Applications..."
if [ -d "$HOME/Applications" ]; then
    ls ~/Applications/ 2>/dev/null | grep '\.app$' | sed 's/\.app$//' > "$EXPORT_DIR/user_applications_$TIMESTAMP.txt" || true
    ls ~/Applications/ 2>/dev/null | grep '\.app$' | sed 's/\.app$//' > "$EXPORT_DIR/user_applications.txt" || true
    echo "  -> Found $(wc -l < "$EXPORT_DIR/user_applications.txt") user apps"
else
    echo "  -> No ~/Applications directory"
    touch "$EXPORT_DIR/user_applications.txt"
fi

echo ""
echo "[6/6] Exporting npm global packages..."
if command -v npm &> /dev/null; then
    npm list -g --depth=0 2>/dev/null | tail -n +2 | awk '{print $2}' | cut -d'@' -f1 | grep -v '^$' > "$EXPORT_DIR/npm_packages_$TIMESTAMP.txt" || true
    npm list -g --depth=0 2>/dev/null | tail -n +2 | awk '{print $2}' | cut -d'@' -f1 | grep -v '^$' > "$EXPORT_DIR/npm_packages.txt" || true
    echo "  -> Found $(wc -l < "$EXPORT_DIR/npm_packages.txt") npm packages"
else
    echo "  -> npm not found, skipping..."
    touch "$EXPORT_DIR/npm_packages.txt"
fi

echo ""
echo "[EXTRA] Exporting pnpm global packages..."
if command -v pnpm &> /dev/null; then
    pnpm list -g --depth=0 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -v '^$' > "$EXPORT_DIR/pnpm_packages_$TIMESTAMP.txt" || true
    pnpm list -g --depth=0 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -v '^$' > "$EXPORT_DIR/pnpm_packages.txt" || true
    echo "  -> Found $(wc -l < "$EXPORT_DIR/pnpm_packages.txt") pnpm packages"
else
    echo "  -> pnpm not found, skipping..."
    touch "$EXPORT_DIR/pnpm_packages.txt"
fi

echo ""
echo "[EXTRA] Exporting yarn global packages..."
if command -v yarn &> /dev/null; then
    yarn global list 2>/dev/null | grep -E "^info " | awk '{print $2}' > "$EXPORT_DIR/yarn_packages_$TIMESTAMP.txt" || true
    yarn global list 2>/dev/null | grep -E "^info " | awk '{print $2}' > "$EXPORT_DIR/yarn_packages.txt" || true
    echo "  -> Found $(wc -l < "$EXPORT_DIR/yarn_packages.txt") yarn packages"
else
    echo "  -> yarn not found, skipping..."
    touch "$EXPORT_DIR/yarn_packages.txt"
fi

echo ""
echo "========================================"
echo "  Export Complete!"
echo "========================================"
echo ""
echo "Files saved to: $EXPORT_DIR"
echo ""
echo "Files created:"
ls -la "$EXPORT_DIR"/*.txt 2>/dev/null | awk '{print "  - " $NF}'
echo ""
echo "Run './install_apps.sh' on your new Mac to reinstall all apps."
