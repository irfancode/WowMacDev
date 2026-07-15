#!/usr/bin/env bash
#
# bootstrap.sh — Chroma Terminal Theme Installer (Linux & macOS)
#
# Usage: bash bootstrap.sh [theme-name] [options]
#   Options:
#     --font       Install JetBrainsMono Nerd Font
#     --prompt     Install Starship prompt with Chroma theme config
#     --tools      Install common CLI tools (eza, bat, fd, ripgrep, zoxide, fzf)
#     --all        Install everything (font, prompt, tools)
#     --help       Show this help message
#
#   Available themes: spectrum, octagon, ristretto, machine, classic, zen,
#                     protorium, relaxed, amber
#
#   Examples:
#     bash bootstrap.sh                    # Interactive mode
#     bash bootstrap.sh octagon            # Apply Octagon theme
#     bash bootstrap.sh spectrum --font    # Apply Spectrum + install font
#     bash bootstrap.sh --all              # Interactive theme + everything
#     bash bootstrap.sh spectrum --all     # Full setup with Chroma Spectrum
#

set -euo pipefail

# ──────────────────────────────────────────────
# Color definitions for script output
# ──────────────────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# ──────────────────────────────────────────────
# Theme definitions (10 Chroma variants)
# ──────────────────────────────────────────────
declare -A THEME_BG THEME_FG THEME_BLACK THEME_RED THEME_GREEN THEME_YELLOW
declare -A THEME_BLUE THEME_MAGENTA THEME_CYAN THEME_WHITE THEME_BRBG THEME_COMMENT

init_theme_colors() {
  # Chroma Spectrum
  THEME_BG[spectrum]="#2D2A2E"
  THEME_FG[spectrum]="#FCFCFA"
  THEME_BLACK[spectrum]="#2D2A2E"
  THEME_RED[spectrum]="#FF6188"
  THEME_GREEN[spectrum]="#A9DC76"
  THEME_YELLOW[spectrum]="#FFD866"
  THEME_BLUE[spectrum]="#78DCE8"
  THEME_MAGENTA[spectrum]="#AB9DF2"
  THEME_CYAN[spectrum]="#78DCE8"
  THEME_WHITE[spectrum]="#FCFCFA"
  THEME_BRBG[spectrum]="#1A1A1C"
  THEME_COMMENT[spectrum]="#69676C"

  # Filter Octagon
  THEME_BG[octagon]="#2D2A2E"
  THEME_FG[octagon]="#FCFCFA"
  THEME_BLACK[octagon]="#2D2A2E"
  THEME_RED[octagon]="#FF6188"
  THEME_GREEN[octagon]="#A9DC76"
  THEME_YELLOW[octagon]="#FFD866"
  THEME_BLUE[octagon]="#78DCE8"
  THEME_MAGENTA[octagon]="#FC9867"
  THEME_CYAN[octagon]="#78DCE8"
  THEME_WHITE[octagon]="#FCFCFA"
  THEME_BRBG[octagon]="#1A1A1C"
  THEME_COMMENT[octagon]="#69676C"

  # Filter Ristretto
  THEME_BG[ristretto]="#2B2A2B"
  THEME_FG[ristretto]="#FCFCFA"
  THEME_BLACK[ristretto]="#2B2A2B"
  THEME_RED[ristretto]="#E36A6A"
  THEME_GREEN[ristretto]="#98C379"
  THEME_YELLOW[ristretto]="#E5C07B"
  THEME_BLUE[ristretto]="#7CB7D9"
  THEME_MAGENTA[ristretto]="#C678DD"
  THEME_CYAN[ristretto]="#56B6C2"
  THEME_WHITE[ristretto]="#FCFCFA"
  THEME_BRBG[ristretto]="#1A1A1C"
  THEME_COMMENT[ristretto]="#5C5C5C"

  # Filter Machine
  THEME_BG[machine]="#2D2A2E"
  THEME_FG[machine]="#FCFCFA"
  THEME_BLACK[machine]="#2D2A2E"
  THEME_RED[machine]="#FF6188"
  THEME_GREEN[machine]="#A9DC76"
  THEME_YELLOW[machine]="#FFD866"
  THEME_BLUE[machine]="#78DCE8"
  THEME_MAGENTA[machine]="#AB9DF2"
  THEME_CYAN[machine]="#FC9867"
  THEME_WHITE[machine]="#FCFCFA"
  THEME_BRBG[machine]="#1A1A1C"
  THEME_COMMENT[machine]="#69676C"

  # Monokai Classic
  THEME_BG[classic]="#272822"
  THEME_FG[classic]="#F8F8F2"
  THEME_BLACK[classic]="#272822"
  THEME_RED[classic]="#F92672"
  THEME_GREEN[classic]="#A6E22E"
  THEME_YELLOW[classic]="#E6DB74"
  THEME_BLUE[classic]="#66D9EF"
  THEME_MAGENTA[classic]="#AE81FF"
  THEME_CYAN[classic]="#A1EFE4"
  THEME_WHITE[classic]="#F8F8F2"
  THEME_BRBG[classic]="#1B1C18"
  THEME_COMMENT[classic]="#75715E"

  # Filter Zen
  THEME_BG[zen]="#2D2A2E"
  THEME_FG[zen]="#FCFCFA"
  THEME_BLACK[zen]="#2D2A2E"
  THEME_RED[zen]="#FF6188"
  THEME_GREEN[zen]="#A9DC76"
  THEME_YELLOW[zen]="#FFD866"
  THEME_BLUE[zen]="#78DCE8"
  THEME_MAGENTA[zen]="#AB9DF2"
  THEME_CYAN[zen]="#FC9867"
  THEME_WHITE[zen]="#FCFCFA"
  THEME_BRBG[zen]="#1A1A1C"
  THEME_COMMENT[zen]="#69676C"

  # Filter Protorium
  THEME_BG[protorium]="#2D2A2E"
  THEME_FG[protorium]="#FCFCFA"
  THEME_BLACK[protorium]="#2D2A2E"
  THEME_RED[protorium]="#FF6188"
  THEME_GREEN[protorium]="#A9DC76"
  THEME_YELLOW[protorium]="#FFD866"
  THEME_BLUE[protorium]="#78DCE8"
  THEME_MAGENTA[protorium]="#AB9DF2"
  THEME_CYAN[protorium]="#FC9867"
  THEME_WHITE[protorium]="#FCFCFA"
  THEME_BRBG[protorium]="#1A1A1C"
  THEME_COMMENT[protorium]="#69676C"

  # Filter Relaxed
  THEME_BG[relaxed]="#3A3A3A"
  THEME_FG[relaxed]="#F8F8F2"
  THEME_BLACK[relaxed]="#3A3A3A"
  THEME_RED[relaxed]="#E06C75"
  THEME_GREEN[relaxed]="#98C379"
  THEME_YELLOW[relaxed]="#E5C07B"
  THEME_BLUE[relaxed]="#61AFEF"
  THEME_MAGENTA[relaxed]="#C678DD"
  THEME_CYAN[relaxed]="#56B6C2"
  THEME_WHITE[relaxed]="#F8F8F2"
  THEME_BRBG[relaxed]="#282828"
  THEME_COMMENT[relaxed]="#5C6370"

  # Filter Amber
  THEME_BG[amber]="#2D2A2E"
  THEME_FG[amber]="#FCFCFA"
  THEME_BLACK[amber]="#2D2A2E"
  THEME_RED[amber]="#E36A6A"
  THEME_GREEN[amber]="#A9DC76"
  THEME_YELLOW[amber]="#E5C07B"
  THEME_BLUE[amber]="#78DCE8"
  THEME_MAGENTA[amber]="#FC9867"
  THEME_CYAN[amber]="#56B6C2"
  THEME_WHITE[amber]="#FCFCFA"
  THEME_BRBG[amber]="#1A1A1C"
  THEME_COMMENT[amber]="#5C6370"
}

