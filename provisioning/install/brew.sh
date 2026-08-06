#!/usr/bin/env bash
set -euo pipefail

BREW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Installing Homebrew..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "    Homebrew already installed"
fi

echo "==> Installing formulae and casks..."
brew bundle install --file="$BREW_DIR/Brewfile" --no-lock --quiet 2>/dev/null || {
  brew bundle install --file="$BREW_DIR/Brewfile" --no-lock
}

echo "==> Installing Mac App Store apps..."
if command -v mas &>/dev/null; then
  xargs mas install < "$BREW_DIR/install/mas-list.txt" 2>/dev/null || true
fi

echo "==> Installing cargo binaries..."
if command -v cargo &>/dev/null; then
  cargo install du-dust 2>/dev/null || true
fi

echo "==> Installing npm global packages..."
if command -v npm &>/dev/null; then
  npm install -g corepack 2>/dev/null || true
fi

echo "==> Brew install complete"
