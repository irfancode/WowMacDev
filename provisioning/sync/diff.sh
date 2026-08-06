#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$(dirname "$SCRIPT_DIR")/Brewfile"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Comparing installed packages with Brewfile...${NC}"
echo ""

INSTALLED_FORMULAE=$(brew list --formula 2>/dev/null | sort)
INSTALLED_CASKS=$(brew list --cask 2>/dev/null | sort)
INSTALLED_VSCODE=$(code --list-extensions 2>/dev/null | sort)

BREWFILE_FORMULAE=$(grep '^brew "' "$BREWFILE" | sed 's/brew "//;s/"$//' | sort)
BREWFILE_CASKS=$(grep '^cask "' "$BREWFILE" | sed 's/cask "//;s/"$//' | sort)
BREWFILE_VSCODE=$(grep '^vscode "' "$BREWFILE" | sed 's/vscode "//;s/"$//' | sort)

MISSING_FORMULAE=$(comm -23 <(echo "$BREWFILE_FORMULAE") <(echo "$INSTALLED_FORMULAE"))
MISSING_CASKS=$(comm -23 <(echo "$BREWFILE_CASKS") <(echo "$INSTALLED_CASKS"))
MISSING_VSCODE=$(comm -23 <(echo "$BREWFILE_VSCODE") <(echo "$INSTALLED_VSCODE"))

EXTRA_FORMULAE=$(comm -13 <(echo "$BREWFILE_FORMULAE") <(echo "$INSTALLED_FORMULAE"))
EXTRA_CASKS=$(comm -13 <(echo "$BREWFILE_CASKS") <(echo "$INSTALLED_CASKS"))
EXTRA_VSCODE=$(comm -13 <(echo "$BREWFILE_VSCODE") <(echo "$INSTALLED_VSCODE"))

echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  MISSING FROM SYSTEM (in Brewfile but not installed)${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"

if [[ -n "$MISSING_FORMULAE" ]]; then
    echo -e "${BLUE}Formulae:${NC}"
    echo "$MISSING_FORMULAE" | while read -r pkg; do [[ -n "$pkg" ]] && echo "  - $pkg"; done
fi

if [[ -n "$MISSING_CASKS" ]]; then
    echo -e "${BLUE}Casks:${NC}"
    echo "$MISSING_CASKS" | while read -r cask; do [[ -n "$cask" ]] && echo "  - $cask"; done
fi

if [[ -n "$MISSING_VSCODE" ]]; then
    echo -e "${BLUE}VS Code Extensions:${NC}"
    echo "$MISSING_VSCODE" | while read -r ext; do [[ -n "$ext" ]] && echo "  - $ext"; done
fi

if [[ -z "$MISSING_FORMULAE" && -z "$MISSING_CASKS" && -z "$MISSING_VSCODE" ]]; then
    echo -e "${GREEN}All packages from Brewfile are installed!${NC}"
fi

echo ""
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  EXTRA ON SYSTEM (installed but not in Brewfile)${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"

if [[ -n "$EXTRA_FORMULAE" ]]; then
    echo -e "${BLUE}Formulae:${NC}"
    echo "$EXTRA_FORMULAE" | while read -r pkg; do [[ -n "$pkg" ]] && echo "  + $pkg"; done
fi

if [[ -n "$EXTRA_CASKS" ]]; then
    echo -e "${BLUE}Casks:${NC}"
    echo "$EXTRA_CASKS" | while read -r cask; do [[ -n "$cask" ]] && echo "  + $cask"; done
fi

if [[ -n "$EXTRA_VSCODE" ]]; then
    echo -e "${BLUE}VS Code Extensions:${NC}"
    echo "$EXTRA_VSCODE" | while read -r ext; do [[ -n "$ext" ]] && echo "  + $ext"; done
fi

if [[ -z "$EXTRA_FORMULAE" && -z "$EXTRA_CASKS" && -z "$EXTRA_VSCODE" ]]; then
    echo -e "${GREEN}No extra packages installed!${NC}"
fi

echo ""
