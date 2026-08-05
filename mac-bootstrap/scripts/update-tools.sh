#!/usr/bin/env zsh
# update-tools — Check and update all locally-installed CLI tools
#   update-tools             check for available updates
#   update-tools --check     same as above
#   update-tools --update    apply all available updates
#   update-tools --update <tool>  update only named tool
#   update-tools --quiet     non-interactive, minimal output

set -euo pipefail

TOOLS_DIR="$HOME/.local/bin"
OPT_DIR="$HOME/.local/opt"
FZF_DIR="$HOME/.fzf"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

ok="●"; warn="▲"; err="✗"; info="→"

log()   { $QUIET || printf "${NC}%b %b${NC}\n" "${info}" "$*"; }
ok()    { $QUIET || printf "${GREEN}%b %b${NC}\n" "${ok}" "$*"; }
info()  { $QUIET || printf "${BLUE}%b %b${NC}\n" "${info}" "$*"; }
warn()  { $QUIET || printf "${YELLOW}%b %b${NC}\n" "${warn}" "$*"; }
fail()  { printf "${RED}%b %b${NC}\n" "${err}" "$*"; }
header(){ $QUIET || printf "\n${BOLD}── %s ──${NC}\n" "$1"; }

cmd_exists() { command -v "$1" &>/dev/null; }

latest_gh_release() {
  gh release view -R "$1" --json tagName --jq .tagName 2>/dev/null
}

version_gt() {
  [ "$(printf '%s\n' "$1" "$2" | sort -V | tail -1)" = "$1" ] && [ "$1" != "$2" ]
}

DO_UPDATE=false; UPDATE_TARGET=""; QUIET=false; SINGLE_MODE=false
for arg in "$@"; do
  case "$arg" in
    --update)     DO_UPDATE=true ;;
    --check)      DO_UPDATE=false ;;
    --quiet|-q)   QUIET=true ;;
    --help|-h)    sed -n '2,11p' "$0"; exit 0 ;;
    *)            UPDATE_TARGET="$arg" ;;
  esac
done

$DO_UPDATE && [ -n "$UPDATE_TARGET" ] && SINGLE_MODE=true

# ── Tool: Neovim ──────────────────────────────────────────────────
TOOL_NVIM_REPO="neovim/neovim"
check_nvim() {
  local current latest
  current=$(cmd_exists nvim && nvim --version | head -1 | awk '{print $2}' | sed 's/^v//' || echo "not-installed")
  latest=$(latest_gh_release "$TOOL_NVIM_REPO" | sed 's/^v//')
  [ "$current" = "$latest" ] && { ok "neovim  ${current}"; return 0; } \
                            || { warn "neovim  ${current} → ${latest}"; return 1; }
}
update_nvim() {
  local ver; ver=$(latest_gh_release "$TOOL_NVIM_REPO" | sed 's/^v//')
  log "Downloading Neovim v${ver}..."
  mkdir -p "$OPT_DIR"
  gh release download "v${ver}" -R "$TOOL_NVIM_REPO" -p "nvim-macos-arm64.tar.gz" --clobber
  tar xzf "nvim-macos-arm64.tar.gz" -C "$OPT_DIR"
  ln -sf "$OPT_DIR/nvim-macos-arm64/bin/nvim" "$TOOLS_DIR/nvim"
  rm -f nvim-macos-arm64.tar.gz
  ok "neovim  → ${ver}"
}

