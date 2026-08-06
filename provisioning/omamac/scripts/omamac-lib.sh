#!/bin/bash
# omamac-lib.sh — shared helpers for plugin and module shell scripts.
# Source with: source "${OMAMAC_LIB:-$(dirname "$0")/lib/omamac-lib.sh}"
# The CLI exports these variables for plugins:
#   OMAMAC_ACTION, OMAMAC_PLUGIN_NAME, OMAMAC_PLUGIN_DIR,
#   OMAMAC_CONFIG_DIR, OMAMAC_DATA_DIR, OMAMAC_STATE_DIR, OMAMAC_HOME,
#   OMAMAC_DRY_RUN, OMAMAC_JSON, OMAMAC_VERBOSE

log() { printf '\033[1;34m▸\033[0m %s\n' "$*"; }
ok()  { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn(){ printf '\033[1;33m⚠\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

# is_dry_run reports whether omamac is previewing rather than executing.
is_dry_run() { [ "${OMAMAC_DRY_RUN:-0}" = "1" ]; }

# run executes a command, respecting dry-run.
run() {
  if is_dry_run; then
    log "[dry-run] $*"
    return 0
  fi
  "$@"
}

# brew_install idempotently installs formulae/casks.
brew_install() {
  local pkg="$1"; shift
  if is_dry_run; then
    log "[dry-run] brew install $pkg $*"
    return 0
  fi
  if brew list "$pkg" >/dev/null 2>&1; then
    log "$pkg already installed"
    return 0
  fi
  brew install "$@" "$pkg"
}

# append_if_missing adds a line to a file if not already present.
append_if_missing() {
  local file="$1" line="$2"
  [ -f "$file" ] || touch "$file"
  grep -qxF "$line" "$file" || printf '%s\n' "$line" >> "$file"
}

# link_dotfile symlinks a managed file into the home directory.
link_dotfile() {
  local src="$1" dst="$2"
  if is_dry_run; then
    log "[dry-run] ln -s $src -> $dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    warn "$dst exists and is not a symlink; leaving as-is"
    return 0
  fi
  ln -sfn "$src" "$dst"
}
