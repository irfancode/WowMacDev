#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_DIR="$SCRIPT_DIR/exports"
CONFIG_DIR="$SCRIPT_DIR/configs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$EXPORT_DIR/export_log_$TIMESTAMP.txt"

mkdir -p "$EXPORT_DIR" "$CONFIG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE" >&2
}

header() {
    echo ""
    echo "========================================"
    echo "  $1"
    echo "========================================"
    log "$1"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

export_homebrew_formulas() {
    header "Exporting Homebrew Formulae (CLI Tools)"
    
    if check_command brew; then
        brew list --formula 2>/dev/null | sort > "$EXPORT_DIR/homebrew_formulas.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/homebrew_formulas.txt")
        log "Exported $COUNT formulas"
        echo "  Found: $COUNT formulae"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Sample: $(head -5 "$EXPORT_DIR/homebrew_formulas.txt" | tr '\n' ' ')..."
        fi
    else
        echo "  [SKIP] Homebrew not installed"
        log "Homebrew not found - skipped"
        touch "$EXPORT_DIR/homebrew_formulas.txt"
    fi
}

export_homebrew_casks() {
    header "Exporting Homebrew Casks (GUI Apps)"
    
    if check_command brew; then
        brew list --cask 2>/dev/null | sort > "$EXPORT_DIR/homebrew_casks.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/homebrew_casks.txt")
        log "Exported $COUNT casks"
        echo "  Found: $COUNT casks"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Sample: $(head -5 "$EXPORT_DIR/homebrew_casks.txt" | tr '\n' ' ')..."
        fi
    else
        echo "  [SKIP] Homebrew not installed"
        log "Homebrew not found - skipped"
        touch "$EXPORT_DIR/homebrew_casks.txt"
    fi
}

export_app_store_apps() {
    header "Exporting Mac App Store Apps"
    
    if check_command mas; then
        mas list 2>/dev/null > "$EXPORT_DIR/app_store_apps.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/app_store_apps.txt")
        log "Exported $COUNT App Store apps"
        echo "  Found: $COUNT App Store apps"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Note: App IDs and names exported for mas CLI"
            echo "  Sample: $(head -3 "$EXPORT_DIR/app_store_apps.txt" | cut -d' ' -f2- | tr '\n' ' ')..."
        else
            echo "  Tip: Sign in with 'mas signin' to export purchased apps"
        fi
    else
        echo "  [SKIP] mas CLI not installed"
        echo "  Install with: brew install mas"
        log "mas CLI not found - skipped"
        touch "$EXPORT_DIR/app_store_apps.txt"
    fi
}

export_system_applications() {
    header "Exporting System Applications (/Applications)"
    
    if [ -d "/Applications" ]; then
        ls /Applications/ 2>/dev/null | grep '\.app$' | sed 's/\.app$//' | sort > "$EXPORT_DIR/system_applications.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/system_applications.txt")
        log "Exported $COUNT system applications"
        echo "  Found: $COUNT apps"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Sample: $(head -5 "$EXPORT_DIR/system_applications.txt" | tr '\n' ' ')..."
        fi
    else
        echo "  [ERROR] /Applications directory not found"
        touch "$EXPORT_DIR/system_applications.txt"
    fi
}

export_user_applications() {
    header "Exporting User Applications (~/Applications)"
    
    if [ -d "$HOME/Applications" ]; then
        ls "$HOME/Applications/" 2>/dev/null | grep '\.app$' | sed 's/\.app$//' | sort > "$EXPORT_DIR/user_applications.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/user_applications.txt")
        log "Exported $COUNT user applications"
        echo "  Found: $COUNT user apps"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Sample: $(head -5 "$EXPORT_DIR/user_applications.txt" | tr '\n' ' ')..."
        fi
    else
        echo "  [SKIP] No ~/Applications directory"
        log "No ~/Applications directory - skipped"
        touch "$EXPORT_DIR/user_applications.txt"
    fi
}

export_npm_packages() {
    header "Exporting npm Global Packages"
    
    if check_command npm; then
        npm list -g --depth=0 2>/dev/null | grep -E "^\s{2,3}[├└]─" | awk '{print $2}' | cut -d'@' -f1 | grep -v '^$' | sort > "$EXPORT_DIR/npm_packages.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/npm_packages.txt")
        log "Exported $COUNT npm packages"
        echo "  Found: $COUNT npm packages"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Sample: $(head -5 "$EXPORT_DIR/npm_packages.txt" | tr '\n' ' ')..."
        fi
    else
        echo "  [SKIP] npm not installed"
        log "npm not found - skipped"
        touch "$EXPORT_DIR/npm_packages.txt"
    fi
}

