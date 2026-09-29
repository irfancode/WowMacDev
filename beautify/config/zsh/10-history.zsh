# ═══════════════════════════════════════════════════════════
#  10-history.zsh — history + completion system
# ═══════════════════════════════════════════════════════════

# ── History ───────────────────────────────────────────────
HISTFILE="$XDG_DATA_HOME/zsh/history"
mkdir -p "${HISTFILE:h}" 2>/dev/null
HISTSIZE=50000
SAVEHIST=50000

setopt SHARE_HISTORY          # live history across concurrent sessions
setopt INC_APPEND_HISTORY     # append as you type, not on Enter
setopt HIST_IGNORE_ALL_DUPS   # drop the earlier duplicate, keep the recent one
setopt HIST_IGNORE_SPACE      # a leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS     # drop trailing whitespace before saving
setopt HIST_VERIFY            # don't run a history-expanded line blind
setopt HIST_FCNTL_LOCK        # append immediately, not on the next prompt

# Keep ~/.zsh_history for muscle memory / older tooling
[[ -f ~/.zsh_history && ! -f $HISTFILE ]] && mv ~/.zsh_history $HISTFILE

# ── Completion ────────────────────────────────────────────
# zcompdump lives in XDG_CACHE_HOME and is rebuilt at most once a
# day, keeping startup fast.
autoload -Uz compinit
mkdir -p "$XDG_CACHE_HOME/zsh" 2>/dev/null
_zcompdump="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"
if [[ -r $_zcompdump(#+mtime+1) ]]; then
  zcompdump -q -d "$_zcompdump"
else
  compinit -d "$_zcompdump"
fi
unset _zcompdump
zmodload -i zsh/complist     # menu completion + case-insensitive expansion

setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt COMPLETE_ALIASES
unsetopt MENU_COMPLETE       # keep the menu usable rather than instant
unsetopt CORRECT_ALL         # CORRECT is fine; CORRECT_ALL rewrites too much
unsetopt BEEP

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %d'

# Group ordering: statics first, then the noisy groups.
zstyle ':completion:*' group-order '' \
  'parameters' 'commands' 'options' 'files' 'aliases'

# Case-insensitive completion for Git hosts/branches and paths.
zstyle ':completion:*:*:git-checkout:*' sort false
zstyle ':completion:*:*:git-*:*' group-name ''
zstyle ':completion:*:(ssh|scp|rsync):*' group-name ''
