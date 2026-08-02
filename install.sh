#!/bin/bash
# omamac bootstrap — transforms a fresh macOS into a configured dev workstation.
#
# Usage:
#   curl -fsSL https://omamac.dev/install.sh | bash
#   # or, for a local checkout / development:
#   bash install.sh
#
# Behavior:
#   1. Detects macOS and architecture (Apple Silicon preferred, Intel supported).
#   2. Installs Xcode Command Line Tools if missing.
#   3. Installs Homebrew if missing.
#   4. Installs the omamac binary (release binary > local build > brew tap).
#   5. Runs `omamac install --yes` to apply your configuration.
set -euo pipefail

OMAMAC_VERSION="${OMAMAC_VERSION:-latest}"
OMAMAC_REPO="${OMAMAC_REPO:-omamac/omamac}"
OMAMAC_TAP="${OMAMAC_TAP:-omamac/homebrew-tap}"
BIN_DIR="${OMAMAC_BIN_DIR:-$HOME/.local/bin}"

log()  { printf '\033[1;34m▸\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

# Detect the source of this script: a local checkout wins (for development).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_CHECKOUT=0
if [ -f "$SCRIPT_DIR/go.mod" ] && [ -d "$SCRIPT_DIR/cmd/omamac" ]; then
  LOCAL_CHECKOUT=1
fi

# --------------------------------------------------------------------------
# 1. Platform checks
# --------------------------------------------------------------------------
if [ "$(uname -s)" != "Darwin" ]; then
  die "omamac only supports macOS (this is $(uname -s))."
fi

ARCH="$(uname -m)"
case "$ARCH" in
  arm64) GOARCH=arm64 ;;
  x86_64) GOARCH=amd64 ;;
  *) die "Unsupported architecture: $ARCH" ;;
esac

OSVER="$(sw_vers -productVersion)"
log "macOS $OSVER ($ARCH)"

# --------------------------------------------------------------------------
# 2. Xcode Command Line Tools
# --------------------------------------------------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (follow the system prompt)..."
  xcode-select --install
  until xcode-select -p >/dev/null 2>&1; do
    sleep 3
  done
fi
ok "Xcode Command Line Tools present"

# --------------------------------------------------------------------------
# 3. Homebrew
# --------------------------------------------------------------------------
if command -v brew >/dev/null 2>&1; then
  ok "Homebrew present ($(brew --prefix))"
else
  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  case "$ARCH" in
    arm64) eval "$(/opt/homebrew/bin/brew shellenv)" ;;
    *) eval "$(/usr/local/bin/brew shellenv)" ;;
  esac
  ok "Homebrew installed"
fi

# --------------------------------------------------------------------------
# 4. Install the omamac binary
# --------------------------------------------------------------------------
install_binary_release() {
  log "Downloading omamac $OMAMAC_VERSION ($GOARCH)..."
  local url
  if [ "$OMAMAC_VERSION" = "latest" ]; then
    url="https://github.com/${OMAMAC_REPO}/releases/latest/download/omamac_${GOARCH}_darwin_${GOARCH}.tar.gz"
  else
    url="https://github.com/${OMAMAC_REPO}/releases/download/v${OMAMAC_VERSION}/omamac_${OMAMAC_VERSION}_darwin_${GOARCH}.tar.gz"
  fi
  # Try the actual release asset naming scheme, falling back to the common one.
  local tmp
  tmp="$(mktemp -d)"
  if ! curl -fsSL "$url" -o "$tmp/omamac.tar.gz"; then
    url="https://github.com/${OMAMAC_REPO}/releases/download/v${OMAMAC_VERSION}/omamac_${GOARCH}_darwin_${GOARCH}.tar.gz"
    curl -fsSL "$url" -o "$tmp/omamac.tar.gz"
  fi
  mkdir -p "$BIN_DIR"
  tar -xzf "$tmp/omamac.tar.gz" -C "$tmp"
  install -m 0755 "$tmp/omamac" "$BIN_DIR/omamac"
  rm -rf "$tmp"
}

if [ "$LOCAL_CHECKOUT" = "1" ]; then
  log "Building omamac from the local checkout..."
  (cd "$SCRIPT_DIR" && make build)
  mkdir -p "$BIN_DIR"
  install -m 0755 "$SCRIPT_DIR/bin/omamac" "$BIN_DIR/omamac"
  ok "omamac installed from local checkout"
elif command -v omamac >/dev/null 2>&1; then
  ok "omamac already installed ($(command -v omamac))"
elif [ -n "${OMAMAC_TAP:-}" ] && command -v brew >/dev/null 2>&1; then
  log "Installing omamac from Homebrew tap ${OMAMAC_TAP}..."
  brew tap "${OMAMAC_TAP}" || true
  brew install omamac || {
    log "Tap install failed; falling back to release binary."
    install_binary_release
  }
else
  install_binary_release
fi

# Ensure ~/.local/bin is on PATH for this and future shells.
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) log "Adding $BIN_DIR to PATH for this session." ;;
esac
export PATH="$BIN_DIR:$PATH"

ok "omamac ready"

# --------------------------------------------------------------------------
# 5. Apply configuration
# --------------------------------------------------------------------------
log "Running: omamac install --yes"
if command -v omamac >/dev/null 2>&1; then
  omamac install --yes
else
  die "omamac binary not found after install."
fi

ok "Done. Welcome to your configured Mac."