# ── Tool: Node.js ─────────────────────────────────────────────────
TOOL_NODE_REPO="nodejs/node"
check_node() {
  local current major latest_line latest_ver target_ver
  current=$(cmd_exists node && node --version | sed 's/^v//' || echo "not-installed")
  major=$(echo "$current" | cut -d. -f1)
  latest_line=$(gh release list -R "$TOOL_NODE_REPO" -L 50 2>/dev/null \
    | grep -v 'rc\|beta\|nightly' | grep "^v${major}\." | head -1)
  latest_ver=$(echo "$latest_line" | awk '{print $1}' | sed 's/^v//')
  target_ver="${latest_ver:-$current}"
  [ "$current" = "$target_ver" ] && { ok "node    ${current}"; return 0; } \
                                 || { warn "node    ${current} → ${target_ver}"; return 1; }
}
update_node() {
  local major latest_ver
  major=$(node --version 2>/dev/null | sed 's/^v//' | cut -d. -f1)
  latest_ver=$(gh release list -R "$TOOL_NODE_REPO" -L 50 2>/dev/null \
    | grep -v 'rc\|beta\|nightly' | grep "^v${major}\." | head -1 | awk '{print $1}' | sed 's/^v//')
  [ -z "$latest_ver" ] && { fail "Could not determine latest Node v${major}"; return 1; }
  local dirname="node-v${latest_ver}-darwin-arm64"
  local tarball="${dirname}.tar.gz"
  log "Downloading Node.js v${latest_ver}..."
  curl -fsSL "https://nodejs.org/dist/v${latest_ver}/${tarball}" -o "$tarball"
  tar xzf "$tarball" -C "$OPT_DIR"
  for bin in node npm npx corepack; do
    ln -sf "$OPT_DIR/$dirname/bin/$bin" "$TOOLS_DIR/$bin" 2>/dev/null || true
  done
  local dirs; dirs=$(ls -d "$OPT_DIR"/node-v* 2>/dev/null | sort -V)
  local count; count=$(echo "$dirs" | wc -l | tr -d ' ')
  [ "$count" -gt 1 ] && rm -rf "$(echo "$dirs" | head -1)"
  rm -f "$tarball"
  ok "node    → ${latest_ver}"
}

# ── Tool: fzf ─────────────────────────────────────────────────────
TOOL_FZF_REPO="junegunn/fzf"
check_fzf() {
  local current latest
  current=$(cmd_exists fzf && fzf --version | awk '{print $1}' || echo "not-installed")
  latest=$(latest_gh_release "$TOOL_FZF_REPO" | sed 's/^v//')
  [ "$current" = "$latest" ] && { ok "fzf     ${current}"; return 0; } \
                            || { warn "fzf     ${current} → ${latest}"; return 1; }
}
update_fzf() {
  local tag; tag=$(latest_gh_release "$TOOL_FZF_REPO")
  log "Downloading fzf ${tag}..."
  gh release download "$tag" -R "$TOOL_FZF_REPO" -p "fzf-*-darwin_arm64.tar.gz" --clobber
  local archive; archive=$(ls fzf-*-darwin_arm64.tar.gz 2>/dev/null | head -1)
  [ -z "$archive" ] && { fail "fzf archive not found"; return 1; }
  tar xzf "$archive" -C "$TOOLS_DIR" fzf
  rm -f "$archive"
  ok "fzf     → ${tag#v}"
}

# ── Tool: ripgrep ────────────────────────────────────────────────
TOOL_RG_REPO="BurntSushi/ripgrep"
check_rg() {
  local current latest
  current=$(cmd_exists rg && rg --version | head -1 | awk '{print $2}' || echo "not-installed")
  latest=$(latest_gh_release "$TOOL_RG_REPO")
  [ "$current" = "$latest" ] && { ok "rg      ${current}"; return 0; } \
                            || { warn "rg      ${current} → ${latest}"; return 1; }
}
update_rg() {
  local ver; ver=$(latest_gh_release "$TOOL_RG_REPO")
  local archive="ripgrep-${ver}-aarch64-apple-darwin.tar.gz"
  log "Downloading ripgrep ${ver}..."
  gh release download "${ver}" -R "$TOOL_RG_REPO" -p "$archive" --clobber
  tar xzf "$archive" -C /tmp
  cp "/tmp/ripgrep-${ver}-aarch64-apple-darwin/rg" "$TOOLS_DIR/rg"
  rm -f "$archive"
  rm -rf "/tmp/ripgrep-${ver}-aarch64-apple-darwin"
  ok "rg      → ${ver}"
}

# ── Tool: starship ───────────────────────────────────────────────
TOOL_STARSHIP_REPO="starship/starship"
check_starship() {
  local current latest
  current=$(cmd_exists starship && starship --version | head -1 | awk '{print $2}' || echo "not-installed")
  latest=$(latest_gh_release "$TOOL_STARSHIP_REPO" | sed 's/^v//')
  [ "$current" = "$latest" ] && { ok "starship ${current}"; return 0; } \
                            || { warn "starship ${current} → ${latest}"; return 1; }
}
update_starship() {
  local ver; ver=$(latest_gh_release "$TOOL_STARSHIP_REPO" | sed 's/^v//')
  curl -fsSL "https://starship.rs/install.sh" | sh -s -- -y -b "$TOOLS_DIR" 2>/dev/null
  ok "starship → ${ver}"
}