THEME_NAMES=(
  "spectrum" "octagon" "ristretto" "machine"
  "classic" "zen" "protorium" "relaxed" "amber"
)

THEME_DISPLAY=(
  "Chroma Spectrum" "Filter Octagon" "Filter Ristretto" "Filter Machine"
  "Monokai Classic" "Filter Zen" "Filter Protorium" "Filter Relaxed" "Filter Amber"
)

# ──────────────────────────────────────────────
# Helper functions
# ──────────────────────────────────────────────
log_info()  { printf "${BLUE}  ⓘ${RESET} %s\n" "$*"; }
log_ok()    { printf "${GREEN}  ✔${RESET} %s\n" "$*"; }
log_warn()  { printf "${YELLOW}  ⚠${RESET} %s\n" "$*"; }
log_error() { printf "${RED}  ✘${RESET} %s\n" "$*" >&2; }
log_step()  { printf "\n${BOLD}${CYAN}▸ %s${RESET}\n" "$*"; }
log_title() { printf "\n${BOLD}${WHITE}  %s${RESET}\n" "$*"; }

detect_os() {
  case "$(uname -s)" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "macos" ;;
    *)       echo "unknown" ;;
  esac
}

has_cmd() {
  command -v "$1" &>/dev/null
}

confirm() {
  local prompt="$1" default="${2:-y}"
  local yn
  if [[ "$default" == "y" ]]; then
    prompt="$prompt [Y/n] "
  else
    prompt="$prompt [y/N] "
  fi
  read -r -p "$(printf "${BOLD}${prompt}${RESET}")" yn
  yn="${yn:-$default}"
  [[ "$yn" =~ ^[Yy]$ ]]
}

# ──────────────────────────────────────────────
# Terminal detection
# ──────────────────────────────────────────────
detect_terminals() {
  local os="$1"
  local detected=()

  if has_cmd ghostty; then
    detected+=("ghostty")
    log_ok "Ghostty detected"
  fi

  if has_cmd alacritty; then
    detected+=("alacritty")
    log_ok "Alacritty detected"
  fi

  if has_cmd warp-terminal || [[ -d "/Applications/Warp.app" ]]; then
    detected+=("warp")
    log_ok "Warp detected"
  fi

  if has_cmd hyper; then
    detected+=("hyper")
    log_ok "Hyper detected"
  fi

  if has_cmd foot; then
    detected+=("foot")
    log_ok "Foot detected"
  fi

  if has_cmd kitty; then
    detected+=("kitty")
    log_ok "Kitty detected"
  fi

  if [[ "$os" == "macos" ]]; then
    if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]] || [[ -d "/Applications/Utilities/Terminal.app" ]] || [[ -f "/System/Applications/Utilities/Terminal.app/Contents/Info.plist" ]]; then
      detected+=("terminal.app")
      log_ok "Terminal.app detected"
    fi
    if [[ "$TERM_PROGRAM" == "iTerm.app" ]] || [[ -d "/Applications/iTerm.app" ]]; then
      detected+=("iterm2")
      log_ok "iTerm2 detected"
    fi
  fi

  # Check for Windows Terminal via default-profiles
  if has_cmd wt; then
    detected+=("windows-terminal")
    log_ok "Windows Terminal detected"
  fi

  printf '%s\n' "${detected[@]}"
}

