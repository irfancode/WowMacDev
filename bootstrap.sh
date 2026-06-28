#!/usr/bin/env bash
#
# mac-bootstrap — One-shot Mac setup from a clean install
#
# Usage: curl -fsSL https://raw.githubusercontent.com/<user>/mac-bootstrap/main/bootstrap.sh | bash
#    Or: ./bootstrap.sh
#
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
ok()  { printf "${GREEN}✓${NC} %s\n" "$1"; }
info(){ printf "${BLUE}→${NC} %s\n" "$1"; }
warn(){ printf "${YELLOW}▲${NC} %s\n" "$1"; }
fail(){ printf "${RED}✗${NC} %s\n" "$1"; }
header(){ printf "\n${BOLD}══ %s ══${NC}\n" "$1"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"

# ── Phase 0: Prerequisites ────────────────────────────────────
header "Phase 0: Prerequisites"
info "Checking prerequisites..."

# Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "    Press Enter after installation completes..."
  read -r
else
  ok "Xcode CLT present"
fi

# Rosetta 2 (for any x86_64 binaries)
if ! /usr/bin/pgrep -q oahd 2>/dev/null; then
  info "Installing Rosetta 2..."
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license 2>/dev/null || true
fi

# ── Phase 1: Homebrew & packages ──────────────────────────────
header "Phase 1: Homebrew & System Packages"
bash "$REPO_DIR/install/brew.sh"

# Ensure brew is in PATH
eval "$(/opt/homebrew/bin/brew shellenv)"

# ── Phase 2: macOS Preferences ────────────────────────────────
header "Phase 2: macOS Preferences"
bash "$REPO_DIR/install/macos.sh"

# ── Phase 3: Dev Tools (Node, Go, Neovim, fzf, rg, bat, etc.) ─
header "Phase 3: Developer Tools"
bash "$REPO_DIR/install/dev-tools.sh"

# ── Phase 4: Shell & Configs ──────────────────────────────────
header "Phase 4: Shell Configuration"

# Zsh config
info "Installing .zshrc and .zprofile..."
cp "$REPO_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
cp "$REPO_DIR/config/zsh/.zprofile" "$HOME/.zprofile"

# Starship prompt
info "Installing Starship config..."
mkdir -p "$HOME/.config"
cp "$REPO_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"

# Ghostty terminal
info "Installing Ghostty config..."
mkdir -p "$HOME/.config/ghostty"
cp "$REPO_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"

# btop
info "Installing btop config..."
mkdir -p "$HOME/.config/btop"
cp "$REPO_DIR/config/btop/btop.conf" "$HOME/.config/btop/btop.conf"

# Neovim
info "Installing Neovim config..."
if [ -d "$HOME/.config/nvim" ]; then
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%s)"
fi
cp -R "$REPO_DIR/config/nvim" "$HOME/.config/nvim"

# Zsh plugins (autosuggestions + syntax highlighting)
ZSH_PLUGIN_DIR="$HOME/.local/share/zsh/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"
if [ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]; then
  info "Installing zsh-autosuggestions..."
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ]; then
  info "Installing zsh-syntax-highlighting..."
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
fi

# FZF key bindings & completion
if command -v fzf &>/dev/null && [ ! -f "$HOME/.fzf/shell/key-bindings.zsh" ]; then
  info "Installing fzf integration..."
  "$(which fzf)"/install --key-bindings --completion --no-update-rc 2>/dev/null || true
fi

# ── Phase 5: Post-setup ───────────────────────────────────────
header "Phase 5: Final Touches"

info "Creating local state directories..."
mkdir -p "$HOME/.local/state" "$HOME/.local/bin" "$HOME/go"

# Install update-tools script
cp "$REPO_DIR/scripts/update-tools.sh" "$HOME/.local/bin/update-tools"
chmod +x "$HOME/.local/bin/update-tools"

# Cargo binaries
if command -v cargo &>/dev/null; then
  info "Installing cargo tools..."
  cargo install du-dust 2>/dev/null || true
fi

# Source new shell config
info "Sourcing new shell config..."
source "$HOME/.zshrc" 2>/dev/null || true

echo ""
header "Bootstrap Complete!"
echo ""
echo "  ${GREEN}Your Mac is now set up with:${NC}"
echo "    - Homebrew packages & casks"
echo "    - macOS preferences (dark mode, dock, keyboard, etc.)"
echo "    - Developer tools (Node, Go, Neovim, Rust, fzf, rg, bat, lsd, lazygit)"
echo "    - Shell config (.zshrc, starship, zsh plugins)"
echo "    - Ghostty terminal config (Catppuccin Mocha theme)"
echo "    - Neovim config (LazyVim based)"
echo ""
echo "  ${YELLOW}Next steps:${NC}"
echo "    1. Restart your terminal (or exec zsh)"
echo "    2. Open Ghostty for the full terminal experience"
echo "    3. Run 'update-tools --update' to ensure everything is current"
echo "    4. Review ~/Desktop for your restored files"
echo ""