export_pnpm_packages() {
    header "Exporting pnpm Global Packages"
    
    if check_command pnpm; then
        pnpm list -g --depth=0 --json 2>/dev/null | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | grep -v '^$' | sort > "$EXPORT_DIR/pnpm_packages.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/pnpm_packages.txt")
        log "Exported $COUNT pnpm packages"
        echo "  Found: $COUNT pnpm packages"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Sample: $(head -5 "$EXPORT_DIR/pnpm_packages.txt" | tr '\n' ' ')..."
        fi
    else
        echo "  [SKIP] pnpm not installed"
        log "pnpm not found - skipped"
        touch "$EXPORT_DIR/pnpm_packages.txt"
    fi
}

export_yarn_packages() {
    header "Exporting yarn Global Packages"
    
    if check_command yarn; then
        yarn global list --no-progress 2>/dev/null | grep -E "^\s{2,3}├|^\s{2,3}└" | awk '{print $2}' | sort > "$EXPORT_DIR/yarn_packages.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/yarn_packages.txt")
        log "Exported $COUNT yarn packages"
        echo "  Found: $COUNT yarn packages"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Sample: $(head -5 "$EXPORT_DIR/yarn_packages.txt" | tr '\n' ' ')..."
        fi
    else
        echo "  [SKIP] yarn not installed"
        log "yarn not found - skipped"
        touch "$EXPORT_DIR/yarn_packages.txt"
    fi
}

export_pip_packages() {
    header "Exporting pip Global Packages"
    
    if check_command pip3; then
        pip3 list 2>/dev/null | grep -v "^Package" | awk '{print $1}' | sort > "$EXPORT_DIR/pip_packages.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/pip_packages.txt")
        log "Exported $COUNT pip packages"
        echo "  Found: $COUNT pip packages"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Sample: $(head -5 "$EXPORT_DIR/pip_packages.txt" | tr '\n' ' ')..."
        fi
    else
        echo "  [SKIP] pip3 not installed"
        log "pip3 not found - skipped"
        touch "$EXPORT_DIR/pip_packages.txt"
    fi
}

export_pipx_packages() {
    header "Exporting pipx Packages"
    
    if check_command pipx; then
        pipx list 2>/dev/null | grep -E "^\s{2,}[a-z]" | awk '{print $1}' | sort > "$EXPORT_DIR/pipx_packages.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/pipx_packages.txt")
        log "Exported $COUNT pipx packages"
        echo "  Found: $COUNT pipx packages"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Sample: $(head -5 "$EXPORT_DIR/pipx_packages.txt" | tr '\n' ' ')..."
        fi
    else
        echo "  [SKIP] pipx not installed"
        log "pipx not found - skipped"
        touch "$EXPORT_DIR/pipx_packages.txt"
    fi
}

export_gem_packages() {
    header "Exporting Ruby Gems"
    
    if check_command gem; then
        gem list --no-versions 2>/dev/null | awk '{print $1}' | sort > "$EXPORT_DIR/gem_packages.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/gem_packages.txt")
        log "Exported $COUNT gems"
        echo "  Found: $COUNT gems"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Sample: $(head -5 "$EXPORT_DIR/gem_packages.txt" | tr '\n' ' ')..."
        fi
    else
        echo "  [SKIP] gem not installed"
        log "gem not found - skipped"
        touch "$EXPORT_DIR/gem_packages.txt"
    fi
}

export_vscode_extensions() {
    header "Exporting VS Code Extensions"
    
    if check_command code; then
        code --list-extensions 2>/dev/null | sort > "$EXPORT_DIR/vscode_extensions.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/vscode_extensions.txt")
        log "Exported $COUNT VS Code extensions"
        echo "  Found: $COUNT VS Code extensions"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Sample: $(head -5 "$EXPORT_DIR/vscode_extensions.txt" | tr '\n' ' ')..."
        fi
    else
        echo "  [SKIP] VS Code CLI (code) not installed"
        echo "  Install VS Code and run: Shell Command: Install 'code' command in PATH"
        log "VS Code CLI not found - skipped"
        touch "$EXPORT_DIR/vscode_extensions.txt"
    fi
}

export_docker_images() {
    header "Exporting Docker Images"
    
    if check_command docker; then
        docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -v "<none>" | sort > "$EXPORT_DIR/docker_images.txt" || true
        COUNT=$(wc -l < "$EXPORT_DIR/docker_images.txt")
        log "Exported $COUNT Docker images"
        echo "  Found: $COUNT Docker images"
        
        if [ "$COUNT" -gt 0 ]; then
            echo "  Note: Export full images with: docker save \$(docker images -q) -o images.tar"
        fi
    else
        echo "  [SKIP] Docker not installed"
        log "Docker not found - skipped"
        touch "$EXPORT_DIR/docker_images.txt"
    fi
}