# ── Tool: zoxide ─────────────────────────────────────────────────
TOOL_ZOXIDE_REPO="ajeetdsouza/zoxide"
check_zoxide() {
  local current latest
  current=$(cmd_exists zoxide && zoxide --version | awk '{print $2}' || echo "not-installed")
  latest=$(latest_gh_release "$TOOL_ZOXIDE_REPO" | sed 's/^v//')
  [ "$current" = "$latest" ] && { ok "zoxide  ${current}"; return 0; } \
                            || { warn "zoxide  ${current} → ${latest}"; return 1; }
}
update_zoxide() {
  local ver; ver=$(latest_gh_release "$TOOL_ZOXIDE_REPO" | sed 's/^v//')
  local archive="zoxide-${ver}-aarch64-apple-darwin.tar.gz"
  gh release download "v${ver}" -R "$TOOL_ZOXIDE_REPO" -p "$archive" --clobber
  tar xzf "$archive" -C "$TOOLS_DIR"
  chmod +x "$TOOLS_DIR/zoxide"
  rm -f "$archive"
  ok "zoxide  → ${ver}"
}

# ── Tool: bat ────────────────────────────────────────────────────
TOOL_BAT_REPO="sharkdp/bat"
check_bat() {
  local current latest
  current=$(cmd_exists bat && bat --version | head -1 | awk '{print $2}' || echo "not-installed")
  latest=$(latest_gh_release "$TOOL_BAT_REPO" | sed 's/^v//')
  [ "$current" = "$latest" ] && { ok "bat     ${current}"; return 0; } \
                            || { warn "bat     ${current} → ${latest}"; return 1; }
}
update_bat() {
  local ver; ver=$(latest_gh_release "$TOOL_BAT_REPO" | sed 's/^v//')
  local archive="bat-v${ver}-aarch64-apple-darwin.tar.gz"
  gh release download "v${ver}" -R "$TOOL_BAT_REPO" -p "$archive" --clobber
  tar xzf "$archive" -C /tmp
  cp "/tmp/bat-v${ver}-aarch64-apple-darwin/bat" "$TOOLS_DIR/bat"
  rm -f "$archive"
  rm -rf "/tmp/bat-v${ver}-aarch64-apple-darwin"
  ok "bat     → ${ver}"
}

# ── Tool: lsd ────────────────────────────────────────────────────
TOOL_LSD_REPO="lsd-rs/lsd"
check_lsd() {
  local current latest
  current=$(cmd_exists lsd && lsd --version | head -1 | awk '{print $2}' || echo "not-installed")
  latest=$(latest_gh_release "$TOOL_LSD_REPO" | sed 's/^v//')
  [ "$current" = "$latest" ] && { ok "lsd     ${current}"; return 0; } \
                            || { warn "lsd     ${current} → ${latest}"; return 1; }
}
update_lsd() {
  local ver; ver=$(latest_gh_release "$TOOL_LSD_REPO" | sed 's/^v//')
  local archive="lsd-${ver}-aarch64-apple-darwin.tar.gz"
  gh release download "v${ver}" -R "$TOOL_LSD_REPO" -p "$archive" --clobber
  tar xzf "$archive" -C /tmp
  cp "/tmp/lsd-${ver}-aarch64-apple-darwin/lsd" "$TOOLS_DIR/lsd"
  rm -f "$archive"
  rm -rf "/tmp/lsd-${ver}-aarch64-apple-darwin"
  ok "lsd     → ${ver}"
}

# ── Tool: lazygit ────────────────────────────────────────────────
TOOL_LAZYGIT_REPO="jesseduffield/lazygit"
check_lazygit() {
  local current latest
  current=$(cmd_exists lazygit && lazygit --version | head -1 | sed 's/.*version=\([^ ]*\).*/\1/' || echo "not-installed")
  latest=$(latest_gh_release "$TOOL_LAZYGIT_REPO" | sed 's/^v//')
  [ "$current" = "$latest" ] && { ok "lazygit ${current}"; return 0; } \
                            || { warn "lazygit ${current} → ${latest}"; return 1; }
}
update_lazygit() {
  local ver; ver=$(latest_gh_release "$TOOL_LAZYGIT_REPO" | sed 's/^v//')
  local archive="lazygit_${ver}_Darwin_arm64.tar.gz"
  gh release download "v${ver}" -R "$TOOL_LAZYGIT_REPO" -p "$archive" --clobber
  tar xzf "$archive" -C "$TOOLS_DIR" lazygit
  rm -f "$archive"
  ok "lazygit → ${ver}"
}

