#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                           QUICK START GUIDE                                  ║
# ║                    Mac App Sync - Get Started in 5 Minutes                  ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

cat << 'BANNER'

    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║     ██╗  ██╗███████╗██████╗ ███╗   ███╗██╗ ██████╗ ██╗   ██╗ ║
    ║     ██║ ██╔╝██╔════╝██╔══██╗████╗ ████║██║██╔═══██╗╚██╗ ██╔╝ ║
    ║     █████╔╝ █████╗  ██████╔╝██╔████╔██║██║██║   ██║ ╚████╔╝  ║
    ║     ██╔═██╗ ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║   ██║  ╚██╔╝   ║
    ║     ██║  ██╗███████╗██║  ██║██║ ╚═╝ ██║██║╚██████╔╝   ██║    ║
    ║     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝ ╚═════╝    ╚═╝    ║
    ║                                                               ║
    ║              ⚡ Backup & Restore Your Mac Apps ⚡             ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝

BANNER

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "                         🚀 GETTING STARTED"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

# Check if we're in the right directory
if [ ! -f "./mac-app-sync.sh" ]; then
    echo "❌ Error: Run this script from the mac-app-sync directory"
    echo ""
    echo "   cd ~/mac-app-sync"
    echo "   ./QUICKSTART.sh"
    echo ""
    exit 1
fi

echo "Let's set up your Mac app backup in 3 simple steps!"
echo ""

echo "───────────────────────────────────────────────────────────────────────────────"
echo " STEP 1️⃣  |  EXPORT YOUR CURRENT APPS"
echo "───────────────────────────────────────────────────────────────────────────────"
echo ""
echo " This will scan your Mac and create a list of all installed apps."
echo ""
read -p " Press ENTER to start export..." -r
echo ""

./mac-app-sync.sh export

echo ""
echo "───────────────────────────────────────────────────────────────────────────────"
echo " STEP 2️⃣  |  REVIEW YOUR EXPORT"
echo "───────────────────────────────────────────────────────────────────────────────"
echo ""
echo " Check what was exported:"
echo ""
./mac-app-sync.sh list
echo ""
echo " You can edit these files to add/remove apps:"
echo "   nano exports/homebrew_casks.txt"
echo "   nano exports/homebrew_formulas.txt"
echo ""
read -p " Press ENTER to continue to sync setup..." -r

echo ""
echo "───────────────────────────────────────────────────────────────────────────────"
echo " STEP 3️⃣  |  SYNC TO GITHUB (Optional but Recommended)"
echo "───────────────────────────────────────────────────────────────────────────────"
echo ""

if command -v gh &> /dev/null && gh auth status &>/dev/null; then
    echo " ✅ GitHub CLI is configured!"
    echo ""
    read -p " Push to GitHub now? [Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        ./mac-app-sync.sh sync
    fi
else
    echo " ⚠️  GitHub CLI not configured yet."
    echo ""
    echo "   To enable sync to GitHub:"
    echo "   1. Install: brew install gh"
    echo "   2. Login:  gh auth login"
    echo "   3. Run:    ./mac-app-sync.sh sync"
    echo ""
    echo "   You can still use this tool by manually copying the folder."
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "                         ✅ SETUP COMPLETE!"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

echo "Your app list has been exported to:"
echo "  📁 exports/"
echo ""
echo "On your NEW MAC, run these commands:"
echo ""
echo "  1. git clone https://github.com/YOUR_USERNAME/mac-app-sync.git"
echo "  2. cd mac-app-sync"
echo "  3. ./mac-app-sync.sh install"
echo ""

# Check git remote
GIT_ORIGIN=$(git remote get-url origin 2>/dev/null || echo "")
if [ -n "$GIT_ORIGIN" ]; then
    echo "Your repo: $(echo $GIT_ORIGIN | sed 's|git@github.com:|https://github.com/|' | sed 's|\.git||')"
fi

echo ""