export_git_config() {
    header "Exporting Git Configuration"
    
    if [ -f "$HOME/.gitconfig" ]; then
        cp "$HOME/.gitconfig" "$CONFIG_DIR/gitconfig"
        log "Exported Git global config"
        echo "  Saved: ~/.gitconfig"
    fi
    
    if [ -f "$HOME/.gitignore_global" ]; then
        cp "$HOME/.gitignore_global" "$CONFIG_DIR/gitignore_global"
        log "Exported Git global ignore"
        echo "  Saved: ~/.gitignore_global"
    fi
}

export_shell_config() {
    header "Exporting Shell Configuration"
    
    for file in .zshrc .bashrc .zprofile .bash_profile .profile; do
        if [ -f "$HOME/$file" ]; then
            cp "$HOME/$file" "$CONFIG_DIR/${file#.}""_backup" 2>/dev/null || true
            log "Exported $file"
            echo "  Saved: ~/$file"
        fi
    done
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "  Note: .oh-my-zsh detected - backup manually if needed"
    fi
}

export_mas_signin_status() {
    header "Mac App Store Sign-in Status"
    
    if check_command mas; then
        if mas account &>/dev/null; then
            mas account > "$EXPORT_DIR/mas_account.txt"
            echo "  Signed in as: $(cat "$EXPORT_DIR/mas_account.txt")"
        else
            echo "  Not signed in - run 'mas signin' after setup"
            echo "not_signed_in" > "$EXPORT_DIR/mas_account.txt"
        fi
    fi
}

generate_summary() {
    header "Export Summary"
    
    echo ""
    echo "Files saved to: $EXPORT_DIR"
    echo "Configs saved to: $CONFIG_DIR"
    echo "Log file: $LOG_FILE"
    echo ""
    echo "Export Statistics:"
    printf "  %-30s %5s\n" "Homebrew Formulae:" "$(wc -l < "$EXPORT_DIR/homebrew_formulas.txt")"
    printf "  %-30s %5s\n" "Homebrew Casks:" "$(wc -l < "$EXPORT_DIR/homebrew_casks.txt")"
    printf "  %-30s %5s\n" "App Store Apps:" "$(wc -l < "$EXPORT_DIR/app_store_apps.txt")"
    printf "  %-30s %5s\n" "System Applications:" "$(wc -l < "$EXPORT_DIR/system_applications.txt")"
    printf "  %-30s %5s\n" "User Applications:" "$(wc -l < "$EXPORT_DIR/user_applications.txt")"
    printf "  %-30s %5s\n" "npm Packages:" "$(wc -l < "$EXPORT_DIR/npm_packages.txt")"
    printf "  %-30s %5s\n" "pnpm Packages:" "$(wc -l < "$EXPORT_DIR/pnpm_packages.txt")"
    printf "  %-30s %5s\n" "yarn Packages:" "$(wc -l < "$EXPORT_DIR/yarn_packages.txt")"
    printf "  %-30s %5s\n" "pip Packages:" "$(wc -l < "$EXPORT_DIR/pip_packages.txt")"
    printf "  %-30s %5s\n" "pipx Packages:" "$(wc -l < "$EXPORT_DIR/pipx_packages.txt")"
    printf "  %-30s %5s\n" "Ruby Gems:" "$(wc -l < "$EXPORT_DIR/gem_packages.txt")"
    printf "  %-30s %5s\n" "VS Code Extensions:" "$(wc -l < "$EXPORT_DIR/vscode_extensions.txt")"
    printf "  %-30s %5s\n" "Docker Images:" "$(wc -l < "$EXPORT_DIR/docker_images.txt")"
    echo ""
    echo "Next Steps:"
    echo "  1. Review exported files in exports/"
    echo "  2. Edit files to add/remove apps as needed"
    echo "  3. Use '#' to comment out items"
    echo "  4. Push to GitHub: ./mac-app-sync.sh sync"
    log "Export completed successfully"
}

main() {
    echo "========================================"
    echo "  Mac App Export Script v2.0"
    echo "  $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"
    log "=== Starting Export ==="
    
    export_homebrew_formulas
    export_homebrew_casks
    export_app_store_apps
    export_system_applications
    export_user_applications
    export_npm_packages
    export_pnpm_packages
    export_yarn_packages
    export_pip_packages
    export_pipx_packages
    export_gem_packages
    export_vscode_extensions
    export_docker_images
    export_git_config
    export_shell_config
    export_mas_signin_status
    
    generate_summary
}

main "$@"
