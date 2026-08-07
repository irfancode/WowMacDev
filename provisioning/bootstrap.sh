#!/usr/bin/env bash
#
# mac-bootstrap — One-shot Mac setup from a clean install (WowMacDev provisioning)
#
# For beginners:
#   1. Open Terminal (Command+Space, type "Terminal", Enter)
#   2. Copy and paste this line, then press Enter:
#
#        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/irfancode/WowMacDev/main/provisioning/bootstrap.sh)"
#
#   3. Wait 30-60 minutes. That's it.
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

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║     mac-bootstrap — macOS Setup Wizard       ║"
echo "  ║     Setting up your Mac... relax and wait    ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""
echo "  This will take 30–60 minutes (mostly downloads)."
echo "  You'll see a lot of text scrolling — that's normal."
echo "  If a popup asks for password, type your Mac login."
echo ""

# ── Phase 0: Prerequisites ────────────────────────────────────
header "Phase 0: Prerequisites"
info "Checking prerequisites..."

# Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  info "  If a popup appears, click 'Install' and wait for it to finish."
  xcode-select --install
  echo ""
  echo "  ⏳ After the installation popup completes,"
  echo "     go back to Terminal and press ENTER to continue..."
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

# Backup-then-install helper (idempotent, preserves existing dotfiles).
install_dotfile() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.backup.$(date +%s)" 2>/dev/null
    info "Backed up existing $dest"
  fi
  cp "$src" "$dest"
}

# ── Zsh shell profiles ─────────────────────────────────────
info "Installing .zshrc / .zprofile / .profile..."
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/zsh/plugins"
install_dotfile "$REPO_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
install_dotfile "$REPO_DIR/config/zsh/.zprofile" "$HOME/.zprofile"
install_dotfile "$REPO_DIR/config/zsh/.profile" "$HOME/.profile"

# ── Git global config ─────────────────────────────────────
info "Installing .gitconfig..."
install_dotfile "$REPO_DIR/config/git/.gitconfig" "$HOME/.gitconfig"

# ── Starship prompt ───────────────────────────────────────
info "Installing Starship config..."
mkdir -p "$HOME/.config"
cp "$REPO_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml"

# ── Ghostty terminal ──────────────────────────────────────
info "Installing Ghostty config..."
mkdir -p "$HOME/.config/ghostty"
cp "$REPO_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"

# ── fastfetch system info ─────────────────────────────────
info "Installing fastfetch config..."
mkdir -p "$HOME/.config/fastfetch"
cp "$REPO_DIR/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"

# ── Zellij multiplexer ────────────────────────────────────
info "Installing Zellij config..."
mkdir -p "$HOME/.config/zellij"
cp "$REPO_DIR/config/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"

# ── btop ──────────────────────────────────────────────────
info "Installing btop config..."
mkdir -p "$HOME/.config/btop"
cp "$REPO_DIR/config/btop/btop.conf" "$HOME/.config/btop/btop.conf"

# ── Neovim ────────────────────────────────────────────────
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

# FZF key bindings & completion (handled by `fzf --zsh` in .zshrc;
# just ensure the binary is present). No ~/.fzf legacy install needed.
if command -v fzf &>/dev/null && fzf --zsh >/dev/null 2>&1; then
  info "fzf shell integration available"
else
  warn "fzf not present or legacy; ensure it's installed via Brewfile"
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
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║         ✅  ALL DONE!  Your Mac is set up.   ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""
echo "  ${GREEN}What was installed:${NC}"
echo "    74 command-line tools (via Homebrew)"
echo "    32 applications (VS Code, Docker, browsers, etc.)"
echo "    3 programming fonts (JetBrains Mono, Fira Code, etc.)"
echo "    macOS settings (dark mode, fast keyboard, Finder tweaks)"
echo "    Shell config with colored prompt and smart search"
echo "    Ghostty terminal with Monokai Pro theme"
echo "    Neovim editor with LazyVim"
echo ""
echo "  ${YELLOW}▶  NEXT STEPS (for beginners):${NC}"
echo ""
echo "    ${BOLD}1. Close this Terminal window and open a new one${NC}"
echo "       (Press Command+Space, type 'Terminal', Enter)"
echo "       You'll now see a colored prompt — that's normal!"
echo ""
echo "    ${BOLD}2. Find 'Ghostty' in your Applications folder${NC}"
echo "       (or press Command+Space, type 'Ghostty', Enter)"
echo "       This is your new terminal — it looks much better."
echo ""
echo "    ${BOLD}3. Connect to GitHub (optional):${NC}"
echo "       In Terminal, type:  gh auth login"
echo "       Then follow the on-screen instructions."
echo ""
echo "    ${BOLD}4. Want Java? Run:${NC}"
echo "       source ~/.sdkman/bin/sdkman-init.sh"
echo "       sdk install java 21.0.11-amzn"
echo ""
echo "  ${YELLOW}▶  Need help?${NC}"
echo "    Open https://github.com/irfancode/mac-bootstrap"
echo "    Or run: cat ~/.zshrc"
echo ""
