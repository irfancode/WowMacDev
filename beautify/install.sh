#!/usr/bin/env bash
#
# beautify/install.sh — WowMacDev unified terminal theming & setup.
#
# Merges:
#   chroma-terminal  → 10 Chroma themes across 10 targets (7 original +
#                      Hyprland borders + Neovim) + theme applier
#   dotfiles         → Ghostty + Zellij + Starship stack + shell config
#
# Usage:
#   ./install.sh                          interactive theme picker + full stack
#   ./install.sh --theme spectrum         apply a specific theme
#   ./install.sh --theme spectrum --stack  # only apply theme
#   ./install.sh --list                   list available themes
#   ./install.sh --dry-run                preview without changes
#
# Flags:
#   --theme NAME   one of aurora canopy clay forge frost nebula solar spectrum tidal void
#   --no-stack     only apply the theme, skip installing tools/configs
#   --only-stack   only install tools/configs, don't touch terminal theme
#   --no-font      skip Nerd Font install
#   --list         list themes and exit
#   --dry-run      print actions without doing them

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"
CONFIG_DIR="$SCRIPT_DIR/config"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
ok()  { printf "${GREEN}✓${NC} %s\n" "$1"; }
info(){ printf "${BLUE}→${NC} %s\n" "$1"; }
warn(){ printf "${YELLOW}▲${NC} %s\n" "$1"; }

THEME=""
DO_STACK=true
DO_THEME=true
DO_FONT=true
DRYDR=false

