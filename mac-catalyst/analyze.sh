#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Analyzing Brewfile...${NC}"
echo ""

FORMULAE=$(grep '^brew "' "$BREWFILE" | sed 's/brew "//;s/"$//' | sort)
CASKS=$(grep '^cask "' "$BREWFILE" | sed 's/cask "//;s/"$//' | sort)
VSCODE=$(grep '^vscode "' "$BREWFILE" | sed 's/vscode "//;s/"$//' | sort)

FORMULAE_COUNT=$(echo "$FORMULAE" | grep -c .)
CASKS_COUNT=$(echo "$CASKS" | grep -c .)
VSCODE_COUNT=$(echo "$VSCODE" | grep -c .)

echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║                         BREWFILE ANALYSIS                            ║${NC}"
echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════════════╣${NC}"

echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC}  ${GREEN}CLI TOOLS (Formulae) - ${FORMULAE_COUNT} packages${NC}"
echo -e "${YELLOW}║${NC}  ${BLUE}────────────────────────────────────${NC}"
echo "$FORMULAE" | while read -r pkg; do
    printf "${YELLOW}║${NC}    ${GREEN}●${NC} %-60s ${YELLOW}║${NC}\n" "$pkg"
done

echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC}  ${GREEN}GUI APPLICATIONS (Casks) - ${CASKS_COUNT} apps${NC}"
echo -e "${YELLOW}║${NC}  ${BLUE}────────────────────────────────────${NC}"
echo "$CASKS" | while read -r cask; do
    printf "${YELLOW}║${NC}    ${GREEN}●${NC} %-60s ${YELLOW}║${NC}\n" "$cask"
done

echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
echo -e "${YELLOW}║${NC}  ${GREEN}VS CODE EXTENSIONS - ${VSCODE_COUNT} extensions${NC}"
echo -e "${YELLOW}║${NC}  ${BLUE}────────────────────────────────────${NC}"
echo "$VSCODE" | while read -r ext; do
    printf "${YELLOW}║${NC}    ${GREEN}●${NC} %-60s ${YELLOW}║${NC}\n" "$ext"
done

echo -e "${YELLOW}║${NC}                                                                      ${YELLOW}║${NC}"
echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════════════╣${NC}"
printf "${YELLOW}║${NC}  ${CYAN}Total Items: %4d${NC}                                                 ${YELLOW}║${NC}\n" "$((FORMULAE_COUNT + CASKS_COUNT + VSCODE_COUNT))"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════╝${NC}"
