#!/bin/bash

set -e

REPO_NAME="mac-catalyst"
VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The canonical Brewfile lives in provisioning/ (one level up from sync/).
BREWFILE="$SCRIPT_DIR/../Brewfile"

DRY_RUN=false
VERBOSE=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              Mac Catalyst - Export Current Setup              ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

usage() {
    echo -e "${PURPLE}Usage:${NC} $(basename "$0") [OPTIONS]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  -n, --dry-run       Show what would be exported without writing"
    echo "  -v, --verbose       Enable verbose output"
    echo "  -h, --help          Show this help message"
    echo ""
}

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_dry_run() { echo -e "${PURPLE}[DRY RUN]${NC} $1"; }

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--dry-run) DRY_RUN=true; shift ;;
            -v|--verbose) VERBOSE=true; shift ;;
            -h|--help) usage; exit 0 ;;
            *) echo -e "${RED}Unknown option: $1${NC}"; usage; exit 1 ;;
        esac
    done
}

export_brewfile() {
    echo ""
    log_info "Exporting current Homebrew setup..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would run: brew bundle dump --file=$BREWFILE --force"
        brew bundle dump --file=- | head -20
        echo "..."
        return
    fi
    
    brew bundle dump --file="$BREWFILE" --force
    log_success "Brewfile exported to: $BREWFILE"
}

show_summary() {
    FORMULAE_COUNT=$(grep '^brew "' "$BREWFILE" 2>/dev/null | wc -l | tr -d ' ')
    CASKS_COUNT=$(grep '^cask "' "$BREWFILE" 2>/dev/null | wc -l | tr -d ' ')
    VSCODE_COUNT=$(grep '^vscode "' "$BREWFILE" 2>/dev/null | wc -l | tr -d ' ')
    
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                      EXPORT SUMMARY                           ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    printf "${CYAN}║${NC}  ${YELLOW}%-20s${NC} ${GREEN}%3d packages${NC}                        ${CYAN}║${NC}\n" "CLI Tools" "$FORMULAE_COUNT"
    printf "${CYAN}║${NC}  ${YELLOW}%-20s${NC} ${GREEN}%3d applications${NC}                     ${CYAN}║${NC}\n" "GUI Apps" "$CASKS_COUNT"
    printf "${CYAN}║${NC}  ${YELLOW}%-20s${NC} ${GREEN}%3d extensions${NC}                      ${CYAN}║${NC}\n" "VS Code" "$VSCODE_COUNT"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  git add Brewfile"
    echo "  git commit -m \"Update Brewfile: $(date +%Y-%m-%d)\""
    echo "  git push"
    echo ""
}

main() {
    parse_args "$@"
    print_banner
    export_brewfile
    [[ "$DRY_RUN" != true ]] && show_summary
}

main "$@"
