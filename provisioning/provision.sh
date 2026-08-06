#!/usr/bin/env bash
#
# provision.sh — WowMacDev unified provisioning CLI.
#
# Merges the functionality of five upstream repos into one command:
#   omamac          → declarative, reversible, verifiable setup engine (Go)
#   mac-bootstrap   → one-shot fresh-Mac bootstrap (Brewfile + configs)
#   mac-catalyst    → Brewfile install/export/analyze/diff workflow
#   mac-app-sync    → cross-machine app/config backup & restore
#   mac-dev-setup   → Forward Deployment Engineer toolchain guide
#
# Usage:
#   ./provision.sh bootstrap          One-shot fresh-Mac setup (everything)
#   ./provision.sh install            Install packages from Brewfile
#   ./provision.sh export             Dump current brew setup → Brewfile
#   ./provision.sh analyze            Summarize the Brewfile
#   ./provision.sh diff               Compare installed vs Brewfile
#   ./provision.sh apps export        Export all app/config manifests (mac-app-sync)
#   ./provision.sh apps install       Install apps from exported manifests
#   ./provision.sh apps sync          Export + push manifests to GitHub
#   ./provision.sh apps list          List exported item counts
#   ./provision.sh omamac <args...>   Delegate to the omamac Go engine
#   ./provision.sh help               Show this help

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
ok()  { printf "${GREEN}✓${NC} %s\n" "$1"; }
info(){ printf "${BLUE}→${NC} %s\n" "$1"; }
warn(){ printf "${YELLOW}▲${NC} %s\n" "$1"; }
fail(){ printf "${RED}✗${NC} %s\n" "$1"; }
header(){ printf "\n${BOLD}══ %s ══${NC}\n" "$1"; }

usage() {
    awk '/^# Usage:/{flag=1} flag && /^#   .*help/{print; exit} flag' "$0" | sed 's/^# \{0,1\}//'
}

ensure_brew() {
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ "$(uname -m)" = "arm64" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
}

cmd_bootstrap() {
    bash "$REPO_DIR/bootstrap.sh"
}

cmd_install() {
    ensure_brew
    info "Installing packages from Brewfile..."
    if ! brew bundle install --file="$REPO_DIR/Brewfile"; then
        warn "Some packages failed. Review the output above."
    fi
    ok "Brewfile installation complete"
}

cmd_export() {
    ensure_brew
    info "Exporting current Homebrew setup to Brewfile..."
    brew bundle dump --file="$REPO_DIR/Brewfile" --force
    ok "Brewfile exported"
}

cmd_analyze() {
    bash "$REPO_DIR/sync/analyze.sh"
}

cmd_diff() {
    bash "$REPO_DIR/sync/diff.sh"
}

cmd_apps() {
    local sub="${1:-help}"
    case "$sub" in
        export) bash "$REPO_DIR/sync/export_apps.sh" ;;
        install) bash "$REPO_DIR/sync/install_apps.sh" ;;
        sync)
            if ! command -v gh &>/dev/null; then
                fail "GitHub CLI (gh) not installed. Run: brew install gh"
                exit 1
            fi
            bash "$REPO_DIR/sync/export_apps.sh"
            (cd "$REPO_DIR" && git add -A && git commit -m "Sync app list $(date +'%Y-%m-%d %H:%M')" || true)
            git push origin "$(git -C "$REPO_DIR" symbolic-ref --short HEAD)" 2>/dev/null || \
                git -C "$REPO_DIR" push -u origin main
            ok "Sync complete"
            ;;
        list)
            # Reuse mac-app-sync's summary by sourcing its counters inline.
            local EXPORT_DIR="$REPO_DIR/sync/exports"
            echo "========================================"
            echo "  Exported Items"
            echo "========================================"
            for spec in "homebrew_formulas.txt:Homebrew Formulae" \
                        "homebrew_casks.txt:Homebrew Casks" \
                        "app_store_apps.txt:App Store Apps" \
                        "npm_packages.txt:npm Packages" \
                        "pip_packages.txt:pip Packages" \
                        "pipx_packages.txt:pipx Packages" \
                        "gem_packages.txt:Ruby Gems" \
                        "vscode_extensions.txt:VS Code Extensions"; do
                file="${spec%%:*}"; name="${spec##*:}"
                if [ -f "$EXPORT_DIR/$file" ]; then
                    count=$(grep -v '^#' "$EXPORT_DIR/$file" 2>/dev/null | grep -v '^$' | wc -l | tr -d ' ')
                else
                    count=0
                fi
                printf "  %-25s %4s items\n" "$name:" "$count"
            done
            ;;
        help) usage ;;
        *) fail "Unknown apps subcommand: $sub"; usage; exit 1 ;;
    esac
}

cmd_omamac() {
    local bin="$REPO_DIR/omamac/bin/omamac"
    if [ ! -x "$bin" ]; then
        info "Building omamac..."
        (cd "$REPO_DIR/omamac" && make build >/dev/null)
    fi
    "$bin" "$@"
}

main() {
    local cmd="${1:-help}"
    shift || true
    case "$cmd" in
        bootstrap) cmd_bootstrap ;;
        install) cmd_install ;;
        export) cmd_export ;;
        analyze) cmd_analyze ;;
        diff) cmd_diff ;;
        apps) cmd_apps "$@" ;;
        omamac) cmd_omamac "$@" ;;
        help|-h|--help) usage ;;
        *) fail "Unknown command: $cmd"; usage; exit 1 ;;
    esac
}

main "$@"