# ──────────────────────────────────────────────
# Theme application per terminal
# ──────────────────────────────────────────────
apply_ghostty() {
  local theme="$1"
  local config_dir="${HOME}/.config/ghostty"
  local config_file="${config_dir}/config"
  mkdir -p "$config_dir"

  # Check if ghostty theme section exists, append or update
  if [[ -f "$config_file" ]] && grep -q "Chroma Theme" "$config_file"; then
    # Remove old theme block
    sed -i.bak '/^# --- Chroma Theme ---$/,/^# --- End Chroma Theme ---$/d' "$config_file"
  fi

  cat >> "$config_file" << THEME

# --- Chroma Theme: ${THEME_DISPLAY[$i]} ---
background = ${THEME_BG[$theme]}
foreground = ${THEME_FG[$theme]}
selection-background = ${THEME_COMMENT[$theme]}
selection-foreground = ${THEME_FG[$theme]}
cursor-color = ${THEME_FG[$theme]}
cursor-text = ${THEME_BG[$theme]}
palette = 0=${THEME_BLACK[$theme]}
palette = 1=${THEME_RED[$theme]}
palette = 2=${THEME_GREEN[$theme]}
palette = 3=${THEME_YELLOW[$theme]}
palette = 4=${THEME_BLUE[$theme]}
palette = 5=${THEME_MAGENTA[$theme]}
palette = 6=${THEME_CYAN[$theme]}
palette = 7=${THEME_WHITE[$theme]}
palette = 8=${THEME_BRBG[$theme]}
palette = 9=${THEME_RED[$theme]}
palette = 10=${THEME_GREEN[$theme]}
palette = 11=${THEME_YELLOW[$theme]}
palette = 12=${THEME_BLUE[$theme]}
palette = 13=${THEME_MAGENTA[$theme]}
palette = 14=${THEME_CYAN[$theme]}
palette = 15=${THEME_WHITE[$theme]}
# --- End Chroma Theme ---
THEME
  log_ok "Applied ${THEME_DISPLAY[$THEME_INDEX[$theme]]} to Ghostty"
}

apply_alacritty() {
  local theme="$1"
  local config_dir="${HOME}/.config/alacritty"
  local config_file="${config_dir}/alacritty.toml"
  mkdir -p "$config_dir"

  local theme_block
  theme_block=$(cat << TOML
# --- Chroma Theme: ${THEME_DISPLAY[$THEME_INDEX[$theme]]} ---
[colors.primary]
background = "${THEME_BG[$theme]}"
foreground = "${THEME_FG[$theme]}"

[colors.cursor]
cursor = "${THEME_FG[$theme]}"
text = "${THEME_BG[$theme]}"

[colors.selection]
background = "${THEME_COMMENT[$theme]}"
text = "${THEME_FG[$theme]}"

[colors.normal]
black = "${THEME_BLACK[$theme]}"
red = "${THEME_RED[$theme]}"
green = "${THEME_GREEN[$theme]}"
yellow = "${THEME_YELLOW[$theme]}"
blue = "${THEME_BLUE[$theme]}"
magenta = "${THEME_MAGENTA[$theme]}"
cyan = "${THEME_CYAN[$theme]}"
white = "${THEME_WHITE[$theme]}"

[colors.bright]
black = "${THEME_BRBG[$theme]}"
red = "${THEME_RED[$theme]}"
green = "${THEME_GREEN[$theme]}"
yellow = "${THEME_YELLOW[$theme]}"
blue = "${THEME_BLUE[$theme]}"
magenta = "${THEME_MAGENTA[$theme]}"
cyan = "${THEME_CYAN[$theme]}"
white = "${THEME_WHITE[$theme]}"
# --- End Chroma Theme ---
TOML
)

  if [[ -f "$config_file" ]]; then
    # Remove existing Chroma block if present
    if grep -q "Chroma Theme" "$config_file" 2>/dev/null; then
      # Use awk to remove between markers (more portable than sed ranges on macOS)
      awk '
        /# --- Chroma Theme/ { skip=1; next }
        /# --- End Chroma Theme/ { skip=0; next }
        !skip { print }
      ' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
    fi
  fi

  echo "$theme_block" >> "$config_file"
  log_ok "Applied ${THEME_DISPLAY[$THEME_INDEX[$theme]]} to Alacritty"
}

apply_kitty() {
  local theme="$1"
  local config_dir="${HOME}/.config/kitty"
  local config_file="${config_dir}/kitty.conf"
  mkdir -p "$config_dir"

  local theme_block
  theme_block=$(cat << CONF
# --- Chroma Theme: ${THEME_DISPLAY[$THEME_INDEX[$theme]]} ---
background ${THEME_BG[$theme]}
foreground ${THEME_FG[$theme]}
selection_background ${THEME_COMMENT[$theme]}
selection_foreground ${THEME_FG[$theme]}
cursor ${THEME_FG[$theme]}
cursor_text_color ${THEME_BG[$theme]}
color0 ${THEME_BLACK[$theme]}
color1 ${THEME_RED[$theme]}
color2 ${THEME_GREEN[$theme]}
color3 ${THEME_YELLOW[$theme]}
color4 ${THEME_BLUE[$theme]}
color5 ${THEME_MAGENTA[$theme]}
color6 ${THEME_CYAN[$theme]}
color7 ${THEME_WHITE[$theme]}
color8 ${THEME_BRBG[$theme]}
color9 ${THEME_RED[$theme]}
color10 ${THEME_GREEN[$theme]}
color11 ${THEME_YELLOW[$theme]}
color12 ${THEME_BLUE[$theme]}
color13 ${THEME_MAGENTA[$theme]}
color14 ${THEME_CYAN[$theme]}
color15 ${THEME_WHITE[$theme]}
# --- End Chroma Theme ---
CONF
)

  if [[ -f "$config_file" ]]; then
    if grep -q "Chroma Theme" "$config_file" 2>/dev/null; then
      awk '
        /# --- Chroma Theme/ { skip=1; next }
        /# --- End Chroma Theme/ { skip=0; next }
        !skip { print }
      ' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
    fi
  fi

  echo "$theme_block" >> "$config_file"
  log_ok "Applied ${THEME_DISPLAY[$THEME_INDEX[$theme]]} to Kitty"
}

