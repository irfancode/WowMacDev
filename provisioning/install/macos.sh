#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting macOS system preferences..."

# ── General ──────────────────────────────────────
# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
# Locale
defaults write NSGlobalDomain AppleLocale -string "en_US@rg=sgzzzz"

# ── Keyboard ─────────────────────────────────────
# Fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
# Disable press-and-hold for accented characters (enables key repeat)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# ── Dock ─────────────────────────────────────────
# Auto-hide Dock
defaults write com.apple.dock autohide -bool true
# Remove auto-hide delay
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
# Smaller icons
defaults write com.apple.dock tilesize -int 61
# Magnification on
defaults write com.apple.dock magnification -bool true
# Show recent apps
defaults write com.apple.dock show-recents -bool true
# Bottom orientation
defaults write com.apple.dock orientation -string "bottom"
# Minimize animation
defaults write com.apple.dock mineffect -string "genie"

# ── Finder ───────────────────────────────────────
# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true
# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# ── Trackpad ─────────────────────────────────────
# Enable tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# ── Screenshots ──────────────────────────────────
# Save screenshots to ~/Desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"
# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# ── Mission Control ──────────────────────────────
# Don't rearrange spaces automatically
defaults write com.apple.dock mru-spaces -bool false

# ── Hot Corners ──────────────────────────────────
# Bottom left → Mission Control
defaults write com.apple.dock wvous-bl-corner -int 2
defaults write com.apple.dock wvous-bl-modifier -int 0

# ── Restart affected services ────────────────────
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "==> macOS preferences applied"
echo "    (Some changes may require logout/restart)"