# ── Tool: Homebrew ───────────────────────────────────────────────
check_homebrew() {
  if cmd_exists brew; then
    local outdated; outdated=$(brew outdated 2>/dev/null | wc -l | tr -d ' ')
    [ "$outdated" -eq 0 ] && { ok "brew    up-to-date"; return 0; } \
                          || { warn "brew    ${outdated} outdated"; return 1; }
  else
    warn "brew   not-installed"; return 1
  fi
}
update_homebrew() {
  brew update --quiet 2>/dev/null
  brew upgrade --quiet 2>/dev/null
  brew upgrade --cask --quiet 2>/dev/null
  brew cleanup --quiet 2>/dev/null
  ok "brew   updated & cleaned"
}

# ── Tool: npm global packages ────────────────────────────────────
check_npm_global() {
  if cmd_exists npm; then
    local outdated; outdated=$(npm outdated -g 2>/dev/null | wc -l | tr -d ' ')
    [ "$outdated" -eq 0 ] && { ok "npm     up-to-date"; return 0; } \
                          || { warn "npm     ${outdated} outdated"; return 1; }
  else
    warn "npm    not-installed"; return 1
  fi
}
update_npm_global() {
  npm update -g 2>/dev/null
  ok "npm    updated"
}

# ── Tool: pip ────────────────────────────────────────────────────
check_pip() {
  if cmd_exists pip3; then
    pip3 list --outdated 2>/dev/null | tail -n +3 | head -1 | grep -q . \
      && { warn "pip    has outdated pkgs"; return 1; } \
      || { ok "pip    up-to-date"; return 0; }
  else
    warn "pip    not-installed"; return 1
  fi
}
update_pip() {
  pip3 install --upgrade pip setuptools wheel 2>/dev/null
  pip3 list --outdated 2>/dev/null | tail -n +3 | awk '{print $1}' | while read -r pkg; do
    pip3 install --upgrade "$pkg" 2>/dev/null || true
  done
  ok "pip    updated"
}

# ── Tool: gh ─────────────────────────────────────────────────────
check_gh() {
  local current latest
  current=$(cmd_exists gh && gh version 2>/dev/null | head -1 | awk '{print $3}' | sed 's/^v//' || echo "not-installed")
  latest=$(latest_gh_release "cli/cli" | sed 's/^v//')
  [ "$current" = "$latest" ] && { ok "gh      ${current}"; return 0; } \
                            || { warn "gh      ${current} → ${latest}"; return 1; }
}
update_gh() {
  local ver; ver=$(latest_gh_release "cli/cli" | sed 's/^v//')
  local archive="gh_${ver}_macOS_arm64.tar.gz"
  gh release download "v${ver}" -R "cli/cli" -p "$archive" --clobber
  tar xzf "$archive" -C /tmp
  cp "/tmp/gh_${ver}_macOS_arm64/bin/gh" "$TOOLS_DIR/gh"
  rm -f "$archive"
  rm -rf "/tmp/gh_${ver}_macOS_arm64"
  ok "gh      → ${ver}"
}

# ── Orchestration ───────────────────────────────────────────────
ALL_TOOLS=("nvim" "node" "fzf" "rg" "starship" "zoxide" "bat" "lsd" "lazygit" "gh" "homebrew" "npm_global" "pip")

check_all() {
  header "Tool Status"
  local exit_code=0
  for tool in "${ALL_TOOLS[@]}"; do
    "check_${tool}" || exit_code=1
  done
  return $exit_code
}

update_all() {
  header "Updating Tools"
  for tool in "${ALL_TOOLS[@]}"; set +e; do
    if ! "check_${tool}" &>/dev/null; then
      "update_${tool}"
    fi
  done; set -e
  header "Update Complete"
}

update_single() {
  local tool="$1"
  if "check_${tool}" &>/dev/null; then
    ok "${tool} already up-to-date"
  else
    "update_${tool}"
  fi
}

# ── Main ────────────────────────────────────────────────────────
if $SINGLE_MODE; then
  update_single "$UPDATE_TARGET"
elif $DO_UPDATE; then
  update_all
else
  check_all
fi