apply_foot() {
  local theme="$1"
  local config_dir="${HOME}/.config/foot"
  local config_file="${config_dir}/foot.ini"
  mkdir -p "$config_dir"

  local theme_block
  theme_block=$(cat << INI
# --- Chroma Theme: ${THEME_DISPLAY[$THEME_INDEX[$theme]]} ---
[colors]
background=${THEME_BG[$theme]}
foreground=${THEME_FG[$theme]}
regular0=${THEME_BLACK[$theme]}
regular1=${THEME_RED[$theme]}
regular2=${THEME_GREEN[$theme]}
regular3=${THEME_YELLOW[$theme]}
regular4=${THEME_BLUE[$theme]}
regular5=${THEME_MAGENTA[$theme]}
regular6=${THEME_CYAN[$theme]}
regular7=${THEME_WHITE[$theme]}
bright0=${THEME_BRBG[$theme]}
bright1=${THEME_RED[$theme]}
bright2=${THEME_GREEN[$theme]}
bright3=${THEME_YELLOW[$theme]}
bright4=${THEME_BLUE[$theme]}
bright5=${THEME_MAGENTA[$theme]}
bright6=${THEME_CYAN[$theme]}
bright7=${THEME_WHITE[$theme]}
selection-background=${THEME_COMMENT[$theme]}
selection-foreground=${THEME_FG[$theme]}
# --- End Chroma Theme ---
INI
)

  if [[ -f "$config_file" ]]; then
    if grep -q "Chroma Theme" "$config_file" 2>/dev/null; then
      awk '
        /# --- Chroma Theme/ { skip=1; next }
        /# --- End Chroma Theme/ { skip=0; next }
        !skip { print }
      ' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
    fi
  fi

  echo "$theme_block" >> "$config_file"
  log_ok "Applied ${THEME_DISPLAY[$THEME_INDEX[$theme]]} to Foot"
}

apply_warp() {
  local theme="$1"
  local warp_dir="${HOME}/.warp/themes"
  mkdir -p "$warp_dir"

  local theme_name="${THEME_DISPLAY[$THEME_INDEX[$theme]]}"
  local file_name="chroma-${theme}.yaml"
  local file_path="${warp_dir}/${file_name}"

  cat > "$file_path" << YAML
# Chroma Theme: ${theme_name}
accent: "${THEME_MAGENTA[$theme]}"
background: "${THEME_BG[$theme]}"
details: "${THEME_COMMENT[$theme]}"
foreground: "${THEME_FG[$theme]}"
black: "${THEME_BLACK[$theme]}"
red: "${THEME_RED[$theme]}"
green: "${THEME_GREEN[$theme]}"
yellow: "${THEME_YELLOW[$theme]}"
blue: "${THEME_BLUE[$theme]}"
magenta: "${THEME_MAGENTA[$theme]}"
cyan: "${THEME_CYAN[$theme]}"
white: "${THEME_WHITE[$theme]}"
YAML
  log_ok "Applied ${theme_name} to Warp (theme file: ${file_name})"
  log_warn "Select '${theme_name}' in Warp Settings → Appearance → Themes"
}

apply_iterm2() {
  local theme="$1"
  local iterm_dir="${HOME}/.config/iterm2"
  mkdir -p "$iterm_dir"

  local file_name="Chroma-${theme}.itermcolors"
  local file_path="${iterm_dir}/${file_name}"

  cat > "$file_path" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Ansi 0 Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_BLACK[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.18))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_BLACK[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.16))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_BLACK[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 0.18))</real></dict></key>
  <key>Ansi 1 Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_RED[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.53))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_RED[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.38))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_RED[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 1.0))</real></dict></key>
  <key>Ansi 2 Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_GREEN[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.46))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_GREEN[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.86))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_GREEN[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 0.66))</real></dict></key>
  <key>Ansi 3 Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_YELLOW[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.40))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_YELLOW[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.85))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_YELLOW[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 1.0))</real></dict></key>
  <key>Ansi 4 Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_BLUE[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.91))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_BLUE[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.86))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_BLUE[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 0.47))</real></dict></key>
  <key>Ansi 5 Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_MAGENTA[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.95))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_MAGENTA[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.62))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_MAGENTA[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 0.67))</real></dict></key>
  <key>Ansi 6 Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_CYAN[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.91))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_CYAN[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.86))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_CYAN[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 0.47))</real></dict></key>
  <key>Ansi 7 Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_WHITE[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.98))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_WHITE[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.99))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_WHITE[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 0.99))</real></dict></key>
  <key>Background Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_BG[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.18))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_BG[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.16))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_BG[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 0.18))</real></dict></key>
  <key>Foreground Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_FG[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.98))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_FG[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.99))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_FG[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 0.99))</real></dict></key>
  <key>Selected Text Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_FG[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.98))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_FG[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.99))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_FG[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 0.99))</real></dict></key>
  <key>Selection Color</key><dict><key>Alpha Component</key><real>1</real><key>Color Space</key><string>sRGB</string><key>Blue Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_COMMENT[$theme]:1} | cut -c5-6)/255" | bc 2>/dev/null || echo 0.42))</real><key>Green Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_COMMENT[$theme]:1} | cut -c3-4)/255" | bc 2>/dev/null || echo 0.40))</real><key>Red Component</key><real>$(printf "%.4f" $(echo "scale=4; ibase=16; $(echo ${THEME_COMMENT[$theme]:1} | cut -c1-2)/255" | bc 2>/dev/null || echo 0.25))</real></dict></key>
