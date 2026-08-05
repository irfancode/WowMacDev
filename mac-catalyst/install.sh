#!/bin/bash

set -e

REPO_NAME="mac-catalyst"
VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

DRY_RUN=false
VERBOSE=false
SKIP_ROSETTA=false
SKIP_SHELL=false

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
    echo "║                                                               ║"
    echo "║   ███╗   ███╗ █████╗ ██████╗      ██████╗ █████╗ ███████╗    ║"
    echo "║   ████╗ ████║██╔══██╗██╔══██╗    ██╔════╝██╔══██╗██╔════╝    ║"
    echo "║   ██╔████╔██║███████║██████╔╝    ██║     ███████║███████╗    ║"
    echo "║   ██║╚██╔╝██║██╔══██║██╔══██╗    ██║     ██╔══██║╚════██║    ║"
    echo "║   ██║ ╚═╝ ██║██║  ██║██║  ██║    ╚██████╗██║  ██║███████║    ║"
    echo "║   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝╚═╝  ╚═╝╚══════╝    ║"
    echo "║                                                               ║"
    echo "║          macOS Environment Replication Tool v${VERSION}          ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

usage() {
    echo -e "${PURPLE}Usage:${NC} $(basename "$0") [OPTIONS]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  -n, --dry-run       Show what would be installed without making changes"
    echo "  -v, --verbose       Enable verbose output"
    echo "  --skip-rosetta      Skip Rosetta 2 installation (Apple Silicon)"
    echo "  --skip-shell        Skip shell configuration"
    echo "  -h, --help          Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $(basename "$0")              # Full installation"
    echo "  $(basename "$0") --dry-run    # Preview what would be installed"
    echo "  $(basename "$0") -nv          # Dry run with verbose output"
    echo ""
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_dry_run() {
    echo -e "${PURPLE}[DRY RUN]${NC} $1"
}

log_step() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --skip-rosetta)
                SKIP_ROSETTA=true
                shift
                ;;
            --skip-shell)
                SKIP_SHELL=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                usage
                exit 1
                ;;
        esac
    done
}

check_prerequisites() {
    log_step "Checking Prerequisites"
    
    ARCH=$(uname -m)
    log_info "Architecture: $ARCH"
    log_info "macOS Version: $(sw_vers -productVersion)"
    log_info "Shell: $SHELL"
    
    if [[ "$VERBOSE" == true ]]; then
        log_info "Script directory: $SCRIPT_DIR"
        log_info "Brewfile: $BREWFILE"
    fi
}

install_rosetta() {
    if [[ "$SKIP_ROSETTA" == true ]]; then
        log_info "Skipping Rosetta 2 (--skip-rosetta)"
        return
    fi
    
    if [[ "$(uname -m)" == "arm64" ]]; then
        if pgrep -q oahd; then
            log_success "Rosetta 2 already installed"
        else
            if [[ "$DRY_RUN" == true ]]; then
                log_dry_run "Would install Rosetta 2"
            else
                log_info "Installing Rosetta 2..."
                softwareupdate --install-rosetta --agree-to-license
                log_success "Rosetta 2 installed"
            fi
        fi
    else
        log_info "Intel Mac - Rosetta 2 not required"
    fi
}

install_homebrew() {
    if command -v brew &> /dev/null; then
        BREW_VERSION=$(brew --version | head -1)
        log_success "Homebrew already installed ($BREW_VERSION)"
        
        if [[ "$VERBOSE" == true ]]; then
            log_info "Homebrew prefix: $(brew --prefix)"
        fi
        return
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would install Homebrew"
        return
    fi
    
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    log_success "Homebrew installed"
}

update_homebrew() {
    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would update Homebrew"
        return
    fi
    
    log_info "Updating Homebrew..."
    brew update
    log_success "Homebrew updated"
}

parse_brewfile() {
    FORMULAE=$(grep '^brew "' "$BREWFILE" | sed 's/brew "//;s/"$//' | sort)
    CASKS=$(grep '^cask "' "$BREWFILE" | sed 's/cask "//;s/"$//' | sort)
    VSCODE=$(grep '^vscode "' "$BREWFILE" | sed 's/vscode "//;s/"$//' | sort)
    
    FORMULAE_COUNT=$(echo "$FORMULAE" | grep -c .)
    CASKS_COUNT=$(echo "$CASKS" | grep -c .)
    VSCODE_COUNT=$(echo "$VSCODE" | grep -c .)
}

show_installation_summary() {
    parse_brewfile
    
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    INSTALLATION SUMMARY                       ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}                                                               ${CYAN}║${NC}"
    printf "${CYAN}║${NC}  ${YELLOW}%-20s${NC} ${GREEN}%3d packages${NC}                        ${CYAN}║${NC}\n" "CLI Tools (Formulae)" "$FORMULAE_COUNT"
    printf "${CYAN}║${NC}  ${YELLOW}%-20s${NC} ${GREEN}%3d applications${NC}                     ${CYAN}║${NC}\n" "GUI Apps (Casks)" "$CASKS_COUNT"
    printf "${CYAN}║${NC}  ${YELLOW}%-20s${NC} ${GREEN}%3d extensions${NC}                      ${CYAN}║${NC}\n" "VS Code Extensions" "$VSCODE_COUNT"
    echo -e "${CYAN}║${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${BLUE}Total: $((FORMULAE_COUNT + CASKS_COUNT + VSCODE_COUNT)) items to install${NC}                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo ""
        echo -e "${PURPLE}This is a DRY RUN - no changes will be made${NC}"
    fi
}

