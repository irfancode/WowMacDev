# ═══════════════════════════════════════════════════════════
# .profile — POSIX/sh login profile (WowMacDev)
# Sourced by bash/zsh login shells for cross-shell env vars.
# ═══════════════════════════════════════════════════════════

# Homebrew (Apple Silicon)
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Local binaries
case ":$PATH:" in
    *:"$HOME/.local/bin":*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":$PATH:" in
    *:"$HOME/go/bin":*) ;;
    *) export PATH="$HOME/go/bin:$PATH" ;;
esac
case ":$PATH:" in
    *:"$HOME/.cargo/bin":*) ;;
    *) export PATH="$HOME/.cargo/bin:$PATH" ;;
esac

# Editor
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"

# Kiro CLI profile hooks (kept for tooling integration)
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/profile.pre.bash" ]] \
    && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/profile.pre.bash"
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/profile.post.bash" ]] \
    && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/profile.post.bash"
