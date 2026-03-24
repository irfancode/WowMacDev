#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_DIR="$SCRIPT_DIR/exports"

check_file() {
    if [ ! -f "$1" ]; then
        echo "Error: $1 not found. Run export_apps.sh first!"
        exit 1
    fi
}

export_apps() {
    echo "Running export_apps.sh..."
    "$SCRIPT_DIR/export_apps.sh"
}

install_apps() {
    echo "Running install_apps.sh..."
    "$SCRIPT_DIR/install_apps.sh"
}

update_and_install() {
    echo ""
    echo "========================================"
    echo "  Update & Install Mode"
    echo "========================================"
    echo ""
    
    check_file "$EXPORT_DIR/homebrew_formulas.txt"
    check_file "$EXPORT_DIR/homebrew_casks.txt"
    
    echo "Updating existing packages first..."
    brew update
    brew upgrade
    
    echo ""
    echo "Installing from your saved list..."
    install_apps
}

case "${1:-}" in
    export)
        export_apps
        ;;
    install)
        install_apps
        ;;
    update)
        update_and_install
        ;;
    sync)
        export_apps
        echo ""
        echo "Syncing to GitHub..."
        cd "$SCRIPT_DIR"
        git add -A
        git commit -m "Auto-sync app list $(date +%Y-%m-%d)"
        git push origin main 2>/dev/null || git push -u origin main
        ;;
    *)
        echo "Usage: $0 {export|install|update|sync}"
        echo ""
        echo "Commands:"
        echo "  export  - Save current apps to exports/"
        echo "  install - Install apps from exports/"
        echo "  update  - Update packages then install"
        echo "  sync    - Export and push to GitHub"
        exit 1
        ;;
esac
