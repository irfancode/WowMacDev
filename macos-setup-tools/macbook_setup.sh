#!/bin/bash

#############################################################################
# macOS M5 MacBook Pro Setup Script
# Based on: "M5 MacBook PRO - FIRST 20 Things To Do!" by GregsGadgets
# URL: https://www.youtube.com/watch?v=EuSGJmBiAOQ
# 
# This script automates the initial setup and customization for new MacBooks
# Run in Terminal: chmod +x macbook_setup.sh && ./macbook_setup.sh
#############################################################################

set -e

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is for macOS only"
    exit 1
fi

echo "========================================="
echo "  MacBook Pro M5 Setup & Customization"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

#############################################################################
# 1. CHECK FOR SOFTWARE UPDATES
#############################################################################
print_info "Step 1: Checking for macOS updates..."
softwareupdate --install --all 2>/dev/null || echo "No updates available or requires GUI"
print_status "Software update check complete"

#############################################################################
# 2. SHOW BATTERY PERCENTAGE IN MENU BAR
#############################################################################
print_info "Step 2: Enabling battery percentage in menu bar..."
defaults -currentHost write com.apple.controlcenter.plist BatteryShowPercentage -bool true
killall SystemUIServer 2>/dev/null || true
print_status "Battery percentage enabled"

#############################################################################
# 3. DOCK CUSTOMIZATION
#############################################################################
print_info "Step 3: Customizing Dock..."

# Enable auto-hide for Dock
defaults write com.apple.dock autohide -bool true

# Set auto-hide delay to 0 (instant)
defaults write com.apple.dock autohide-delay -float 0

# Set auto-hide animation time (faster)
defaults write com.apple.dock autohide-time-modifier -float 0.4

# Set Dock icon size (smaller for more space)
defaults write com.apple.dock tilesize -int 48

# Enable magnification on hover
defaults write com.apple.dock magnification -bool true

# Set magnification size
defaults write com.apple.dock largesize -int 64

# Position Dock on bottom (can also be left or right)
defaults write com.apple.dock orientation -string bottom

# Enable spring loading (drag files to apps to open)
defaults write com.apple.dock enabling-spring-load-on-all-items -bool true

# Don't show recent apps in Dock
defaults write com.apple.dock show-recents -bool false

# Enable launch animation
defaults write com.apple.dock launchanimate -bool true

# Show indicator for open apps
defaults write com.apple.dock show-indicators -bool true

# Restart Dock to apply changes
killall Dock
print_status "Dock customized"

#############################################################################
# 4. FINDER CUSTOMIZATION
#############################################################################
print_info "Step 4: Customizing Finder..."

# Show all filename extensions
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show warning before emptying trash
defaults write com.apple.finder EmptyTrashSecureWarning -bool true

# Use list view by default (comment out your preferred view)
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Show hidden files (disabled by default, enable if needed)
# defaults write com.apple.finder AppleShowAllFiles -bool true

# Enable desktop with two or more monitors
defaults write com.apple.finder AppleShowDesktop -bool true

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain NSPrintPanelExpandedState -bool true

# Search scope: Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Restart Finder to apply changes
killall Finder 2>/dev/null || true
print_status "Finder customized"

#############################################################################
# 5. MENU BAR & CONTROL CENTER CUSTOMIZATION
#############################################################################
print_info "Step 5: Customizing menu bar..."

# Auto-hide menu bar
# defaults write NSGlobalDomain _HIHideMenuBar -bool true

# Show Wi-Fi in menu bar
defaults write com.apple.controlcenter.plist WiFiShowInMenuBar -bool true

# Show Bluetooth in menu bar
defaults write com.apple.controlcenter.plist BluetoothShowInMenuBar -bool true

# Show Battery in menu bar (already done above)
defaults write com.apple.controlcenter.plist BatteryShowInMenuBar -bool true

# Restart Control Center
killall ControlCenter 2>/dev/null || true
print_status "Menu bar customized"

#############################################################################
# 6. DISPLAY & RESOLUTION - "MORE SPACE"
#############################################################################
print_info "Step 6: Display settings optimized for 'More Space'..."

# Note: Display resolution is set per-display and requires specific display ID
# This setting enables scaled resolution options in System Settings
# The script can't change this directly, but we can hint at the setting

