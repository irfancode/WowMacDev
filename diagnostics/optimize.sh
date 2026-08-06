#!/bin/bash
# diagnostics/optimize.sh - opinionated macOS customization (20 steps).
#
# Merged from: macos-setup-tools/macbook_setup.sh
# Fixes over upstream:
#   - no bare `set -e` (was aborting mid-run on unguarded killall/defaults)
#   - every killall guarded with `|| true`
#   - every `defaults write` wrapped in a helper that tolerates OS variance
#   - added --dry-run and --yes flags; --yes skips confirmations
#   - removed speculative Apple Intelligence auto-enable (manual only)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

require_macos

DRY_RUN=false
ASSUME_YES=false

usage() {
    echo "Usage: $(basename "$0") [--dry-run] [--yes]"
    echo ""
    echo "  --dry-run   Print every change without applying it"
    echo "  --yes       Skip confirmation prompt"
    echo ""
    echo "WARNING: This modifies macOS settings. Review before running."
}

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --yes) ASSUME_YES=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

if [ "$DRY_RUN" = false ] && [ "$ASSUME_YES" = false ]; then
    echo "This script changes macOS settings (Dock, Finder, Trackpad, screenshots, and more)."
    read -r -p "Continue? [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

print_status() { echo -e "${C_GREEN}[✓]${C_RESET} $1"; }
print_warning() { echo -e "${C_YELLOW}[!]${C_RESET} $1"; }
print_info() { echo -e "${C_BLUE}[i]${C_RESET} $1"; }

# Apply a `defaults write` rule, honoring dry-run and tolerating failures.
# Usage: apply_defaults write <domain> <key> <type> <value>...
apply_defaults() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${C_PURPLE}[dry-run]${C_RESET} defaults $*"
        return 0
    fi
    if ! defaults "$@" 2>/dev/null; then
        print_warning "defaults $* failed (may be unsupported on this macOS) - skipped"
    fi
}

restart() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${C_PURPLE}[dry-run]${C_RESET} killall $*"
        return 0
    fi
    killall "$@" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# 1. CHECK FOR SOFTWARE UPDATES
# ---------------------------------------------------------------------------
print_info "Step 1: Checking for macOS updates..."
if [ "$DRY_RUN" = false ]; then
    softwareupdate --install --all 2>/dev/null || print_warning "No updates available or requires GUI"
fi
print_status "Software update check complete"

# ---------------------------------------------------------------------------
# 2. SHOW BATTERY PERCENTAGE IN MENU BAR
# ---------------------------------------------------------------------------
print_info "Step 2: Enabling battery percentage in menu bar..."
apply_defaults -currentHost write com.apple.controlcenter.plist BatteryShowPercentage -bool true
restart SystemUIServer
print_status "Battery percentage enabled"

# ---------------------------------------------------------------------------
# 3. DOCK CUSTOMIZATION
# ---------------------------------------------------------------------------
print_info "Step 3: Customizing Dock..."
apply_defaults write com.apple.dock autohide -bool true
apply_defaults write com.apple.dock autohide-delay -float 0
apply_defaults write com.apple.dock autohide-time-modifier -float 0.4
apply_defaults write com.apple.dock tilesize -int 48
apply_defaults write com.apple.dock magnification -bool true
apply_defaults write com.apple.dock largesize -int 64
apply_defaults write com.apple.dock orientation -string bottom
apply_defaults write com.apple.dock enabling-spring-load-on-all-items -bool true
apply_defaults write com.apple.dock show-recents -bool false
apply_defaults write com.apple.dock launchanimate -bool true
apply_defaults write com.apple.dock show-indicators -bool true
restart Dock
print_status "Dock customized"

# ---------------------------------------------------------------------------
# 4. FINDER CUSTOMIZATION
# ---------------------------------------------------------------------------
print_info "Step 4: Customizing Finder..."
apply_defaults write com.apple.finder AppleShowAllFiles -bool true
apply_defaults write com.apple.finder EmptyTrashSecureWarning -bool true
apply_defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
apply_defaults write com.apple.finder AppleShowDesktop -bool true
apply_defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
apply_defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
apply_defaults write NSGlobalDomain NSPrintPanelExpandedState -bool true
apply_defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
apply_defaults write com.apple.finder ShowPathbar -bool true
apply_defaults write com.apple.finder ShowStatusBar -bool true
restart Finder
print_status "Finder customized"

