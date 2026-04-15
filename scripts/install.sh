#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# Ghostty + Zellij Terminal Setup
# A powerful, beautiful terminal configuration
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unsupported"
    fi
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}${CYAN}🚀 Terminal Setup: Ghostty + Zellij + Starship${NC}                   ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${PURPLE}A powerful, beautiful terminal configuration${NC}                   ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

OS=$(detect_os)

if [[ "$OS" == "unsupported" ]]; then
    echo -e "${RED}❌ Unsupported operating system${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Detected: $OS${NC}"
echo ""

# ── Check for Homebrew ──────────────────────────────────────────────────────
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add to shell config for Apple Silicon
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

echo -e "${GREEN}✅ Homebrew ready${NC}"
echo ""

# ── Install packages ────────────────────────────────────────────────────────
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📦 Installing packages...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

install_package() {
    local pkg="$1"
    local desc="${2:-$pkg}"
    if brew list --formula "$pkg" &>/dev/null || brew list --cask "$pkg" &>/dev/null 2>&1; then
        echo -e "  ${YELLOW}⏭️  $pkg${NC} (already installed)"
    else
        echo -e "  ${GREEN}📦 $pkg${NC}"
        brew install --formula "$pkg" 2>/dev/null || brew install --cask "$pkg" 2>/dev/null || true
    fi
}

# Terminal Emulator
echo -e "\n${BOLD}🎨 Terminal:${NC}"
install_package "ghostty" "Ghostty GPU-accelerated terminal"

# Terminal Multiplexer
echo -e "\n${BOLD}🟣 Multiplexer:${NC}"
install_package "zellij" "Zellij (tmux alternative)"

# Prompt & Shell Enhancements
echo -e "\n${BOLD}⭐ Prompt & Shell:${NC}"
install_package "starship" "Starship cross-shell prompt"
install_package "zoxide" "Smarter cd command"

# File Utilities
echo -e "\n${BOLD}📁 File Utilities:${NC}"
install_package "eza" "Modern ls replacement"
install_package "bat" "Modern cat replacement"
install_package "fd" "Modern find replacement"
install_package "fzf" "Fuzzy finder"

# Development Tools
echo -e "\n${BOLD}🔧 Development Tools:${NC}"
install_package "ripgrep" "Modern grep replacement"
install_package "lazygit" "Git TUI"

echo ""
echo -e "${GREEN}✅ All packages installed!${NC}"

# ── Create config directories ───────────────────────────────────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📁 Creating config directories...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

mkdir -p ~/.config/ghostty
mkdir -p ~/.config/zellij/themes
mkdir -p ~/.config/starship

echo -e "  ${GREEN}✅ ~/.config/ghostty${NC}"
echo -e "  ${GREEN}✅ ~/.config/zellij/themes${NC}"
echo -e "  ${GREEN}✅ ~/.config/starship${NC}"

# ── Link config files ──────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔗 Linking config files...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Ghostty
if [[ -f "$DOTFILES_DIR/config/ghostty/config" ]]; then
    ln -sf "$DOTFILES_DIR/config/ghostty/config" ~/.config/ghostty/config
    echo -e "  ${GREEN}✅ Ghostty config${NC}"
fi

# Zellij
if [[ -f "$DOTFILES_DIR/config/zellij/config.kdl" ]]; then
    ln -sf "$DOTFILES_DIR/config/zellij/config.kdl" ~/.config/zellij/config.kdl
    echo -e "  ${GREEN}✅ Zellij config${NC}"
fi

if [[ -f "$DOTFILES_DIR/config/zellij/themes/catppuccin-mocha.kdl" ]]; then
    ln -sf "$DOTFILES_DIR/config/zellij/themes/catppuccin-mocha.kdl" ~/.config/zellij/themes/catppuccin-mocha.kdl
    echo -e "  ${GREEN}✅ Zellij Catppuccin theme${NC}"
fi

# Starship
if [[ -f "$DOTFILES_DIR/config/starship.toml" ]]; then
    ln -sf "$DOTFILES_DIR/config/starship.toml" ~/.config/starship.toml
    echo -e "  ${GREEN}✅ Starship config${NC}"
fi

# Zsh
if [[ -f "$DOTFILES_DIR/zshrc" ]]; then
    # Backup existing .zshrc if different
    if [[ -f ~/.zshrc ]] && ! diff -q ~/.zshrc "$DOTFILES_DIR/zshrc" &>/dev/null; then
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d%H%M%S)
        echo -e "  ${YELLOW}⚠️  Backed up existing .zshrc${NC}"
    fi
    ln -sf "$DOTFILES_DIR/zshrc" ~/.zshrc
    echo -e "  ${GREEN}✅ Zsh config${NC}"
fi

echo ""
echo -e "${GREEN}✅ All config files linked!${NC}"

# ── Initialize fzf ────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔧 Initializing fzf...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if command -v fzf &> /dev/null; then
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc 2>/dev/null || true
    echo -e "  ${GREEN}✅ fzf initialized${NC}"
fi

# ── Summary ────────────────────────────────────────────────────────────────
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}${GREEN}✅ Setup Complete!${NC}                                              ${PURPLE}║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC}                                                                  ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}🎨 Terminal:${NC}     Ghostty + Catppuccin Mocha                  ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}🟣 Multiplexer:${NC}  Zellij (Alt-based keybindings)              ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}⭐ Prompt:${NC}       Starship + Zsh                             ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}  ${BOLD}📦 Tools:${NC}       eza, bat, fd, fzf, ripgrep, lazygit, zoxide ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC}                                                                  ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Next steps ──────────────────────────────────────────────────────────────
echo -e "${BOLD}📋 Next Steps:${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} Restart your terminal or run: ${BOLD}exec zsh${NC}"
echo -e "  ${CYAN}2.${NC} Open Ghostty: ${BOLD}open -a Ghostty${NC}"
echo -e "  ${CYAN}3.${NC} Start Zellij: ${BOLD}zj${NC}"
echo ""

# ── Keyboard shortcuts ──────────────────────────────────────────────────────
echo -e "${BOLD}⌨️  Quick Reference:${NC}"
echo ""
echo -e "  ${BOLD}Ghostty:${NC}"
echo -e "    ${CYAN}⌘ + T${NC}    → New tab"
echo -e "    ${CYAN}⌘ + D${NC}    → Vertical split"
echo -e "    ${CYAN}⌘ + ⇧ + D${NC} → Horizontal split"
echo -e "    ${CYAN}⌘ + F${NC}    → Search scrollback"
echo ""
echo -e "  ${BOLD}Zellij:${NC}"
echo -e "    ${CYAN}⌥ + N${NC}    → New pane"
echo -e "    ${CYAN}⌥ + HJKL${NC} → Navigate panes"
echo -e "    ${CYAN}⌥ + T${NC}    → New tab"
echo -e "    ${CYAN}⌥ + Q${NC}    → Detach"
echo ""
echo -e "  ${BOLD}Aliases:${NC}"
echo -e "    ${CYAN}zj${NC}         → Zellij"
echo -e "    ${CYAN}lg${NC}         → Lazygit"
echo -e "    ${CYAN}z <dir>${NC}     → Jump to directory"
echo -e "    ${CYAN}Ctrl + R${NC}    → Search history"
echo ""

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}Happy coding! 🚀${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