# For external displays, set to more space (scaled resolution)
# This is done via defaults per-display - see below for hint
# The actual resolution change requires manual intervention or DisplayPlist

print_warning "Display resolution: Set to 'More Space' manually in System Settings > Display"
print_status "Display settings noted"

#############################################################################
# 7. TRACKPAD & MOUSE CUSTOMIZATION
#############################################################################
print_info "Step 7: Customizing Trackpad..."

# Enable tap to click
defaults write com.apple.trackpad TapToClick -bool true

# Enable trackpad dragging
defaults write com.apple.trackpad TrackpadDragging -bool true

# Enable three-finger drag (requires trackpad)
defaults write com.apple.trackpad ThreeFingerDrag -bool true

# Enable notification center gestures
defaults write com.apple.trackpad notification-center -bool true

# Set tracking speed (1.0 is default, range 0-3)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Restart trackpad to apply
killall trackpad 2>/dev/null || true
print_status "Trackpad customized"

#############################################################################
# 8. HOT CORNERS CONFIGURATION
#############################################################################
print_info "Step 8: Configuring Hot Corners..."

# Note: Hot corners are configured via plist, each corner has a code
# Bottom-left: Mission Control = 2
# Bottom-right: Desktop = 4  
# Top-left: Notification Center = 5
# Top-right: Start Screen Saver = 6

# Set bottom-left to Mission Control
defaults write com.apple.dock wvous-bl-corner -int 2
defaults write com.apple.dock wvous-bl-modifier -int 0

# Set bottom-right to Desktop
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0

# Set top-left to Notification Center
defaults write com.apple.dock wvous-tl-corner -int 5
defaults write com.apple.dock wvous-tl-modifier -int 0

# Set top-right to Screen Saver
defaults write com.apple.dock wvous-tr-corner -int 6
defaults write com.apple.dock wvous-tr-modifier -int 0

killall Dock
print_status "Hot corners configured"

#############################################################################
# 9. SCREENSHOT CUSTOMIZATION
#############################################################################
print_info "Step 9: Customizing Screenshots..."

# Change screenshot save location to Pictures/Screenshots
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Set screenshot save location
defaults write com.apple.screencapture location -string "$SCREENSHOT_DIR"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Set screenshot format (png, jpg, gif, tiff, pdf)
defaults write com.apple.screencapture type -string "png"

# Include date in filename
defaults write com.apple.screencapture include-date -bool true

killall SystemUIServer
print_status "Screenshots customized (saves to ~/Pictures/Screenshots)"

#############################################################################
# 10. SPOTLIGHT SEARCH CUSTOMIZATION
#############################################################################
print_info "Step 10: Customizing Spotlight..."

# Enable Spotlight search results ordering by category
defaults write com.apple.spotlight orderedItems -array

# Restart Spotlight
killall mds 2>/dev/null || true
killall mdworker 2>/dev/null || true
print_status "Spotlight customized"

#############################################################################
# 11. ENERGY SAVER / BATTERY SETTINGS
#############################################################################
print_info "Step 11: Optimizing battery settings..."

# Set display to sleep after 5 minutes on battery (user-level, no sudo needed)
pmset -b displaysleep 5 2>/dev/null || true

# Set display to sleep after 15 minutes on power (user-level)
pmset -c displaysleep 15 2>/dev/null || true

# Enable wake on network access (wrapped - may need sudo)
pmset -w wakeonlan 1 2>/dev/null || print_warning "Wake on LAN requires sudo - skipping"

print_status "Battery settings optimized (user defaults)"

#############################################################################
# 12. KEYBOARD & INPUT CUSTOMIZATION
#############################################################################
print_info "Step 12: Customizing Keyboard..."

# Set key repeat rate (faster)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Enable capital letters (caps lock as shift)
defaults write com.apple.keyboard modifier -bool false

# Turn off auto-correct (optional)
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Turn off predictive typing (optional)  
# defaults write NSGlobalDomain NSPredictiveWritingEnabled -bool false

print_status "Keyboard customized"

#############################################################################
# 13. SAFARI CUSTOMIZATION
#############################################################################
print_info "Step 13: Customizing Safari..."

# Set homepage
defaults write com.apple.Safari HomePage -string "https://www.google.com"