</dict>
</plist>
PLIST
  log_ok "Applied ${THEME_DISPLAY[$THEME_INDEX[$theme]]} to iTerm2 (import ${file_name} in iTerm2 → Preferences → Profiles → Colors → Color Presets)"
}

apply_hyper() {
  local theme="$1"
  local hyper_file="${HOME}/.hyper.js"

  if [[ ! -f "$hyper_file" ]]; then
    log_warn "Hyper not configured (no .hyper.js found). Skipping."
    return
  fi

  local bg="${THEME_BG[$theme]}"
  local fg="${THEME_FG[$theme]}"
  local black="${THEME_BLACK[$theme]}"
  local red="${THEME_RED[$theme]}"
  local green="${THEME_GREEN[$theme]}"
  local yellow="${THEME_YELLOW[$theme]}"
  local blue="${THEME_BLUE[$theme]}"
  local magenta="${THEME_MAGENTA[$theme]}"
  local cyan="${THEME_CYAN[$theme]}"
  local white="${THEME_WHITE[$theme]}"
  local brbg="${THEME_BRBG[$theme]}"

  local temp_file
  temp_file="$(mktemp)"

  # Backup
  cp "$hyper_file" "${hyper_file}.bak.$(date +%s)" 2>/dev/null || true

  # Update colors in .hyper.js
  node -e "
    const fs = require('fs');
    let content = fs.readFileSync('$hyper_file', 'utf8');
    const colors = {
      black: '$black', red: '$red', green: '$green', yellow: '$yellow',
      blue: '$blue', magenta: '$magenta', cyan: '$cyan', white: '$white',
      lightBlack: '$brbg', lightRed: '$red', lightGreen: '$green',
      lightYellow: '$yellow', lightBlue: '$blue', lightMagenta: '$magenta',
      lightCyan: '$cyan', lightWhite: '$white',
    };
    // Replace colors block
    content = content.replace(/colors:\s*\{[^}]+\}/s, 'colors: ' + JSON.stringify(colors, null, 2));
    fs.writeFileSync('$temp_file', content, 'utf8');
  " 2>/dev/null || {
    log_warn "Could not auto-update .hyper.js. Please apply the theme manually."
    return
  }

  mv "$temp_file" "$hyper_file"
  log_ok "Applied ${THEME_DISPLAY[$THEME_INDEX[$theme]]} to Hyper"
}

apply_terminal_app() {
  local theme="$1"
  # Terminal.app on macOS uses .terminal files (XML plists)
  local term_dir="${HOME}/.config/terminal"
  mkdir -p "$term_dir"

  local file_name="Chroma-${theme}.terminal"
  local file_path="${term_dir}/${file_name}"

  cat > "$file_path" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>ANSIBlackColor</key><data>$(printf "${THEME_BLACK[$theme]:1}" | xxd -r -p | base64 2>/dev/null || echo "")</data>
  <key>ANSIRedColor</key><data>$(printf "${THEME_RED[$theme]:1}" | xxd -r -p | base64 2>/dev/null || echo "")</data>
  <key>ANSIGreenColor</key><data>$(printf "${THEME_GREEN[$theme]:1}" | xxd -r -p | base64 2>/dev/null || echo "")</data>
  <key>ANSIYellowColor</key><data>$(printf "${THEME_YELLOW[$theme]:1}" | xxd -r -p | base64 2>/dev/null || echo "")</data>
  <key>ANSIBlueColor</key><data>$(printf "${THEME_BLUE[$theme]:1}" | xxd -r -p | base64 2>/dev/null || echo "")</data>
  <key>ANSIMagentaColor</key><data>$(printf "${THEME_MAGENTA[$theme]:1}" | xxd -r -p | base64 2>/dev/null || echo "")</data>
  <key>ANSICyanColor</key><data>$(printf "${THEME_CYAN[$theme]:1}" | xxd -r -p | base64 2>/dev/null || echo "")</data>
  <key>ANSIWhiteColor</key><data>$(printf "${THEME_WHITE[$theme]:1}" | xxd -r -p | base64 2>/dev/null || echo "")</data>
  <key>BackgroundColor</key><data>$(printf "${THEME_BG[$theme]:1}" | xxd -r -p | base64 2>/dev/null || echo "")</data>
  <key>TextColor</key><data>$(printf "${THEME_FG[$theme]:1}" | xxd -r -p | base64 2>/dev/null || echo "")</data>
  <key>SelectionColor</key><data>$(printf "${THEME_COMMENT[$theme]:1}" | xxd -r -p | base64 2>/dev/null || echo "")</data>
</dict>
</plist>
PLIST

  log_ok "Exported ${THEME_DISPLAY[$THEME_INDEX[$theme]]} for Terminal.app"
  log_warn "Open ${file_path} in Terminal.app to import the theme"
}