AVAILABLE=()
for d in "$THEMES_DIR"/*/; do
    [ -d "$d" ] && AVAILABLE+=("$(basename "$d")")
done

usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --theme NAME    Apply a specific theme (default: pick interactively)"
    echo "  --only-stack    Only install tools/configs, skip theme"
    echo "  --no-stack      Only apply the theme"
    echo "  --no-font       Skip the Nerd Font install"
    echo "  --list          List available themes and exit"
    echo "  --dry-run       Preview without making changes"
    echo "  -h, --help      Show help"
    echo ""
    echo "Available themes: ${AVAILABLE[*]}"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --theme) THEME="$2"; shift 2 ;;
        --only-stack) DO_THEME=false; DO_STACK=true; shift ;;
        --no-stack) DO_THEME=true; DO_STACK=false; shift ;;
        --no-font) DO_FONT=false; shift ;;
        --list) printf '%s\n' "${AVAILABLE[@]}"; exit 0 ;;
        --dry-run) DRYDR=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) warn "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# ── Interactive theme picker ──────────────────────────────────────────────
if [ "$DO_THEME" = true ] && [ "$THEME" = "none" ]; then
    if [ "$DRYDR" = true ]; then
        THEME="${AVAILABLE[0]}"
        info "Theme (dry-run): $THEME"
    else
        echo "Pick a theme:"
        PS3="Theme? "
        select t in "${AVAILABLE[@]}"; do
            [ -n "$t" ] && { THEME="$t"; break; }
        done
    fi
fi

if [ "$DO_THEME" = true ]; then
    THEDIR="$THEMES_DIR/$THEME"
    if [ ! -d "$THEDIR" ]; then
        fail "Unknown theme: $THEME"; usage; exit 1
    fi
fi

detect_os() {
    case "$OSTYPE" in
        darwin*) echo macos ;;
        linux*) echo linux ;;
        *) echo unsupported ;;
    esac
}
OS=$(detect_os)

# ── 1. Apply theme to installed terminals ──────────────────────────────────
apply() {
    local src="$1" dest="$2"
    if [ "$DRYDR" = true ]; then
        info "[dry] cp $src → $dest"
        return
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    ok "Applied to $dest"
}

apply_theme() {
    info "Applying theme '${THEME}'..."
    local tdir="$THEMES_DIR/$THEME"

    # Ghostty
    if [ -d "${tdir}/ghostty" ]; then
        if command -v ghostty >/dev/null 2>&1 || [ "$DRYDR" = true ]; then
            apply "$tdir/ghostty/config" "$HOME/.config/ghostty/config"
        fi
    fi
    # Alacritty (+ append if user already has a config)
    local f_toml
    f_toml=$(ls "$tdir"/alacritty/*.toml 2>/dev/null | head -1)
    if [ -n "$f_toml" ]; then
        local adest="$HOME/.config/alacritty/alacritty.toml"
        if [ -f "$adest" ] && [ "$DRYDR" = false ]; then
            # Preserve user file; append our palette
            cp "$adest" "${adest}.bak" 2>/dev/null || true
            cat "$f_toml" >> "$adest"
            ok "Appended theme to Alacritty (backup saved)"
        else
            apply "$f_toml" "$adest"
        fi
    fi
    # Kitty
    f_kitty="$(ls "$tdir"/kitty/*.conf 2>/dev/null | head -1)"
    [ -n "$f_kitty" ] && apply "$f_kitty" "$HOME/.config/kitty/kitty.conf"
    # macOS Terminal.app
    f_term="$(ls "$tdir"/terminal/*.terminal 2>/dev/null | head -1)"
    [ -n "$f_term" ] && apply "$f_term" "$HOME/.config/terminal/Chroma-${THEME}.terminal"
    # Warp
    f_warp="$(ls "$tdir"/warp/*.yaml 2>/dev/null | head -1)"
    [ -n "$f_warp" ] && apply "$f_warp" "$HOME/.warp/themes/chroma-${THEME}.yaml"
    # Hyper / Foot handled if .hyper.js / foot.ini exist
    f_hyper="$(ls "$tdir"/hyper/*.js 2>/dev/null | head -1)"
    [ -n "$f_hyper" ] && apply "$f_hyper" "$HOME/.hyper.js"
    f_foot="$(ls "$tdir"/foot/*.ini 2>/dev/null | head -1)"
    [ -n "$f_foot" ] && apply "$f_foot" "$HOME/.config/foot/foot.ini"
    # Hyprland window borders
    if [ -f "$tdir/hyprland/hyprland.toml" ]; then
        apply "$tdir/hyprland/hyprland.toml" "$HOME/.config/hypr/hyprland.theme.toml"
    fi
    # Neovim: copy the chroma colorscheme into the nvim colors dir
    if [ -f "$tdir/nvim/chroma.lua" ]; then
        apply "$tdir/nvim/chroma.lua" "$HOME/.config/nvim/colors/chroma.lua"
    fi
    ok "Theme '${THEME}' applied"
}

# ── 2. Install the stack (Ghostty, Zellij, Starship, tools) ───────────────
install_pkg() {
    local pkg="$1"
    if [ "$(uname -m)" = "arm64" ] && [ "$OS" = macos ]; then
        if brew list "$pkg" >/dev/null 2>&1; then return; fi
    fi
    if [ "$DRYDR" = true ]; then
        info "dry: brew install $pkg"
        return
    fi
    brew install "$pkg" >/dev/null 2>&1 && ok "Installed $pkg" || warn "Could not install $pkg"
}

install_stack() {
    if [ "$OS" = unsupported ]; then
        fail "Install script supports macOS and Linux only"
        exit 1
    fi
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        if [ "$DRYDR" = false ]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            [ "$(uname -m)" = arm64 ] && eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi

    for p in ghostty zellij starship zoxide eza bat fd fzf ripgrep lazygit; do
        install_pkg "$p"
    done

    # Configs
    if [ "$DRYDR" = false ]; then
        mkdir -p "$HOME/.config/ghostty" "$HOME/.config/zellij/themes" "$HOME/.config/starship" "$HOME/.config/fastfetch"
        ln -sf "$CONFIG_DIR/ghostty/config" "$HOME/.config/ghostty/config"
        ln -sf "$CONFIG_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
        ln -sf "$CONFIG_DIR/zellij/themes/catppuccin-mocha.kdl" "$HOME/.config/zellij/themes/catppuccin-mocha.kdl"
        ln -sf "$CONFIG_DIR/starship.toml" "$HOME/.config/starship.toml"
        ln -sf "$CONFIG_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
        if [[ -f "$HOME/.zshrc" ]] && ! diff -q "$HOME/.zshrc" "$CONFIG_DIR/zshrc" &>/dev/null; then
            cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%s)"
        fi
        ln -sf "$CONFIG_DIR/zshrc" "$HOME/.zshrc"
        ok "Config files linked"
    else
        info "dry: linking configs (ghostty, zellij, starship, zshrc)"
    fi
}

if [ "$DO_THEME" = true ]; then apply_theme; fi
if [ "$DO_STACK" = true ]; then install_stack; fi

if [ "$DO_FONT" = true ] && [ "$OS" = macos ] && [ "$DRYDR" = false ]; then
    if ! command -v fontinstall.sh >/dev/null 2>&1; then
        # fallback: brew install jetbrains nerd font
        brew install font-jetbrains-mono-nerd-font 2>/dev/null && ok "Installed JetBrainsMono Nerd Font" || true
    fi
    if ! fc-list 2>/dev/null | grep -qi "JetBrains.*Nerd"; then
        brew install font-jetbrains-mono-nerd-font 2>/dev/null && ok "Installed JetBrainsMono Nerd Font"
    fi
fi

if [ "$DO_STACK" = true ]; then
    echo ""
    echo -e "${PURPLE}══ Setup Complete ══${NC}"
    echo "  Terminal: Ghostty · Prompt: Starship · Multiplexer: Zellij ($THEME)"
    echo "  Tools: eza, bat, fd, fzf, ripgrep, lazygit, zoxide"
    echo ""
    echo "Next: restart your shell, then:  open -a Ghostty   # then:  zj"
fi