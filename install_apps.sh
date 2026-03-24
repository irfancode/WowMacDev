#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_DIR="$SCRIPT_DIR/exports"

BREW_FORMULAS="$EXPORT_DIR/homebrew_formulas.txt"
BREW_CASKS="$EXPORT_DIR/homebrew_casks.txt"
APP_STORE="$EXPORT_DIR/app_store_apps.txt"
NPM_PKGS="$EXPORT_DIR/npm_packages.txt"
PNPM_PKGS="$EXPORT_DIR/pnpm_packages.txt"
YARN_PKGS="$EXPORT_DIR/yarn_packages.txt"

echo "========================================"
echo "  Mac App Install Script"
echo "========================================"
echo ""
echo "This script will install all your apps on a fresh Mac."
echo ""

check_file() {
    if [ ! -f "$1" ]; then
        echo "  -> File not found: $1"
        echo "  -> Run export_apps.sh first on your current Mac!"
        exit 1
    fi
}

check_file "$BREW_FORMULAS"
check_file "$BREW_CASKS"

prompt_install() {
    read -p "$1 [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
    return 0
}

install_homebrew() {
    echo ""
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

if ! command -v brew &> /dev/null; then
    echo "[PREP] Homebrew not found!"
    if prompt_install "Do you want to install Homebrew now?"; then
        install_homebrew
    else
        echo "Cannot continue without Homebrew. Exiting."
        exit 1
    fi
else
    echo "[OK] Homebrew is installed"
fi

echo ""
echo "========================================"
echo "  Installing Homebrew Formulae"
echo "========================================"
echo ""

if [ -s "$BREW_FORMULAS" ]; then
    FORMULA_COUNT=$(wc -l < "$BREW_FORMULAS")
    echo "Installing $FORMULA_COUNT Homebrew formulae..."
    
    brew install $(cat "$BREW_FORMULAS" | grep -v "^#" | grep -v "^$" | tr '\n' ' ')
    
    echo ""
    echo "Formulae installation complete!"
else
    echo "No formulae to install (file is empty)"
fi

echo ""
echo "========================================"
echo "  Installing Homebrew Casks"
echo "========================================"
echo ""

if [ -s "$BREW_CASKS" ]; then
    CASK_COUNT=$(wc -l < "$BREW_CASKS")
    echo "Installing $CASK_COUNT Homebrew casks..."
    
    brew install --cask $(cat "$BREW_CASKS" | grep -v "^#" | grep -v "^$" | tr '\n' ' ')
    
    echo ""
    echo "Casks installation complete!"
else
    echo "No casks to install (file is empty)"
fi

echo ""
echo "========================================"
echo "  Installing npm Global Packages"
echo "========================================"
echo ""

if command -v npm &> /dev/null && [ -s "$NPM_PKGS" ]; then
    NPM_COUNT=$(wc -l < "$NPM_PKGS" | tr -d ' ')
    if [ "$NPM_COUNT" -gt 0 ]; then
        echo "Installing $NPM_COUNT npm global packages..."
        while IFS= read -r pkg; do
            [ -z "$pkg" ] && continue
            echo "  Installing: $pkg"
            npm install -g "$pkg" 2>/dev/null || echo "  -> Failed: $pkg"
        done < "$NPM_PKGS"
        echo ""
        echo "npm packages installation complete!"
    else
        echo "No npm packages to install"
    fi
else
    echo "npm not found or no packages file"
fi

echo ""
echo "========================================"
echo "  Installing pnpm Global Packages"
echo "========================================"
echo ""

if command -v pnpm &> /dev/null && [ -s "$PNPM_PKGS" ]; then
    PNPM_COUNT=$(wc -l < "$PNPM_PKGS" | tr -d ' ')
    if [ "$PNPM_COUNT" -gt 0 ]; then
        echo "Installing $PNPM_COUNT pnpm global packages..."
        while IFS= read -r pkg; do
            [ -z "$pkg" ] && continue
            echo "  Installing: $pkg"
            pnpm add -g "$pkg" 2>/dev/null || echo "  -> Failed: $pkg"
        done < "$PNPM_PKGS"
        echo ""
        echo "pnpm packages installation complete!"
    else
        echo "No pnpm packages to install"
    fi
else
    echo "pnpm not found or no packages file"
fi

echo ""
echo "========================================"
echo "  Installing yarn Global Packages"
echo "========================================"
echo ""

if command -v yarn &> /dev/null && [ -s "$YARN_PKGS" ]; then
    YARN_COUNT=$(wc -l < "$YARN_PKGS" | tr -d ' ')
    if [ "$YARN_COUNT" -gt 0 ]; then
        echo "Installing $YARN_COUNT yarn global packages..."
        while IFS= read -r pkg; do
            [ -z "$pkg" ] && continue
            echo "  Installing: $pkg"
            yarn global add "$pkg" 2>/dev/null || echo "  -> Failed: $pkg"
        done < "$YARN_PKGS"
        echo ""
        echo "yarn packages installation complete!"
    else
        echo "No yarn packages to install"
    fi
else
    echo "yarn not found or no packages file"
fi

echo ""
echo "========================================"
echo "  Installing App Store Apps"
echo "========================================"
echo ""

if ! command -v mas &> /dev/null; then
    echo "Installing mas (Mac App Store CLI)..."
    brew install mas
fi

if [ -s "$APP_STORE" ]; then
    echo "Note: App Store apps require Apple ID sign-in"
    echo ""
    
    if prompt_install "Do you want to install App Store apps?"; then
        APP_COUNT=$(wc -l < "$APP_STORE" | tr -d ' ')
        echo "Installing $APP_COUNT App Store apps..."
        
        while IFS= read -r line; do
            [ -z "$line" ] && continue
            APP_ID=$(echo "$line" | awk '{print $1}')
            APP_NAME=$(echo "$line" | sed 's/^[0-9]* //')
            echo "  Installing: $APP_NAME"
            mas install "$APP_ID" 2>/dev/null || echo "  -> Failed or already installed: $APP_NAME"
        done < "$APP_STORE"
        
        echo ""
        echo "App Store apps installation complete!"
    else
        echo "Skipping App Store apps"
    fi
else
    echo "No App Store apps to install"
fi

echo ""
echo "========================================"
echo "  Installation Complete!"
echo "========================================"
echo ""
echo "Summary:"
echo "  - Homebrew formulae: installed"
echo "  - Homebrew casks: installed"
echo "  - npm packages: installed"
echo "  - pnpm packages: installed"
echo "  - yarn packages: installed"
echo "  - App Store apps: see above"
echo ""
echo "Run 'brew doctor' to verify your installation."
echo "Run 'brew upgrade' to update all packages."