# ──────────────────────────────────────────────
# Color preview
# ──────────────────────────────────────────────
show_preview() {
  local theme="$1"
  echo ""
  log_title "${THEME_DISPLAY[$THEME_INDEX[$theme]]}"
  echo ""
  printf "  ${BOLD}Background:${RESET}  "
  printf "\033[48;2;%d;%d;%dm              ${RESET}\n" \
    "$(printf '%d' 0x$(echo ${THEME_BG[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_BG[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_BG[$theme]:1} | cut -c5-6))"
  printf "  ${BOLD}Foreground:${RESET}  "
  printf "\033[48;2;%d;%d;%dm              ${RESET}\n" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c5-6))"
  echo ""
  printf "  ${BOLD}Palette:${RESET}\n"
  local names=("Black" "Red" "Green" "Yellow" "Blue" "Magenta" "Cyan" "White")
  local colors=(
    "${THEME_BLACK[$theme]}" "${THEME_RED[$theme]}" "${THEME_GREEN[$theme]}"
    "${THEME_YELLOW[$theme]}" "${THEME_BLUE[$theme]}" "${THEME_MAGENTA[$theme]}"
    "${THEME_CYAN[$theme]}" "${THEME_WHITE[$theme]}"
  )
  printf "  "
  for i in "${!colors[@]}"; do
    local c="${colors[$i]}"
    printf "\033[48;2;%d;%d;%dm  ${RESET} " \
      "$(printf '%d' 0x$(echo $c | cut -c2-3))" \
      "$(printf '%d' 0x$(echo $c | cut -c4-5))" \
      "$(printf '%d' 0x$(echo $c | cut -c6-7))"
  done
  echo ""
  printf "  "
  for name in "${names[@]}"; do
    printf "${DIM}%-6s${RESET} " "$name"
  done
  echo ""
  echo ""
  printf "  ${BOLD}Sample:${RESET} "
  printf "\033[38;2;%d;%d;%mdconst\
 \033[38;2;%d;%d;%dmx\
 \033[38;2;%d;%d;%dm=\
 \033[38;2;%d;%d;%dm42\
 \033[38;2;%d;%d;%dm;\
 \033[38;2;%d;%d;%dm\
\033[38;2;%d;%d;%dmconsole\033[38;2;%d;%d;%dm.\033[38;2;%d;%d;%dmlog\033[38;2;%d;%d;%dm(\033[38;2;%d;%d;%dm\"hello\033[38;2;%d;%d;%dm\"\
\033[38;2;%d;%d;%dm)\033[0m\n" \
    "$(printf '%d' 0x$(echo ${THEME_MAGENTA[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_MAGENTA[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_MAGENTA[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_CYAN[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_CYAN[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_CYAN[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_GREEN[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_GREEN[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_GREEN[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_RED[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_RED[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_RED[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_MAGENTA[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_MAGENTA[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_MAGENTA[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_CYAN[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_CYAN[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_CYAN[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_GREEN[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_GREEN[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_GREEN[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_RED[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_RED[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_RED[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_YELLOW[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_YELLOW[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_YELLOW[$theme]:1} | cut -c5-6))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c1-2))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c3-4))" \
    "$(printf '%d' 0x$(echo ${THEME_FG[$theme]:1} | cut -c5-6))"
}

# ──────────────────────────────────────────────
# Theme index helper
# ──────────────────────────────────────────────
declare -A THEME_INDEX
for idx in "${!THEME_NAMES[@]}"; do
  THEME_INDEX["${THEME_NAMES[$idx]}"]="$idx"
done

# ──────────────────────────────────────────────
# Install functions
# ──────────────────────────────────────────────
install_fonts() {
  log_step "Installing JetBrainsMono Nerd Font"
  local os="$1"
  local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  if has_cmd curl; then
    curl -fsSL "$font_url" -o "${tmp_dir}/JetBrainsMono.zip" || {
      log_error "Failed to download JetBrainsMono Nerd Font"
      rm -rf "$tmp_dir"
      return 1
    }
  elif has_cmd wget; then
    wget -q "$font_url" -O "${tmp_dir}/JetBrainsMono.zip" || {
      log_error "Failed to download JetBrainsMono Nerd Font"
      rm -rf "$tmp_dir"
      return 1
    }
  else
    log_error "Neither curl nor wget found. Cannot download font."
    rm -rf "$tmp_dir"
    return 1
  fi

  if has_cmd unzip; then
    unzip -qo "${tmp_dir}/JetBrainsMono.zip" -d "${tmp_dir}/fonts" || {
      log_error "Failed to unzip font archive"
      rm -rf "$tmp_dir"
      return 1
    }
  elif has_cmd 7z; then
    7z x "${tmp_dir}/JetBrainsMono.zip" -o"${tmp_dir}/fonts" -y >/dev/null 2>&1 || {
      log_error "Failed to extract font archive"
      rm -rf "$tmp_dir"
      return 1
    }
  else
    log_error "Neither unzip nor 7z found. Cannot extract font."
    rm -rf "$tmp_dir"
    return 1
  fi

  local font_dir
  if [[ "$os" == "macos" ]]; then
    font_dir="${HOME}/Library/Fonts"
  else
    font_dir="${HOME}/.local/share/fonts"
    mkdir -p "$font_dir"
  fi

  # Install only the .ttf files matching JetBrainsMono
  local count=0
  while IFS= read -r -d '' f; do
    cp "$f" "$font_dir/" && count=$((count + 1))
  done < <(find "${tmp_dir}/fonts" -name "JetBrainsMono*.ttf" -print0 2>/dev/null || true)

  if [[ "$count" -gt 0 ]]; then
    log_ok "Installed ${count} JetBrainsMono Nerd Font files to ${font_dir}"
    # Update font cache on Linux
    if [[ "$os" == "linux" ]] && has_cmd fc-cache; then
      fc-cache -f "$font_dir" 2>/dev/null && log_ok "Font cache updated"
    fi
  else
    log_error "No JetBrainsMono TTF files found in the archive"
    rm -rf "$tmp_dir"
    return 1
  fi

  rm -rf "$tmp_dir"

  # Verify
  if has_cmd fc-list; then
    if fc-list | grep -qi "JetBrainsMono" 2>/dev/null; then
      log_ok "JetBrainsMono Nerd Font verified (fc-list)"
    fi
  fi
}