# ---------------------------------------------------------------------------
# 5. MENU BAR & CONTROL CENTER
# ---------------------------------------------------------------------------
print_info "Step 5: Customizing menu bar..."
apply_defaults write com.apple.controlcenter.plist WiFiShowInMenuBar -bool true
apply_defaults write com.apple.controlcenter.plist BluetoothShowInMenuBar -bool true
apply_defaults write com.apple.controlcenter.plist BatteryShowInMenuBar -bool true
restart ControlCenter
print_status "Menu bar customized"

# ---------------------------------------------------------------------------
# 6. DISPLAY - "MORE SPACE" (manual)
# ---------------------------------------------------------------------------
print_info "Step 6: Display settings..."
print_warning "Display resolution: Set to 'More Space' manually in System Settings > Display"
print_status "Display settings noted"

# ---------------------------------------------------------------------------
# 7. TRACKPAD & MOUSE
# ---------------------------------------------------------------------------
print_info "Step 7: Customizing Trackpad..."
apply_defaults write com.apple.trackpad TapToClick -bool true
apply_defaults write com.apple.trackpad TrackpadDragging -bool true
apply_defaults write com.apple.trackpad ThreeFingerDrag -bool true
apply_defaults write com.apple.trackpad notification-center -bool true
apply_defaults write NSGlobalDomain KeyRepeat -int 2
apply_defaults write NSGlobalDomain InitialKeyRepeat -int 15
restart trackpad
print_status "Trackpad customized"

# ---------------------------------------------------------------------------
# 8. HOT CORNERS
# ---------------------------------------------------------------------------
print_info "Step 8: Configuring Hot Corners..."
# BL=Mission Control(2), BR=Desktop(4), TL=Notification Center(5), TR=Screen Saver(6)
apply_defaults write com.apple.dock wvous-bl-corner -int 2
apply_defaults write com.apple.dock wvous-bl-modifier -int 0
apply_defaults write com.apple.dock wvous-br-corner -int 4
apply_defaults write com.apple.dock wvous-br-modifier -int 0
apply_defaults write com.apple.dock wvous-tl-corner -int 5
apply_defaults write com.apple.dock wvous-tl-modifier -int 0
apply_defaults write com.apple.dock wvous-tr-corner -int 6
apply_defaults write com.apple.dock wvous-tr-modifier -int 0
restart Dock
print_status "Hot corners configured"

# ---------------------------------------------------------------------------
# 9. SCREENSHOT CUSTOMIZATION
# ---------------------------------------------------------------------------
print_info "Step 9: Customizing Screenshots..."
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
if [ "$DRY_RUN" = true ]; then
    echo -e "${C_PURPLE}[dry-run]${C_RESET} mkdir -p $SCREENSHOT_DIR"
else
    mkdir -p "$SCREENSHOT_DIR"
fi
apply_defaults write com.apple.screencapture location -string "$SCREENSHOT_DIR"
apply_defaults write com.apple.screencapture disable-shadow -bool true
apply_defaults write com.apple.screencapture type -string "png"
apply_defaults write com.apple.screencapture include-date -bool true
restart SystemUIServer
print_status "Screenshots customized (saves to ~/Pictures/Screenshots)"

# ---------------------------------------------------------------------------
# 10. SPOTLIGHT SEARCH
# ---------------------------------------------------------------------------
print_info "Step 10: Customizing Spotlight..."
apply_defaults write com.apple.spotlight orderedItems -array
restart mds
restart mdworker
print_status "Spotlight customized"

# ---------------------------------------------------------------------------
# 11. ENERGY SAVER / BATTERY
# ---------------------------------------------------------------------------
print_info "Step 11: Optimizing battery settings..."
if [ "$DRY_RUN" = true ]; then
    echo -e "${C_PURPLE}[dry-run]${C_RESET} pmset -b displaysleep 5; pmset -c displaysleep 15"
else
    pmset -b displaysleep 5 2>/dev/null || true
    pmset -c displaysleep 15 2>/dev/null || true
    pmset -w wakeonlan 1 2>/dev/null || print_warning "Wake on LAN requires sudo - skipping"
fi
print_status "Battery settings optimized"

