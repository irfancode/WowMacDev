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
# Non-fatal: a single transient download/cask failure shouldn't abort the whole
# bootstrap. First a quiet run, then a verbose fallback; any residual failures
# are reported and bootstrapping continues so the rest of setup still runs.
if ! brew bundle install --file="$BREW_DIR/Brewfile" --quiet 2>/dev/null; then
  brew bundle install --file="$BREW_DIR/Brewfile" || {
    echo "→  WARNING: some Brewfile entries failed. See output above; bootstrap continues."
  }
fi

echo "==> Installing Mac App Store apps..."
if command -v mas &>/dev/null; then
  xargs mas install < "$BREW_DIR/install/mas-list.txt" 2>/dev/null || true
fi

echo "==> Installing cargo binaries..."
if command -v cargo &>/dev/null; then
  cargo install du-dust 2>/dev/null || true
fi

# npm global packages: intentionally none. corepack is skipped (its pnpm/pnpx
# shims collide with the Homebrew pnpm formula and break `brew link`); pnpm/yarn
# come from Homebrew formulae. See Brewfile notes for the full rationale.

echo "==> Brew install complete"