show_detailed_list() {
    if [[ "$VERBOSE" != true ]]; then
        return
    fi
    
    parse_brewfile
    
    echo ""
    echo -e "${YELLOW}CLI Tools (Formulae):${NC}"
    echo "$FORMULAE" | while read -r pkg; do
        echo -e "  ${GREEN}✓${NC} $pkg"
    done
    
    echo ""
    echo -e "${YELLOW}GUI Applications (Casks):${NC}"
    echo "$CASKS" | while read -r cask; do
        echo -e "  ${GREEN}✓${NC} $cask"
    done
    
    echo ""
    echo -e "${YELLOW}VS Code Extensions (showing first 20):${NC}"
    echo "$VSCODE" | head -20 | while read -r ext; do
        echo -e "  ${GREEN}✓${NC} $ext"
    done
    if [[ $VSCODE_COUNT -gt 20 ]]; then
        echo -e "  ${BLUE}... and $((VSCODE_COUNT - 20)) more${NC}"
    fi
}

install_packages() {
    if [[ ! -f "$BREWFILE" ]]; then
        log_warning "Brewfile not found at $BREWFILE"
        exit 1
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would run: brew bundle install --file=$BREWFILE"
        show_detailed_list
        return
    fi
    
    log_info "Installing packages from Brewfile..."
    log_info "This may take a while..."
    
    if ! brew bundle install --file="$BREWFILE"; then
        log_warning "Some packages failed to install. Check the output above."
    fi
    
    log_success "Package installation complete"
}

configure_shell() {
    if [[ "$SKIP_SHELL" == true ]]; then
        log_info "Skipping shell configuration (--skip-shell)"
        return
    fi
    
    if ! command -v fish &> /dev/null; then
        log_warning "Fish shell not found, skipping configuration"
        return
    fi
    
    FISH_PATH="$(which fish)"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would add $FISH_PATH to /etc/shells"
        log_dry_run "Would prompt to set Fish as default shell"
        return
    fi
    
    if ! grep -q "$FISH_PATH" /etc/shells 2>/dev/null; then
        log_info "Adding Fish to /etc/shells..."
        echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
        log_success "Fish added to /etc/shells"
    fi
    
    echo ""
    echo -e "${YELLOW}Do you want to set Fish as your default shell? [y/N]:${NC}"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        chsh -s "$FISH_PATH"
        log_success "Default shell changed to Fish"
    fi
}

show_final_summary() {
    if [[ "$DRY_RUN" == true ]]; then
        echo ""
        echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
        echo -e "${PURPLE}  DRY RUN COMPLETE - No changes were made${NC}"
        echo -e "${PURPLE}  Run without --dry-run to perform actual installation${NC}"
        echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}"
        return
    fi
    
    INSTALLED_FORMULAE=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
    INSTALLED_CASKS=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
    INSTALLED_VSCODE=$(code --list-extensions 2>/dev/null | wc -l | tr -d ' ')
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                   INSTALLATION COMPLETE!                      ║${NC}"
    echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${NC}                                                               ${GREEN}║${NC}"
    printf "${GREEN}║${NC}  ${YELLOW}%-25s${GREEN} %3d installed${NC}                    ${GREEN}║${NC}\n" "Homebrew Formulae" "$INSTALLED_FORMULAE"
    printf "${GREEN}║${NC}  ${YELLOW}%-25s${GREEN} %3d installed${NC}                    ${GREEN}║${NC}\n" "Homebrew Casks" "$INSTALLED_CASKS"
    printf "${GREEN}║${NC}  ${YELLOW}%-25s${GREEN} %3d installed${NC}                    ${GREEN}║${NC}\n" "VS Code Extensions" "$INSTALLED_VSCODE"
    echo -e "${GREEN}║${NC}                                                               ${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    
    echo ""
    echo -e "${YELLOW}Post-installation steps:${NC}"
    echo "  1. Restart your terminal"
    echo "  2. Open apps once to grant necessary permissions"
    echo "  3. Sign in to apps that require accounts"
    echo "  4. Configure Git:"
    echo "     git config --global user.name \"Your Name\""
    echo "     git config --global user.email \"your@email.com\""
    echo "  5. Generate SSH keys if needed:"
    echo "     ssh-keygen -t ed25519 -C \"your@email.com\""
    echo ""
}

main() {
    parse_args "$@"
    print_banner
    check_prerequisites
    
    log_step "Rosetta 2 Setup"
    install_rosetta
    
    log_step "Homebrew Setup"
    install_homebrew
    update_homebrew
    
    show_installation_summary
    
    log_step "Package Installation"
    install_packages
    
    log_step "Shell Configuration"
    configure_shell
    
    show_final_summary
}

main "$@"