# ---------------------------------------------------------------------------
# 12. KEYBOARD & INPUT
# ---------------------------------------------------------------------------
print_info "Step 12: Customizing Keyboard..."
apply_defaults write NSGlobalDomain KeyRepeat -int 2
apply_defaults write NSGlobalDomain InitialKeyRepeat -int 15
apply_defaults write com.apple.keyboard modifier -bool false
print_status "Keyboard customized"

# ---------------------------------------------------------------------------
# 13. SAFARI
# ---------------------------------------------------------------------------
print_info "Step 13: Customizing Safari..."
apply_defaults write com.apple.Safari HomePage -string "https://www.google.com"
apply_defaults write com.apple.Safari IncludeDebugMenu -bool true
apply_defaults write com.apple.Safari ShowFavoritesBar -bool true
apply_defaults write com.apple.Safari SyncedTabsPreventStop -bool false
print_status "Safari customized"

# ---------------------------------------------------------------------------
# 14. APPLE INTELLIGENCE (manual only)
# ---------------------------------------------------------------------------
print_info "Step 14: Apple Intelligence..."
print_warning "Enable manually: System Settings > Apple Intelligence & Siri"
print_status "Apple Intelligence noted"

# ---------------------------------------------------------------------------
# 15. STAGE MANAGER
# ---------------------------------------------------------------------------
print_info "Step 15: Configuring Stage Manager..."
apply_defaults write com.apple.WindowManager EnableStageManager -bool true
apply_defaults write com.apple.WindowManager StageManagerOptionsAreVisible -bool true
print_status "Stage Manager settings configured (logout may be required)"

# ---------------------------------------------------------------------------
# 16. NETWORK & CONNECTIVITY
# ---------------------------------------------------------------------------
print_info "Step 16: Optimizing Network Settings..."
if [ "$DRY_RUN" = true ]; then
    echo -e "${C_PURPLE}[dry-run]${C_RESET} systemsetup -setnetworktimeserver time.apple.com"
else
    systemsetup -setnetworktimeserver time.apple.com 2>/dev/null || print_warning "Time sync may need sudo - skipping"
fi
print_status "Network settings configured"

# ---------------------------------------------------------------------------
# 17. FILEVAULT SECURITY
# ---------------------------------------------------------------------------
print_info "Step 17: Checking FileVault status..."
if [ "$DRY_RUN" = false ] && fdesetup status 2>/dev/null | grep -q "FileVault is On"; then
    print_status "FileVault is already enabled"
else
    print_warning "FileVault is NOT enabled - enable in System Settings > Privacy & Security"
fi

# ---------------------------------------------------------------------------
# 18. SCROLLBAR & MOUSE
# ---------------------------------------------------------------------------
print_info "Step 18: Customizing scrollbar and mouse..."
apply_defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
apply_defaults write NSGlobalDomain MouseDoubleClickTime -int 300
apply_defaults write NSGlobalDomain MouseScaling -float 2.5
print_status "Scroll and mouse settings customized"

# ---------------------------------------------------------------------------
# 19. DICTIONARY & LOOKUP
# ---------------------------------------------------------------------------
print_info "Step 19: Customizing Dictionary..."
apply_defaults write com.apple.spotlight DictionaryEnabled -bool true
print_status "Dictionary settings customized"

# ---------------------------------------------------------------------------
# 20. CLEANUP & FINALIZATION
# ---------------------------------------------------------------------------
print_info "Step 20: Final cleanup..."
if [ "$DRY_RUN" = false ]; then
    dscacheutil -flushcache 2>/dev/null || true
    killall -HUP mDNSResponder 2>/dev/null || true
fi
print_status "Cleanup complete"

# ---------------------------------------------------------------------------
# FINAL SUMMARY
# ---------------------------------------------------------------------------
echo ""
echo "========================================="
echo "  Optimization Complete!"
echo "========================================="
echo ""
if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN - no changes were applied."
else
    echo "Some settings require logout/restart:"
    echo "  1. Hot Corners changes"
    echo "  2. Stage Manager changes"
    echo ""
    echo "Manual settings to verify in System Settings:"
    echo "  ✓ Display: Set to 'More Space' resolution"
    echo "  ✓ Apple Intelligence: Enable & download"
    echo "  ✓ Low Power Mode: Enable for battery"
    echo "  ✓ FileVault: Enable in Privacy & Security"
    echo ""
    echo "Restart: sudo shutdown -r now"
fi
echo "========================================="
