#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

echo "Exporting current Homebrew setup to Brewfile..."

brew bundle dump --file="$BREWFILE" --force

echo ""
echo "Brewfile exported to: $BREWFILE"
echo ""
echo "Summary:"
echo "  - $(grep '^brew "' "$BREWFILE" | wc -l | tr -d ' ') formulae"
echo "  - $(grep '^cask "' "$BREWFILE" | wc -l | tr -d ' ') casks"
echo "  - $(grep '^vscode "' "$BREWFILE" | wc -l | tr -d ' ') VS Code extensions"
echo ""
echo "Run 'git commit -am \"Update Brewfile\"' to save changes."