install_starship() {
  log_step "Installing Starship Prompt"
  if has_cmd starship; then
    log_ok "Starship is already installed"
  else
    if has_cmd curl; then
      curl -sS https://starship.rs/install.sh | sh -s -- -y || {
        log_error "Failed to install Starship"
        return 1
      }
    elif has_cmd wget; then
      wget -qO- https://starship.rs/install.sh | sh -s -- -y || {
        log_error "Failed to install Starship"
        return 1
      }
    else
      log_error "Neither curl nor wget found. Cannot install Starship."
      return 1
    fi
    log_ok "Starship installed"
  fi

  # Install config
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local config_dir="${HOME}/.config"
  mkdir -p "$config_dir"

  if [[ -f "${config_dir}/starship.toml" ]]; then
    local backup="${config_dir}/starship.toml.bak.$(date +%s)"
    cp "${config_dir}/starship.toml" "$backup"
    log_info "Backed up existing starship.toml → ${backup}"
  fi

  cp "${script_dir}/starship.toml" "${config_dir}/starship.toml"
  log_ok "Starship config installed to ${config_dir}/starship.toml"

  # Add to shell config if not present
  local shell_config
  case "${SHELL:-}" in
    *zsh)  shell_config="${HOME}/.zshrc" ;;
    *bash) shell_config="${HOME}/.bashrc" ;;
    *fish) shell_config="${HOME}/.config/fish/config.fish" ;;
    *)     shell_config="" ;;
  esac

  if [[ -n "$shell_config" ]] && [[ -f "$shell_config" ]]; then
    local eval_line
    case "${SHELL:-}" in
      *fish) eval_line="starship init fish | source" ;;
      *)     eval_line='eval "$(starship init)'"${SHELL##*/}"')"' ;;
    esac
    if ! grep -q "starship init" "$shell_config" 2>/dev/null; then
      echo "" >> "$shell_config"
      echo "# Starship prompt (installed by chroma-terminal)" >> "$shell_config"
      echo "$eval_line" >> "$shell_config"
      log_ok "Added Starship init to ${shell_config}"
    fi
  fi
}

install_tools() {
  log_step "Installing CLI Tools"
  local os="$1"
  local tools=("eza" "bat" "fd" "ripgrep" "zoxide" "fzf")
  local to_install=()

  for tool in "${tools[@]}"; do
    if has_cmd "$tool"; then
      log_ok "${tool} is already installed"
    else
      to_install+=("$tool")
    fi
  done

  if [[ ${#to_install[@]} -eq 0 ]]; then
    log_info "All tools are already installed"
    return 0
  fi

  if [[ "$os" == "macos" ]]; then
    if has_cmd brew; then
      HOMEBREW_NO_AUTO_UPDATE=1 brew install "${to_install[@]}" 2>/dev/null || {
        log_warn "Some tools failed to install via Homebrew. Check 'brew install ${to_install[*]}'"
      }
    else
      log_warn "Homebrew not found. Install tools manually or install Homebrew first."
    fi
  elif [[ "$os" == "linux" ]]; then
    # Detect package manager
    if has_cmd apt-get; then
      # Map tool names to apt package names
      for tool in "${to_install[@]}"; do
        case "$tool" in
          eza)    sudo apt-get install -y eza 2>/dev/null || cargo install eza 2>/dev/null || log_warn "eza install failed" ;;
          bat)    sudo apt-get install -y bat 2>/dev/null || log_warn "bat install failed" ;;
          fd)     sudo apt-get install -y fd-find 2>/dev/null || log_warn "fd install failed" ;;
          ripgrep) sudo apt-get install -y ripgrep 2>/dev/null || log_warn "ripgrep install failed" ;;
          zoxide) sudo apt-get install -y zoxide 2>/dev/null || curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash 2>/dev/null || log_warn "zoxide install failed" ;;
          fzf)    sudo apt-get install -y fzf 2>/dev/null || log_warn "fzf install failed" ;;
        esac
      done
    elif has_cmd dnf; then
      for tool in "${to_install[@]}"; do
        sudo dnf install -y "$tool" 2>/dev/null || log_warn "${tool} install failed"
      done
    elif has_cmd pacman; then
      for tool in "${to_install[@]}"; do
        sudo pacman -S --noconfirm "$tool" 2>/dev/null || log_warn "${tool} install failed"
      done
    else
      log_warn "No supported package manager found (apt/dnf/pacman). Install tools manually."
    fi
  fi

  # Verify installations
  for tool in "${to_install[@]}"; do
    if has_cmd "$tool"; then
      log_ok "${tool} installed"
    else
      log_warn "${tool} could not be installed"
    fi
  done
}

