# ═══════════════════════════════════════════════════════════
#  00-paths.zsh — PATH construction (single source of truth)
# ═══════════════════════════════════════════════════════════
#  Loaded first. Owns PATH completely so ordering is explicit and
#  duplicates cannot accumulate across login + interactive shells.
#
#  Why this file exists:
#  The previous .zshrc sourced .zprofile AND .profile (login-shell
#  files) from the interactive shell, and each of those appends
#  ~/.docker/bin to PATH. Result: ~/.docker/bin appeared 7x and
#  ~/.local/bin 3x, while /usr/local/bin sat ahead of
#  /opt/homebrew/bin and shadowed Homebrew's binaries.
#
#  `typeset -U path` makes the array unique on every assignment,
#  keeping the first occurrence — so order below is the real order.
# ═══════════════════════════════════════════════════════════

# `typeset -gU` is required, not `typeset -U`: this file is sourced
# from inside a loop in .zshrc, and a bare `typeset` there would make
# the uniqueness flag local to that source and discard it on return —
# which is exactly how PATH duplicates crept back in.
typeset -gU path PATH

path=(
  $HOME/.local/bin                # pipx, user scripts, mise-style bins
  $HOME/bin
  /opt/homebrew/bin               # Apple Silicon Homebrew  (authoritative)
  /usr/local/bin                  # Intel Homebrew / manual installs (fallback)
  $HOME/go/bin
  $HOME/.cargo/bin
  $HOME/.opencode/bin
  $HOME/.lmstudio/bin
  $HOME/.docker/bin               # Docker Desktop CLI
  $path                           # inherit the system default
)

# Drop entries that do not exist. Kept cheap: no subshell, pure zsh glob.
local -a _existing
_existing=()
local _p
for _p in $path; do
  [[ -d $_p ]] && _existing+=( $_p )
done
path=( ${_existing} )
unset _existing _p
