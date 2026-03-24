#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_DIR="$SCRIPT_DIR/exports"
CONFIG_DIR="$SCRIPT_DIR/configs"
LOG_FILE="$EXPORT_DIR/install_log_$(date +%Y%m%d_%H%M%S).txt"

mkdir -p "$EXPORT_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE" >&2
}

warn() {
    echo "[WARN] $1" | tee -a "$LOG_FILE"
}

success() {
    echo "[OK] $1"
}

header() {
    echo ""
    echo "========================================"
    echo "  $1"
    echo "========================================"
    log "$1"
}

check_file() {
    if [ ! -f "$1" ]; then
        touch "$1"
        warn "Created empty file: $1"
    fi
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

prompt_yes_no() {
    local prompt="$1"
    local default="${2:-N}"
    
    if [ "$default" = "Y" ]; then
        read -p "$prompt [Y/n]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            return 1
        fi
    else
        read -p "$prompt [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    return 0
}

install_homebrew() {
    header "Installing Homebrew"
    
    if check_command brew; then
        success "Homebrew already installed"
        log "Homebrew already installed"
        return 0
    fi
    
    echo "Installing Homebrew..."
    log "Installing Homebrew"
    
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if [[ "$(uname -m)" == "arm64" ]]; then
        (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        (echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    if check_command brew; then
        success "Homebrew installed successfully"
        log "Homebrew installed successfully"
    else
        error "Failed to install Homebrew"
        return 1
    fi
}

filter_packages() {
    local file="$1"
    grep -v "^#" "$file" 2>/dev/null | grep -v "^$" | grep -v "^#" || true
}

install_homebrew_formulas() {
    header "Installing Homebrew Formulae"
    
    local file="$EXPORT_DIR/homebrew_formulas.txt"
    check_file "$file"
    
    local packages=$(filter_packages "$file" | tr '\n' ' ')
    local count=$(filter_packages "$file" | wc -l | tr -d ' ')
    
    if [ -z "$packages" ] || [ "$count" -eq 0 ]; then
        echo "  No formulae to install"
        log "No formulae to install"
        return 0
    fi
    
    echo "  Installing $count formulae..."
    log "Installing $count formulae"
    
    local failed=0
    local installed=0
    
    for pkg in $packages; do
        if brew list "$pkg" &>/dev/null; then
            echo "  [SKIP] $pkg (already installed)"
        else
            echo "  Installing: $pkg"
            if brew install "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
                ((installed++))
            else
                error "Failed to install: $pkg"
                ((failed++))
            fi
        fi
    done
    
    echo ""
    echo "  Installed: $installed, Failed: $failed"
    log "Formulae: Installed $installed, Failed $failed"
}

install_homebrew_casks() {
    header "Installing Homebrew Casks"
    
    local file="$EXPORT_DIR/homebrew_casks.txt"
    check_file "$file"
    
    local packages=$(filter_packages "$file" | tr '\n' ' ')
    local count=$(filter_packages "$file" | wc -l | tr -d ' ')
    
    if [ -z "$packages" ] || [ "$count" -eq 0 ]; then
        echo "  No casks to install"
        log "No casks to install"
        return 0
    fi
    
    echo "  Installing $count casks..."
    log "Installing $count casks"
    
    local failed=0
    local installed=0
    
    for pkg in $packages; do
        if brew list --cask "$pkg" &>/dev/null; then
            echo "  [SKIP] $pkg (already installed)"
        else
            echo "  Installing: $pkg"
            if brew install --cask "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
                ((installed++))
            else
                error "Failed to install: $pkg"
                ((failed++))
            fi
        fi
    done
    
    echo ""
    echo "  Installed: $installed, Failed: $failed"
    log "Casks: Installed $installed, Failed $failed"
}

install_app_store_apps() {
    header "Installing Mac App Store Apps"
    
    if ! prompt_yes_no "Install App Store apps?" "N"; then
        echo "  Skipped by user"
        log "App Store apps skipped by user"
        return 0
    fi
    
    if ! check_command mas; then
        echo "  Installing mas CLI..."
        brew install mas
    fi
    
    local file="$EXPORT_DIR/app_store_apps.txt"
    check_file "$file"
    
    if [ ! -s "$file" ]; then
        echo "  No App Store apps to install"
        log "No App Store apps to install"
        return 0
    fi
    
    echo "  Note: Ensure you're signed in to Mac App Store"
    if ! mas account &>/dev/null; then
        echo "  Run 'mas signin' to sign in first!"
        warn "Not signed in to Mac App Store"
    fi
    
    local count=$(filter_packages "$file" | wc -l | tr -d ' ')
    echo "  Installing $count App Store apps..."
    log "Installing $count App Store apps"
    
    local failed=0
    local installed=0
    
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        [ "${line:0:1}" = "#" ] && continue
        
        local app_id=$(echo "$line" | awk '{print $1}')
        local app_name=$(echo "$line" | sed 's/^[0-9]* //')
        
        if mas list | grep -q "^$app_id "; then
            echo "  [SKIP] $app_name (already installed)"
        else
            echo "  Installing: $app_name (ID: $app_id)"
            if mas install "$app_id" 2>&1 | tee -a "$LOG_FILE"; then
                ((installed++))
            else
                error "Failed to install: $app_name"
                ((failed++))
            fi
        fi
    done < "$file"
    
    echo ""
    echo "  Installed: $installed, Failed: $failed"
    log "App Store: Installed $installed, Failed $failed"
}

install_npm_packages() {
    header "Installing npm Global Packages"
    
    if ! check_command npm; then
        echo "  [SKIP] npm not installed"
        log "npm not found - skipped"
        return 0
    fi
    
    local file="$EXPORT_DIR/npm_packages.txt"
    check_file "$file"
    
    local packages=$(filter_packages "$file" | tr '\n' ' ')
    local count=$(filter_packages "$file" | wc -l | tr -d ' ')
    
    if [ -z "$packages" ] || [ "$count" -eq 0 ]; then
        echo "  No npm packages to install"
        log "No npm packages to install"
        return 0
    fi
    
    echo "  Installing $count npm packages..."
    log "Installing $count npm packages"
    
    local failed=0
    local installed=0
    
    for pkg in $packages; do
        echo "  Installing: $pkg"
        if npm install -g "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
            ((installed++))
        else
            error "Failed to install: $pkg"
            ((failed++))
        fi
    done
    
    echo ""
    echo "  Installed: $installed, Failed: $failed"
    log "npm: Installed $installed, Failed $failed"
}

install_pnpm_packages() {
    header "Installing pnpm Global Packages"
    
    if ! check_command pnpm; then
        echo "  [SKIP] pnpm not installed"
        log "pnpm not found - skipped"
        return 0
    fi
    
    local file="$EXPORT_DIR/pnpm_packages.txt"
    check_file "$file"
    
    local packages=$(filter_packages "$file" | tr '\n' ' ')
    local count=$(filter_packages "$file" | wc -l | tr -d ' ')
    
    if [ -z "$packages" ] || [ "$count" -eq 0 ]; then
        echo "  No pnpm packages to install"
        log "No pnpm packages to install"
        return 0
    fi
    
    echo "  Installing $count pnpm packages..."
    log "Installing $count pnpm packages"
    
    local failed=0
    local installed=0
    
    for pkg in $packages; do
        echo "  Installing: $pkg"
        if pnpm add -g "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
            ((installed++))
        else
            error "Failed to install: $pkg"
            ((failed++))
        fi
    done
    
    echo ""
    echo "  Installed: $installed, Failed: $failed"
    log "pnpm: Installed $installed, Failed $failed"
}

install_yarn_packages() {
    header "Installing yarn Global Packages"
    
    if ! check_command yarn; then
        echo "  [SKIP] yarn not installed"
        log "yarn not found - skipped"
        return 0
    fi
    
    local file="$EXPORT_DIR/yarn_packages.txt"
    check_file "$file"
    
    local packages=$(filter_packages "$file" | tr '\n' ' ')
    local count=$(filter_packages "$file" | wc -l | tr -d ' ')
    
    if [ -z "$packages" ] || [ "$count" -eq 0 ]; then
        echo "  No yarn packages to install"
        log "No yarn packages to install"
        return 0
    fi
    
    echo "  Installing $count yarn packages..."
    log "Installing $count yarn packages"
    
    local failed=0
    local installed=0
    
    for pkg in $packages; do
        echo "  Installing: $pkg"
        if yarn global add "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
            ((installed++))
        else
            error "Failed to install: $pkg"
            ((failed++))
        fi
    done
    
    echo ""
    echo "  Installed: $installed, Failed: $failed"
    log "yarn: Installed $installed, Failed $failed"
}

install_pip_packages() {
    header "Installing pip Packages"
    
    if ! check_command pip3; then
        echo "  [SKIP] pip3 not installed"
        log "pip3 not found - skipped"
        return 0
    fi
    
    local file="$EXPORT_DIR/pip_packages.txt"
    check_file "$file"
    
    local packages=$(filter_packages "$file" | tr '\n' ' ')
    local count=$(filter_packages "$file" | wc -l | tr -d ' ')
    
    if [ -z "$packages" ] || [ "$count" -eq 0 ]; then
        echo "  No pip packages to install"
        log "No pip packages to install"
        return 0
    fi
    
    echo "  Installing $count pip packages..."
    log "Installing $count pip packages"
    
    local failed=0
    local installed=0
    
    for pkg in $packages; do
        echo "  Installing: $pkg"
        if pip3 install "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
            ((installed++))
        else
            error "Failed to install: $pkg"
            ((failed++))
        fi
    done
    
    echo ""
    echo "  Installed: $installed, Failed: $failed"
    log "pip: Installed $installed, Failed $failed"
}

install_pipx_packages() {
    header "Installing pipx Packages"
    
    if ! check_command pipx; then
        echo "  [SKIP] pipx not installed"
        log "pipx not found - skipped"
        return 0
    fi
    
    local file="$EXPORT_DIR/pipx_packages.txt"
    check_file "$file"
    
    local packages=$(filter_packages "$file" | tr '\n' ' ')
    local count=$(filter_packages "$file" | wc -l | tr -d ' ')
    
    if [ -z "$packages" ] || [ "$count" -eq 0 ]; then
        echo "  No pipx packages to install"
        log "No pipx packages to install"
        return 0
    fi
    
    echo "  Installing $count pipx packages..."
    log "Installing $count pipx packages"
    
    local failed=0
    local installed=0
    
    for pkg in $packages; do
        echo "  Installing: $pkg"
        if pipx install "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
            ((installed++))
        else
            error "Failed to install: $pkg"
            ((failed++))
        fi
    done
    
    echo ""
    echo "  Installed: $installed, Failed: $failed"
    log "pipx: Installed $installed, Failed $failed"
}

install_gem_packages() {
    header "Installing Ruby Gems"
    
    if ! check_command gem; then
        echo "  [SKIP] gem not installed"
        log "gem not found - skipped"
        return 0
    fi
    
    local file="$EXPORT_DIR/gem_packages.txt"
    check_file "$file"
    
    local packages=$(filter_packages "$file" | tr '\n' ' ')
    local count=$(filter_packages "$file" | wc -l | tr -d ' ')
    
    if [ -z "$packages" ] || [ "$count" -eq 0 ]; then
        echo "  No gems to install"
        log "No gems to install"
        return 0
    fi
    
    echo "  Installing $count gems..."
    log "Installing $count gems"
    
    local failed=0
    local installed=0
    
    for pkg in $packages; do
        echo "  Installing: $pkg"
        if gem install "$pkg" 2>&1 | tee -a "$LOG_FILE"; then
            ((installed++))
        else
            error "Failed to install: $pkg"
            ((failed++))
        fi
    done
    
    echo ""
    echo "  Installed: $installed, Failed: $failed"
    log "gem: Installed $installed, Failed $failed"
}

install_vscode_extensions() {
    header "Installing VS Code Extensions"
    
    if ! check_command code; then
        echo "  [SKIP] VS Code CLI not installed"
        echo "  Install VS Code and run: Shell Command: Install 'code' command in PATH"
        log "VS Code CLI not found - skipped"
        return 0
    fi
    
    local file="$EXPORT_DIR/vscode_extensions.txt"
    check_file "$file"
    
    local extensions=$(filter_packages "$file" | tr '\n' ' ')
    local count=$(filter_packages "$file" | wc -l | tr -d ' ')
    
    if [ -z "$extensions" ] || [ "$count" -eq 0 ]; then
        echo "  No VS Code extensions to install"
        log "No VS Code extensions to install"
        return 0
    fi
    
    echo "  Installing $count VS Code extensions..."
    log "Installing $count VS Code extensions"
    
    local failed=0
    local installed=0
    
    for ext in $extensions; do
        echo "  Installing: $ext"
        if code --install-extension "$ext" --force 2>&1 | tee -a "$LOG_FILE"; then
            ((installed++))
        else
            error "Failed to install: $ext"
            ((failed++))
        fi
    done
    
    echo ""
    echo "  Installed: $installed, Failed: $failed"
    log "VS Code: Installed $installed, Failed $failed"
}

restore_configs() {
    header "Restoring Configurations"
    
    if [ ! -d "$CONFIG_DIR" ]; then
        echo "  [SKIP] No configs directory found"
        return 0
    fi
    
    if prompt_yes_no "Restore configuration files?" "N"; then
        echo "  Restoring configuration files..."
        log "Restoring configuration files"
        
        for file in "$CONFIG_DIR"/*; do
            if [ -f "$file" ]; then
                local filename=$(basename "$file")
                local dest="$HOME/.$filename"
                
                if [ "$filename" = "gitconfig" ]; then
                    dest="$HOME/.gitconfig"
                elif [[ "$filename" == *"_backup" ]]; then
                    local base="${filename%_backup}"
                    dest="$HOME/.${base#.}"
                fi
                
                echo "  Copying: $file -> $dest"
                cp "$file" "$dest"
            fi
        done
        
        echo "  Configuration files restored"
        log "Configuration files restored"
    else
        echo "  Skipped by user"
        log "Config restore skipped by user"
    fi
}

final_verification() {
    header "Final Verification"
    
    echo ""
    echo "Checking installed tools:"
    
    local tools=("brew" "npm" "pnpm" "yarn" "pip3" "gem" "code" "mas" "docker" "gh")
    for tool in "${tools[@]}"; do
        if check_command "$tool"; then
            local version=$($tool --version 2>/dev/null | head -1 || echo "installed")
            success "$tool: $version"
        else
            warn "$tool: not installed"
        fi
    done
    
    echo ""
    echo "Log file: $LOG_FILE"
    log "=== Installation Complete ==="
}

main() {
    echo "========================================"
    echo "  Mac App Install Script v2.0"
    echo "  $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"
    echo ""
    echo "This script will install all your apps on a fresh Mac."
    echo "Log file: $LOG_FILE"
    echo ""
    
    if ! prompt_yes_no "Continue with installation?" "Y"; then
        echo "Installation cancelled."
        exit 0
    fi
    
    log "=== Starting Installation ==="
    
    install_homebrew
    install_homebrew_formulas
    install_homebrew_casks
    install_app_store_apps
    install_npm_packages
    install_pnpm_packages
    install_yarn_packages
    install_pip_packages
    install_pipx_packages
    install_gem_packages
    install_vscode_extensions
    restore_configs
    
    final_verification
    
    header "Installation Complete!"
    echo ""
    echo "Summary:"
    echo "  - Check log file: $LOG_FILE"
    echo "  - Run 'brew doctor' to verify Homebrew"
    echo "  - Restart terminal or run: source ~/.zprofile"
    echo "  - Sign in to App Store if needed"
    echo ""
    echo "Optional Next Steps:"
    echo "  1. Install macOS updates: sudo softwareupdate -ia"
    echo "  2. Restore Dock preferences"
    echo "  3. Sync your development environment (VS Code settings, etc.)"
}

main "$@"