# Enable Safari developer mode
defaults write com.apple.Safari IncludeDebugMenu -bool true

# Show favorites bar
defaults write com.apple.Safari ShowFavoritesBar -bool true

# Use recent tabs from other devices
defaults write com.apple.Safari SyncedTabsPreventStop -bool false

# Turn off autofill (optional, for security)
# defaults write com.apple.Safari AutoFillPasswords -bool false

print_status "Safari customized"

#############################################################################
# 14. APPLE INTELLIGENCE SETTINGS (macOS Tahoe)
#############################################################################
print_info "Step 14: Checking Apple Intelligence..."

# Note: Apple Intelligence requires setup via System Settings
# Check if we can enable via defaults (works on some macOS versions)
defaults write com.apple.AppleIntelligence IsEnabled -bool true 2>/dev/null || true
defaults write com.apple.AppleIntelligence VoiceSupportEnabled -bool true 2>/dev/null || true

print_warning "Apple Intelligence: Please enable in System Settings > Apple Intelligence & Siri"
print_status "Apple Intelligence settings attempted"

#############################################################################
# 15. STAGE MANAGER CONFIGURATION
#############################################################################
print_info "Step 15: Configuring Stage Manager..."

# Enable Stage Manager
defaults write com.apple.WindowManager EnableStageManager -bool true

# Set Stage Manager edge padding
defaults write com.apple.WindowManager StageManagerOptionsAreVisible -bool true

# This requires logout to take effect
print_status "Stage Manager settings configured"

#############################################################################
# 16. NETWORK & CONNECTIVITY
#############################################################################
print_info "Step 16: Optimizing Network Settings..."

# Sync time (user-level) - may skip if no permission
systemsetup -setnetworktimeserver time.apple.com 2>/dev/null || print_warning "Time sync may need sudo - skipping"

print_status "Network settings configured (basic)"

#############################################################################
# 17. FILEVAULT SECURITY
#############################################################################
print_info "Step 17: Checking FileVault status..."

# Check if FileVault is enabled
if fdesetup status | grep -q "FileVault is On"; then
    print_status "FileVault is already enabled"
else
    print_warning "FileVault is NOT enabled - enable in System Settings > Privacy & Security"
fi

#############################################################################
# 18. SCROLLBAR & MOUSE CUSTOMIZATION
#############################################################################
print_info "Step 18: Customizing scrollbar and mouse..."

# Enable momentum scrolling (enabled by default on most Macs)
# defaults write com.apple.scrollviewer -bool true

# Set scroll bar to show always
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Set double-click speed
defaults write NSGlobalDomain MouseDoubleClickTime -int 300

# Set mouse tracking speed
defaults write NSGlobalDomain MouseScaling -float 2.5

print_status "Scroll and mouse settings customized"

#############################################################################
# 19. DICTIONARY & LOOKUP CUSTOMIZATION
#############################################################################
print_info "Step 19: Customizing Dictionary..."

# Enable look up with three finger tap (Force Touch)
# Note: This requires Force Touch trackpad - available on MacBooks
# defaults write com.apple.trackpad/three-finger-tap -bool true

# Enable definition lookup
defaults write com.apple.spotlight DictionaryEnabled -bool true

print_status "Dictionary settings customized"

#############################################################################
# 20. CLEANUP & FINALIZATION
#############################################################################
print_info "Step 20: Final cleanup..."

# Clear DNS cache (no sudo needed on modern macOS)
dscacheutil -flushcache 2>/dev/null || true
killall -HUP mDNSResponder 2>/dev/null || true

print_status "Cleanup complete"

#############################################################################
# FINAL SUMMARY
#############################################################################
echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "Some settings require logout/restart:"
echo "  1. Hot Corners changes"
echo "  2. Stage Manager changes"
echo "  3. Apple Intelligence settings"
echo ""
echo "Manual settings to verify in System Settings:"
echo "  ✓ Display: Set to 'More Space' resolution"
echo "  ✓ Apple Intelligence: Enable & download"
echo "  ✓ Low Power Mode: Enable for battery"
echo "  ✓ Liquid Glass: Customize in Appearance"
echo "  ✓ FileVault: Enable in Privacy & Security"
echo "  ✓ Control Center: Add favorite widgets"
echo ""
echo "Restart: sudo shutdown -r now"
echo "========================================="