#!/usr/bin/env bash
#
# fonts.sh — JetBrainsMono Nerd Font Installer (Linux & macOS)
#
# Downloads and installs JetBrainsMono Nerd Font to the system.
#   Linux:   ~/.local/share/fonts
#   macOS:   ~/Library/Fonts
#
# Usage: bash fonts.sh [options]
#   --help      Show this help
#   --verify    Only verify existing installation
#

set -euo pipefail

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

log_info()  { printf "${BLUE}  ⓘ${RESET} %s\n" "$*"; }
log_ok()    { printf "${GREEN}  ✔${RESET} %s\n" "$*"; }
log_warn()  { printf "${YELLOW}  ⚠${RESET} %s\n" "$*"; }
log_error() { printf "${RED}  ✘${RESET} %s\n" "$*" >&2; }
log_step()  { printf "\n${BOLD}${CYAN}▸ %s${RESET}\n" "$*"; }

detect_os() {
  case "$(uname -s)" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "macos" ;;
    *)       echo "unknown" ;;
  esac
}

has_cmd() { command -v "$1" &>/dev/null; }

get_font_dir() {
  local os="$1"
  if [[ "$os" == "macos" ]]; then
    echo "${HOME}/Library/Fonts"
  else
    echo "${HOME}/.local/share/fonts"
  fi
}

verify_fonts() {
  local os="$1"
  local font_dir
  font_dir="$(get_font_dir "$os")"

  log_info "Font directory: ${font_dir}"

  if [[ -d "$font_dir" ]]; then
    local count
    count="$(find "$font_dir" -name "JetBrainsMono*.ttf" 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "$count" -gt 0 ]]; then
      log_ok "Found ${count} JetBrainsMono Nerd Font file(s)"
      if has_cmd fc-list; then
        if fc-list | grep -qi "JetBrainsMono" 2>/dev/null; then
          log_ok "Verified via fc-list"
        fi
      fi
      return 0
    fi
  fi

  log_warn "JetBrainsMono Nerd Font not found"
  return 1
}

install_fonts() {
  local os="$1"
  local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local font_dir
  font_dir="$(get_font_dir "$os")"

  log_step "Downloading JetBrainsMono Nerd Font"

  if has_cmd curl; then
    curl -fsSL "$font_url" -o "${tmp_dir}/JetBrainsMono.zip" || {
      log_error "Download failed (curl)"
      rm -rf "$tmp_dir"
      exit 1
    }
  elif has_cmd wget; then
    wget -q "$font_url" -O "${tmp_dir}/JetBrainsMono.zip" || {
      log_error "Download failed (wget)"
      rm -rf "$tmp_dir"
      exit 1
    }
  else
    log_error "Neither curl nor wget found. Install one of them first."
    rm -rf "$tmp_dir"
    exit 1
  fi

  log_ok "Downloaded successfully"

  log_step "Extracting fonts"

  if has_cmd unzip; then
    unzip -qo "${tmp_dir}/JetBrainsMono.zip" -d "${tmp_dir}/fonts" || {
      log_error "Failed to extract (unzip)"
      rm -rf "$tmp_dir"
      exit 1
    }
  elif has_cmd 7z; then
    7z x "${tmp_dir}/JetBrainsMono.zip" -o"${tmp_dir}/fonts" -y >/dev/null 2>&1 || {
      log_error "Failed to extract (7z)"
      rm -rf "$tmp_dir"
      exit 1
    }
  else
    log_error "Neither unzip nor 7z found. Install one of them first."
    rm -rf "$tmp_dir"
    exit 1
  fi

  log_step "Installing fonts to ${font_dir}"
  mkdir -p "$font_dir"

  local count=0
  while IFS= read -r -d '' f; do
    local dest="${font_dir}/$(basename "$f")"
    if [[ ! -f "$dest" ]]; then
      cp "$f" "$dest"
      count=$((count + 1))
    fi
  done < <(find "${tmp_dir}/fonts" -name "JetBrainsMono*.ttf" -print0 2>/dev/null || true)

  if [[ "$count" -gt 0 ]]; then
    log_ok "Installed ${count} new JetBrainsMono Nerd Font files"
  else
    log_info "All fonts already up to date"
  fi

  # Update font cache on Linux
  if [[ "$os" == "linux" ]] && has_cmd fc-cache; then
    log_step "Updating font cache"
    fc-cache -f "$font_dir" 2>/dev/null
    log_ok "Font cache updated"
  fi

  rm -rf "$tmp_dir"

  echo ""
  log_step "Verifying installation"
  if verify_fonts "$os"; then
    echo ""
    log_ok "JetBrainsMono Nerd Font is installed and ready!"
  else
    log_warn "Font installation may not be complete"
  fi
}

main() {
  local os
  os="$(detect_os)"

  echo ""
  printf "${BOLD}${WHITE}  JetBrainsMono Nerd Font Installer${RESET}\n"
  echo ""

  if [[ "$os" == "unknown" ]]; then
    log_error "Unsupported OS: $(uname -s)"
    exit 1
  fi

  log_info "Detected OS: ${os}"

  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
      --help|-h)
        sed -n '3,10p' "$0" | sed 's/^# //; s/^#$//'
        exit 0
        ;;
      --verify)
        verify_fonts "$os"
        exit $?
        ;;
    esac
  done

  # Check if already installed
  if verify_fonts "$os"; then
    echo ""
    if [[ "${1:-}" != "--force" ]]; then
      log_info "Font already installed. Use --force to reinstall or --verify to just check."
      exit 0
    fi
  fi

  install_fonts "$os"
}

main "$@"
