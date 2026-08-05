# Customization Guide

Personalize Mac App Sync for your specific needs.

## Table of Contents

1. [Adding New Export Types](#adding-new-export-types)
2. [Modifying Export Filters](#modifying-export-filters)
3. [Custom Installation Steps](#custom-installation-steps)
4. [Environment Variables](#environment-variables)
5. [Pre/Post Installation Hooks](#prepost-installation-hooks)
6. [Conditional Installs](#conditional-installs)
7. [Personal Templates](#personal-templates)

---

## Adding New Export Types

### Add a New Package Manager

Edit `export_apps.sh` and add a new function:

```bash
export_custom_packages() {
    header "Exporting Custom Package Manager"
    
    if check_command your-package-manager; then
        # Export command
        your-package-manager list 2>/dev/null > "$EXPORT_DIR/custom_packages.txt" || true
        
        COUNT=$(wc -l < "$EXPORT_DIR/custom_packages.txt")
        echo "  Found: $COUNT packages"
        log "Exported $COUNT custom packages"
    else
        echo "  [SKIP] Package manager not installed"
        touch "$EXPORT_DIR/custom_packages.txt"
    fi
}
```

Then call it in `main()`:
```bash
main() {
    # ... existing exports ...
    export_custom_packages
}
```

### Add a New Configuration Export

```bash
export_custom_config() {
    header "Exporting Custom Configuration"
    
    if [ -f "$HOME/.your-config" ]; then
        cp "$HOME/.your-config" "$CONFIG_DIR/your_config"
        echo "  Saved: ~/.your-config"
    fi
}
```

---

## Modifying Export Filters

### Filter Out Development vs Production

Edit the filter in `install_apps.sh`:

```bash
filter_packages() {
    local file="$1"
    local env="${2:-all}"  # all, dev, prod
    
    if [ "$env" = "dev" ]; then
        grep -v "^#" "$file" 2>/dev/null | grep -v "^$" | grep "dev" || true
    elif [ "$env" = "prod" ]; then
        grep -v "^#" "$file" 2>/dev/null | grep -v "^$" | grep -v "dev" || true
    else
        grep -v "^#" "$file" 2>/dev/null | grep -v "^$" || true
    fi
}
```

### Add Tag-Based Filtering

In `exports/homebrew_formulas.txt`:
```
# Development tools
git
node
python@3.12

# Production tools  #prod
nginx
redis

# Testing tools     #test
jest
pytest
```

Filter function:
```bash
filter_by_tag() {
    local file="$1"
    local tag="$2"
    
    if [ -n "$tag" ]; then
        grep "#$tag" "$file" | sed 's/#.*$//' || true
    else
        grep -v "^#" "$file" | grep -v "^$" || true
    fi
}
```

---

## Custom Installation Steps

### Add a Custom Installation Step

Edit `install_apps.sh` and add:

```bash
install_custom_tools() {
    header "Installing Custom Tools"
    
    # Your custom installation commands
    echo "  Installing from custom source..."
    
    # Example: Download and install from URL
    curl -L "https://example.com/tool.zip" -o /tmp/tool.zip
    unzip /tmp/tool.zip -d /Applications/
    
    # Example: Run custom setup script
    if [ -f "$SCRIPT_DIR/custom_setup.sh" ]; then
        bash "$SCRIPT_DIR/custom_setup.sh"
    fi
}
```

### Disable Specific Installations

Comment out lines in `main()`:

```bash
main() {
    # ... other installs ...
    # install_app_store_apps  # Disabled
    install_npm_packages
    # install_vscode_extensions  # Disabled
    # ...
}
```

---

## Environment Variables

Add configuration at the top of `install_apps.sh`:

```bash
# Configuration
SKIP_APP_STORE=${SKIP_APP_STORE:-false}
SKIP_NPM=${SKIP_NPM:-false}
SKIP_VSCODE=${SKIP_VSCODE:-false}
INSTALL_CONFIGS=${INSTALL_CONFIGS:-true}
BREW_PREFIX=${BREW_PREFIX:-""}  # Custom Homebrew prefix

# Use in installation functions
if [ "$SKIP_APP_STORE" = "true" ]; then
    return 0
fi
```

Usage:
```bash
SKIP_APP_STORE=true ./mac-app-sync.sh install
```

---

## Pre/Post Installation Hooks

### Create Hook Files

Create these files in the script directory:

```bash
# pre_install.sh - Runs before any installation
#!/bin/bash
echo "Running pre-installation tasks..."

# Update macOS
sudo softwareupdate -ia --force

# Clean up
brew cleanup -s
```

```bash
# post_install.sh - Runs after all installations
#!/bin/bash
echo "Running post-installation tasks..."

# Set up macOS preferences
defaults write com.apple.dock autohide -bool true
killall Dock

# Install fonts
brew install --cask font-fira-code
```

### Modify install_apps.sh

Add hooks:

```bash
main() {
    # Run pre-install hook
    if [ -f "$SCRIPT_DIR/pre_install.sh" ]; then
        bash "$SCRIPT_DIR/pre_install.sh"
    fi
    
    # ... installations ...
    
    # Run post-install hook
    if [ -f "$SCRIPT_DIR/post_install.sh" ]; then
        bash "$SCRIPT_DIR/post_install.sh"
    fi
}
```

---

## Conditional Installs

### Based on macOS Version

```bash
install_version_specific() {
    local os_version=$(sw_vers -productVersion)
    
    if [[ "$os_version" == "14."* ]]; then
        # Sonoma-specific installations
        brew install --cask sonoma-app
    elif [[ "$os_version" == "13."* ]]; then
        # Ventura-specific installations
        brew install --cask ventura-app
    fi
}
```

### Based on Apple Silicon vs Intel

```bash
install_arch_specific() {
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo "Installing Apple Silicon versions..."
        # ARM-specific installations
    else
        echo "Installing Intel versions..."
        # Intel-specific installations
    fi
}
```

### Based on Available Space

```bash
check_disk_space() {
    local required_space=10  # GB
    local available_space=$(df -g / | tail -1 | awk '{print $4}')
    
    if [ "$available_space" -lt "$required_space" ]; then
        echo "Warning: Low disk space ($available_space GB available)"
        # Optionally skip large installations
    fi
}
```

---

## Personal Templates

### Minimal Template (Dev Machine Only)

Create `exports/dev_only.txt`:
```
# Development only - no GUI apps
git
node
python@3.12
docker
kubectl
```

### Full Template (Complete Setup)

Create `exports/full_setup.txt`:
```
# Add comments to describe your setup
# Development
git
node
python@3.12

# Containers
docker
kubernetes-cli

# Productivity
slack
notion
```

### Work Template

Create `exports/work_setup.txt`:
```
# Work-specific tools (no personal apps)
git
slack
zoom
vscode
```

### Home Template

Create `exports/home_setup.txt`:
```
# Personal setup
spotify
steam
vlc
```

---

## Advanced: Multiple Configurations

### Profile-Based Installation

```bash
PROFILE="${1:-default}"

case "$PROFILE" in
    dev)
        FILTER_FILE="$EXPORT_DIR/dev_packages.txt"
        ;;
    work)
        FILTER_FILE="$EXPORT_DIR/work_packages.txt"
        ;;
    home)
        FILTER_FILE="$EXPORT_DIR/home_packages.txt"
        ;;
    *)
        FILTER_FILE="$EXPORT_DIR/default_packages.txt"
        ;;
esac

install_from_profile() {
    local packages=$(filter_packages "$FILTER_FILE")
    # ... install packages ...
}
```

Usage:
```bash
./install_apps.sh dev     # Install development profile
./install_apps.sh work    # Install work profile
./install_apps.sh home    # Install home profile
```

---

## Sharing Customizations

### Export Your Custom Scripts

```bash
# Create a templates directory
mkdir -p templates

# Save custom scripts
cp pre_install.sh templates/
cp post_install.sh templates/

# Add to git
git add templates/
git commit -m "Add custom installation templates"
```

### Share with Others

1. Fork the repository
2. Add your customizations
3. Submit a pull request
4. Document your changes in your fork's README

---

## Reset to Defaults

To reset all customizations:
```bash
git checkout HEAD -- *.sh
rm -rf exports/*.txt configs/*
./mac-app-sync.sh export
```