# ──────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────
main() {
  local theme=""
  local do_font=false
  local do_prompt=false
  local do_tools=false
  local interactive=false

  init_theme_colors

  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
      --font)    do_font=true ;;
      --prompt)  do_prompt=true ;;
      --tools)   do_tools=true ;;
      --all)     do_font=true; do_prompt=true; do_tools=true ;;
      --help|-h)
        sed -n '2,18p' "$0" | sed 's/^# //; s/^#$//'
        exit 0
        ;;
      --list-themes)
        echo ""
        log_title "Available Themes"
        echo ""
        for i in "${!THEME_NAMES[@]}"; do
          local name="${THEME_NAMES[$i]}"
          local display="${THEME_DISPLAY[$i]}"
          printf "  ${BOLD}%-16s${RESET} %s\n" "$name" "$display"
        done
        echo ""
        exit 0
        ;;
      --preview)
        echo ""
        log_title "Theme Previews"
        echo ""
        for name in "${THEME_NAMES[@]}"; do
          show_preview "$name"
        done
        exit 0
        ;;
      --*)
        log_error "Unknown option: $arg"
        echo "Usage: bash bootstrap.sh [theme-name] [options]"
        echo "Try 'bash bootstrap.sh --help' for more information."
        exit 1
        ;;
      *)
        if [[ -z "$theme" ]]; then
          theme="$arg"
        else
          log_error "Unexpected argument: $arg"
          exit 1
        fi
        ;;
    esac
  done

  # Validate theme
  if [[ -n "$theme" ]]; then
    local valid=false
    for t in "${THEME_NAMES[@]}"; do
      [[ "$t" == "$theme" ]] && { valid=true; break; }
    done
    if ! $valid; then
      log_error "Unknown theme: ${theme}"
      echo "Available themes: ${THEME_NAMES[*]}"
      exit 1
    fi
  fi

  # Interactive mode
  if [[ -z "$theme" ]]; then
    interactive=true
    echo ""
    log_title "╔══════════════════════════════════════╗"
    log_title "║  Chroma Terminal Theme Installer      ║"
    log_title "╚══════════════════════════════════════╝"
    echo ""

    # Select theme
    echo ""
    log_title "Select a theme:"
    echo ""
    for i in "${!THEME_NAMES[@]}"; do
      printf "  ${BOLD}%2d)${RESET} %-16s ${DIM}%s${RESET}\n" $((i + 1)) "${THEME_NAMES[$i]}" "${THEME_DISPLAY[$i]}"
    done
    echo ""
    read -r -p "$(printf "${BOLD}Enter theme number or name [1]:${RESET} ")" choice
    choice="${choice:-1}"

    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#THEME_NAMES[@]} ]]; then
      theme="${THEME_NAMES[$((choice - 1))]}"
    else
      # Try as name
      local found=false
      for t in "${THEME_NAMES[@]}"; do
        if [[ "$t" == "$choice" ]]; then
          theme="$t"
          found=true
          break
        fi
      done
      if ! $found; then
        theme="${THEME_NAMES[0]}"
        log_warn "Invalid choice, using default: ${theme}"
      fi
    fi

    echo ""
    show_preview "$theme"
    echo ""

    # Ask about optional installs
    if ! $do_font && ! $do_prompt && ! $do_tools; then
      if confirm "Install JetBrainsMono Nerd Font?"; then do_font=true; fi
      if confirm "Install Starship prompt with Chroma theme config?"; then do_prompt=true; fi
      if confirm "Install CLI tools (eza, bat, fd, ripgrep, zoxide, fzf)?"; then do_tools=true; fi
    fi
  fi

  local os
  os="$(detect_os)"
  log_info "Detected OS: ${os}"

  # Detect terminals
  log_step "Detecting Terminals"
  local -a terminals
  mapfile -t terminals < <(detect_terminals "$os")

  if [[ ${#terminals[@]} -eq 0 ]]; then
    log_warn "No supported terminals detected. Theme files will still be generated."
  fi

  # Apply theme
  log_step "Applying Theme: ${THEME_DISPLAY[$THEME_INDEX[$theme]]}"
  for term in "${terminals[@]}"; do
    case "$term" in
      ghostty)    apply_ghostty "$theme" ;;
      alacritty)  apply_alacritty "$theme" ;;
      kitty)      apply_kitty "$theme" ;;
      foot)       apply_foot "$theme" ;;
      warp)       apply_warp "$theme" ;;
      iterm2)     apply_iterm2 "$theme" ;;
      hyper)      apply_hyper "$theme" ;;
      terminal.app) apply_terminal_app "$theme" ;;
    esac
  done

  # Optional installations
  if $do_font; then
    install_fonts "$os"
  fi

  if $do_prompt; then
    install_starship "$os"
  fi

  if $do_tools; then
    install_tools "$os"
  fi

  # Summary
  echo ""
  log_title "╔════════════════════════════════════════════╗"
  log_title "║  Setup Complete! 🎉                        ║"
  log_title "╚════════════════════════════════════════════╝"
  echo ""
  log_info "Theme applied: ${BOLD}${THEME_DISPLAY[$THEME_INDEX[$theme]]}${RESET}"
  log_info "Terminals configured: ${BOLD}${terminals[*]:-(none)}${RESET}"
  if $do_font; then
    log_info "Font: JetBrainsMono Nerd Font installed"
  fi
  if $do_prompt; then
    log_info "Prompt: Starship configured (restart shell or run: exec \$SHELL)"
  fi
  if $do_tools; then
    log_info "Tools: installed"
  fi
  echo ""
  log_info "To preview the theme in your terminal, run:"
  echo ""
  printf "  ${BOLD}bash %s --preview${RESET}\n" "$0"
  echo ""
}

main "$@"
