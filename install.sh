#!/bin/bash

set -e

echo "=========================================="
echo "  macOS Setup Script"
echo "=========================================="

if [[ "$(uname -m)" == "arm64" ]]; then
    echo ""
    echo "Apple Silicon detected. Checking Rosetta 2..."
    if ! pgrep -q oahd; then
        echo "Installing Rosetta 2..."
        softwareupdate --install-rosetta --agree-to-license
    else
        echo "Rosetta 2 already installed."
    fi
fi

echo ""
echo "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed."
fi

echo ""
echo "Updating Homebrew..."
brew update

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

if [[ ! -f "$BREWFILE" ]]; then
    echo "Error: Brewfile not found at $BREWFILE"
    exit 1
fi

echo ""
echo "Installing packages from Brewfile..."
echo "This may take a while..."
brew bundle install --file="$BREWFILE"

echo ""
echo "Setting up Fish shell..."
FISH_PATH="$(which fish)"
if ! grep -q "$FISH_PATH" /etc/shells 2>/dev/null; then
    echo "Adding Fish to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells
fi

read -p "Do you want to set Fish as your default shell? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    chsh -s "$FISH_PATH"
    echo "Default shell changed to Fish."
fi

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Installed:"
echo "  - $(brew list --formula | wc -l | tr -d ' ') Homebrew formulae"
echo "  - $(brew list --cask | wc -l | tr -d ' ') Homebrew casks"
echo "  - $(code --list-extensions | wc -l | tr -d ' ') VS Code extensions"
echo ""
echo "You may need to:"
echo "  1. Restart your terminal"
echo "  2. Open apps once to grant permissions"
echo "  3. Sign in to apps that require accounts"
echo ""
