#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_DIR="$SCRIPT_DIR/exports"

VERSION="2.0.0"

show_banner() {
    echo ""
    echo "========================================"
    echo "  Mac App Sync v$VERSION"
    echo "  Backup & Restore Your Mac Apps"
    echo "========================================"
    echo ""
}

show_usage() {
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  export          Export all apps and configs from current Mac"
    echo "  install        Install apps on a new Mac from exports/"
    echo "  update         Update existing packages, then install"
    echo "  sync           Export and push to GitHub"
    echo "  clean          Remove export files"
    echo "  list           List all exported items"
    echo "  verify         Verify export files exist"
    echo "  help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 export       # Save current setup"
    echo "  $0 install      # Install on new Mac"
    echo "  $0 sync         # Export and push to GitHub"
    echo ""
}

check_file() {
    if [ ! -f "$1" ]; then
        echo "[ERROR] File not found: $1"
        echo "        Run '$0 export' first on your source Mac!"
        return 1
    fi
    return 0
}

cmd_export() {
    echo "Running export script..."
    "$SCRIPT_DIR/export_apps.sh"
}

cmd_install() {
    echo "Running install script..."
    "$SCRIPT_DIR/install_apps.sh"
}

cmd_update() {
    echo ""
    echo "========================================"
    echo "  Update Mode"
    echo "========================================"
    echo ""
    
    check_file "$EXPORT_DIR/homebrew_formulas.txt" || exit 1
    check_file "$EXPORT_DIR/homebrew_casks.txt" || exit 1
    
    if ! command -v brew &> /dev/null; then
        echo "[ERROR] Homebrew not installed. Run install first."
        exit 1
    fi
    
    echo "This will update ALL existing packages to latest versions."
    read -p "Continue? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
    
    echo ""
    echo "Updating Homebrew..."
    brew update
    
    echo ""
    echo "Upgrading formulae..."
    brew upgrade
    
    echo ""
    echo "Upgrading casks..."
    brew upgrade --cask
    
    echo ""
    echo "Cleaning up old versions..."
    brew cleanup -s
    
    echo ""
    echo "Update complete! Now running install..."
    echo ""
    
    cmd_install
}

cmd_sync() {
    echo "Syncing to GitHub..."
    
    if ! command -v gh &> /dev/null; then
        echo "[ERROR] GitHub CLI (gh) not installed"
        echo "        Install with: brew install gh"
        exit 1
    fi
    
    if ! gh auth status &>/dev/null; then
        echo "[ERROR] Not logged in to GitHub"
        echo "        Run: gh auth login"
        exit 1
    fi
    
    cmd_export
    
    echo ""
    echo "Committing changes..."
    cd "$SCRIPT_DIR"
    git add -A
    git commit -m "Sync app list $(date +'%Y-%m-%d %H:%M')" || echo "Nothing to commit"
    
    echo ""
    echo "Pushing to GitHub..."
    git push origin main 2>/dev/null || git push -u origin main
    
    echo ""
    echo "Sync complete!"
    echo "View your repo at: https://github.com/$(gh api user --jq .login 2>/dev/null)/mac-app-sync"
}

cmd_clean() {
    echo ""
    echo "========================================"
    echo "  Clean Export Files"
    echo "========================================"
    echo ""
    
    if [ ! -d "$EXPORT_DIR" ]; then
        echo "No exports directory found."
        exit 0
    fi
    
    echo "Files to be removed:"
    ls -la "$EXPORT_DIR"/*.txt 2>/dev/null | awk '{print "  " $NF}'
    echo ""
    
    read -p "Remove all export files? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$EXPORT_DIR"/*.txt
        rm -f "$EXPORT_DIR"/*.log
        echo "Export files cleaned."
    else
        echo "Cancelled."
    fi
}

cmd_list() {
    echo ""
    echo "========================================"
    echo "  Exported Items"
    echo "========================================"
    echo ""
    
    local files=(
        "homebrew_formulas.txt:Homebrew Formulae"
        "homebrew_casks.txt:Homebrew Casks"
        "app_store_apps.txt:App Store Apps"
        "system_applications.txt:System Applications"
        "user_applications.txt:User Applications"
        "npm_packages.txt:npm Packages"
        "pnpm_packages.txt:pnpm Packages"
        "yarn_packages.txt:yarn Packages"
        "pip_packages.txt:pip Packages"
        "pipx_packages.txt:pipx Packages"
        "gem_packages.txt:Ruby Gems"
        "vscode_extensions.txt:VS Code Extensions"
        "docker_images.txt:Docker Images"
    )
    
    for item in "${files[@]}"; do
        local file="${item%%:*}"
        local name="${item##*:}"
        local path="$EXPORT_DIR/$file"
        
        if [ -f "$path" ]; then
            local count=$(grep -v "^#" "$path" 2>/dev/null | grep -v "^$" | wc -l | tr -d ' ')
            printf "  %-25s %4s items\n" "$name:" "$count"
        else
            printf "  %-25s %4s items\n" "$name:" "0"
        fi
    done
    
    echo ""
    echo "Config files:"
    if [ -d "$SCRIPT_DIR/configs" ]; then
        ls "$SCRIPT_DIR/configs" 2>/dev/null | while read f; do
            echo "  - $f"
        done
    else
        echo "  (none)"
    fi
}

cmd_verify() {
    echo ""
    echo "========================================"
    echo "  Verify Export Files"
    echo "========================================"
    echo ""
    
    local required_files=(
        "homebrew_formulas.txt"
        "homebrew_casks.txt"
    )
    
    local optional_files=(
        "app_store_apps.txt"
        "system_applications.txt"
        "user_applications.txt"
        "npm_packages.txt"
        "pnpm_packages.txt"
        "yarn_packages.txt"
        "pip_packages.txt"
        "pipx_packages.txt"
        "gem_packages.txt"
        "vscode_extensions.txt"
        "docker_images.txt"
    )
    
    local status=0
    
    echo "Required files:"
    for file in "${required_files[@]}"; do
        if [ -f "$EXPORT_DIR/$file" ]; then
            echo "  [OK] $file"
        else
            echo "  [MISSING] $file"
            status=1
        fi
    done
    
    echo ""
    echo "Optional files:"
    for file in "${optional_files[@]}"; do
        if [ -f "$EXPORT_DIR/$file" ]; then
            echo "  [OK] $file"
        else
            echo "  [--] $file (not available)"
        fi
    done
    
    echo ""
    if [ $status -eq 0 ]; then
        echo "All required files present!"
    else
        echo "Some required files are missing. Run '$0 export' first."
    fi
    
    return $status
}

main() {
    show_banner
    
    case "${1:-help}" in
        export)
            cmd_export
            ;;
        install)
            cmd_install
            ;;
        update)
            cmd_update
            ;;
        sync)
            cmd_sync
            ;;
        clean)
            cmd_clean
            ;;
        list)
            cmd_list
            ;;
        verify)
            cmd_verify
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            echo "Unknown command: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
