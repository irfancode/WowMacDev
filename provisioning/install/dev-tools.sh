#!/usr/bin/env bash
set -euo pipefail

TOOLS_DIR="$HOME/.local/bin"
OPT_DIR="$HOME/.local/opt"
mkdir -p "$TOOLS_DIR" "$OPT_DIR"

echo "==> Installing standalone CLI tools..."

install_gh_release() {
  local repo="$1" pattern="$2" binary="$3"
  local tag ver f
  tag=$(gh release view -R "$repo" --json tagName --jq .tagName 2>/dev/null) || return
  ver=$(echo "$tag" | sed 's/^v//')
  echo "    Installing $binary v$ver ..."
  local work
  work=$(mktemp -d)
  # Download into a work dir keeping the ORIGINAL asset filename so we can
  # detect tar.gz vs zip from the actual file, not from gh's output text.
  gh release download "$tag" -R "$repo" -p "$pattern" --clobber --dir "$work" 2>/dev/null || {
    rm -rf "$work"
    echo "    WARNING: could not download $binary ($pattern); skipping"
    return 0
  }
  # Capture the actual downloaded asset name; gh keeps the original filename.
  f=$(find "$work" -maxdepth 1 -type f -print -quit)
  if [ -z "$f" ]; then
    rm -rf "$work"
    echo "    WARNING: no archive found for $binary; skipping"
    return 0
  fi
  case "$f" in
    *.tar.gz|*.tgz)
      tar xzf "$f" -C "$work"
      ;;
    *.zip)
      unzip -qo "$f" -d "$work"
      ;;
    *)
      rm -rf "$work"
      echo "    WARNING: unknown archive type for $binary ($f); skipping"
      return 0
      ;;
  esac
  # Locate the binary anywhere in the extracted tree.
  if [ -f "$work/$binary" ]; then
    cp "$work/$binary" "$TOOLS_DIR/$binary"
  else
    find "$work" -name "$binary" -type f -exec cp {} "$TOOLS_DIR/$binary" \; 2>/dev/null || true
  fi
  chmod +x "$TOOLS_DIR/$binary"
  rm -rf "$work"
}

# Neovim
if ! command -v nvim &>/dev/null; then
  echo "    Installing Neovim..."
  latest=$(gh release view neovim/neovim --json tagName --jq .tagName | sed 's/^v//')
  gh release download "v$latest" -R neovim/neovim -p "nvim-macos-arm64.tar.gz" --clobber -O /tmp/nvim.tar.gz
  tar xzf /tmp/nvim.tar.gz -C "$OPT_DIR"
  ln -sf "$OPT_DIR/nvim-macos-arm64/bin/nvim" "$TOOLS_DIR/nvim"
  rm /tmp/nvim.tar.gz
fi

# Node.js
if ! command -v node &>/dev/null; then
  echo "    Installing Node.js..."
  latest=$(gh release list -R nodejs/node -L 50 2>/dev/null | grep -v 'rc\|beta\|nightly' | grep '^v22' | head -1 | awk '{print $1}' | sed 's/^v//' || true)
  [ -z "$latest" ] && latest=$(gh release list -R nodejs/node -L 50 2>/dev/null | grep -v 'rc\|beta\|nightly' | head -1 | awk '{print $1}' | sed 's/^v//' || true)
  if [ -z "$latest" ]; then
    echo "    WARNING: could not determine latest Node version; skipping"
  else
    curl -fsSL "https://nodejs.org/dist/v${latest}/node-v${latest}-darwin-arm64.tar.gz" -o /tmp/node.tar.gz
    tar xzf /tmp/node.tar.gz -C "$OPT_DIR"
    ln -sf "$OPT_DIR/node-v${latest}-darwin-arm64/bin/node" "$TOOLS_DIR/node"
    ln -sf "$OPT_DIR/node-v${latest}-darwin-arm64/bin/npm" "$TOOLS_DIR/npm"
    ln -sf "$OPT_DIR/node-v${latest}-darwin-arm64/bin/npx" "$TOOLS_DIR/npx"
    rm /tmp/node.tar.gz
  fi
fi

# Go
if ! command -v go &>/dev/null; then
  echo "    Installing Go..."
  # golang/go has no "latest" GitHub release (404), so resolve the newest
  # STABLE tag (excludes rc/beta/nightly) from the remote tag list.
  latest=$(git ls-remote --tags --refs https://github.com/golang/go 'go1.*' \
    2>/dev/null | awk -F/ '{print $3}' | grep -E '^go[0-9]+\.[0-9]+\.[0-9]+$' \
    | sort -V | tail -1 | sed 's/^go//')
  if [ -z "$latest" ]; then
    echo "    WARNING: could not determine latest Go version; skipping"
  else
    echo "    Installing Go v${latest} (darwin-arm64)..."
    curl -fsSL "https://go.dev/dl/go${latest}.darwin-arm64.tar.gz" -o /tmp/go.tar.gz
    tar xzf /tmp/go.tar.gz -C "$OPT_DIR"
    mv "$OPT_DIR/go" "$OPT_DIR/go${latest}" 2>/dev/null || true
    ln -sf "$OPT_DIR/go${latest}/bin/go" "$TOOLS_DIR/go"
    ln -sf "$OPT_DIR/go${latest}/bin/gofmt" "$TOOLS_DIR/gofmt"
    rm /tmp/go.tar.gz
  fi
fi

# fzf
install_gh_release "junegunn/fzf" "fzf-*-darwin_arm64.tar.gz" "fzf"

# ripgrep
install_gh_release "BurntSushi/ripgrep" "ripgrep-*-aarch64-apple-darwin.tar.gz" "rg"

# bat
install_gh_release "sharkdp/bat" "bat-*-aarch64-apple-darwin.tar.gz" "bat"

# lsd
install_gh_release "lsd-rs/lsd" "lsd-*-aarch64-apple-darwin.tar.gz" "lsd"

# lazygit
install_gh_release "jesseduffield/lazygit" "lazygit_*_Darwin_arm64.tar.gz" "lazygit"

# zoxide
install_gh_release "ajeetdsouza/zoxide" "zoxide-*-aarch64-apple-darwin.tar.gz" "zoxide"

# starship
install_gh_release "starship/starship" "starship-*-aarch64-apple-darwin.tar.gz" "starship"

# GitHub CLI (gh) - usually via brew, but fallback
if ! command -v gh &>/dev/null; then
  install_gh_release "cli/cli" "gh_*_macOS_arm64.tar.gz" "gh"
fi

# Rust (via rustup)
if ! command -v rustc &>/dev/null; then
  echo "    Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

echo "==> Dev tools installed"

# Ensure PATH
export PATH="$TOOLS_DIR:$PATH"
hash -r
