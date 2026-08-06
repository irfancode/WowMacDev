# ═══════════════════════════════════════════════════════════
# .zprofile — Zsh login shell environment (WowMacDev)
# Loaded once per login: PATH, brew, toolchain env vars.
# Interactive shell features live in .zshrc.
# ═══════════════════════════════════════════════════════════

# ── Homebrew ──────────────────────────────────────────────
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# ── OrbStack (containers / VMs) ───────────────────────────
[ -f "$HOME/.orbstack/shell/init.zsh" ] && source "$HOME/.orbstack/shell/init.zsh"

# ── Local bin dirs ────────────────────────────────────────
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ]        && export PATH="$HOME/bin:$PATH"
[ -d "$HOME/go/bin" ]     && export PATH="$HOME/go/bin:$PATH"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
[ -d "$HOME/.krew/bin" ]  && export PATH="$HOME/.krew/bin:$PATH"

# ── macOS MySQL client (brew keg-only) ────────────────────
[ -d "/opt/homebrew/opt/mysql-client/bin" ] && export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
[ -d "/opt/homebrew/opt/sqlite/bin" ]       && export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
[ -d "/opt/homebrew/opt/openjdk/bin" ]      && export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# ── Editor / pager defaults ───────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'

# ── XDG Base Directory ────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# ── Locale ────────────────────────────────────────────────
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# ── Java (SDKMAN) ─────────────────────────────────────────
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# ── Rust (rustup) ─────────────────────────────────────────
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
