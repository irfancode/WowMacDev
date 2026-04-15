# ═══════════════════════════════════════════════════════════
# .zshrc - Zsh Configuration
# Ghostty + Zellij + Productivity Setup
# ═══════════════════════════════════════════════════════════

# ── Source Profile Files ────────────────────────────────────
# Source .profile for PATH additions
[ -f "$HOME/.profile" ] && . "$HOME/.profile"

# Source .zprofile (brew, orbstack)
[ -f "$HOME/.zprofile" ] && . "$HOME/.zprofile"

# ═══════════════════════════════════════════════════════════
# STARSHIP PROMPT
# Fast, cross-shell prompt with git/rust/node info
# ═══════════════════════════════════════════════════════════
eval "$(starship init zsh)"

# ═══════════════════════════════════════════════════════════
# ZOXIDE - Smarter cd
# Learns your directory habits for instant navigation
# ═══════════════════════════════════════════════════════════
eval "$(zoxide init zsh)"

# ── zoxide aliases ─────────────────────────────────────────
# 'z' is the main command - use partial directory names
# 'zi' for interactive selection with fzf
alias za='zoxide add'
alias zq='zoxide query'
alias zqi='zoxide query --interactive'

# ═══════════════════════════════════════════════════════════
# FZF - Fuzzy Finder Integration
# Ctrl+R: Search command history
# Ctrl+T: Search files
# Alt+C: cd into directory
# ═══════════════════════════════════════════════════════════
eval "$(fzf --zsh)"

# ── fzf colors and options ─────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --style=numbers --color=always {}"'
export FZF_CTRL_R_OPTS='--height 40% --layout=reverse --border --preview "echo {}" --preview-window hidden --bind "ctrl-y:execute-silent(echo {} | pbcopy)+abort"'

# ═══════════════════════════════════════════════════════════
# EZA - Modern ls replacement
# Better colors, git status, icons, tree views
# ═══════════════════════════════════════════════════════════
alias ls='eza --icons'
alias la='eza -a --icons'
alias ll='eza -l --git'
alias lla='eza -la --git'
alias lt='eza --tree --level=2'
alias lta='eza -a --tree --level=3'
alias lt2='eza --tree --level=2'
alias lt3='eza --tree --level=3'

# ═══════════════════════════════════════════════════════════
# BAT - Modern cat replacement
# Syntax highlighting, git integration, line numbers
# ═══════════════════════════════════════════════════════════
alias cat='bat --style=numbers,changes --wrap=never'
alias catp='bat --plain'
alias cath='bat --language=help'

# ═══════════════════════════════════════════════════════════
# FD - Modern find replacement
# Faster, colorized, intuitive syntax
# ═══════════════════════════════════════════════════════════
alias fd='fd --hidden --follow'

# ═══════════════════════════════════════════════════════════
# RIPGREP - Modern grep replacement
# Faster, smarter defaults, colorized output
# ═══════════════════════════════════════════════════════════
alias rg='rg --color=always --line-number --no-heading --smart-case'
alias rgi='rg --ignore-case'
alias rgw='rg --word-regexp'

# ═══════════════════════════════════════════════════════════
# ZELLIJ - Terminal Multiplexer
# Modern Rust-based alternative to tmux
# ═══════════════════════════════════════════════════════════
alias zj='zellij'
alias zja='zellij attach'
alias zjl='zellij list-sessions'
alias zjk='zellij kill-session'

# ── Zellij auto-attach ─────────────────────────────────────
# Auto-attach to existing session if available
# zellij attach -c 2>/dev/null || true

# ═══════════════════════════════════════════════════════════
# LAZYGIT - Terminal UI for Git
# Full-featured git TUI - stage, commit, push, branches
# ═══════════════════════════════════════════════════════════
alias lg='lazygit'
alias lga='lazygit --git-dir=$HOME/dotfiles --work-tree=$HOME'

# ═══════════════════════════════════════════════════════════
# GHOSTTY - Quick Terminal
# Global hotkey: Ctrl+` (configured in Ghostty)
# ═══════════════════════════════════════════════════════════
alias ghostty-config='${EDITOR:-nvim} ~/.config/ghostty/config'

# ═══════════════════════════════════════════════════════════
# SYSTEM UTILITIES
# ═══════════════════════════════════════════════════════════
# Clear screen
alias c='clear'

# Show open ports
alias ports='lsof -i -P -n | grep LISTEN'

# Quick HTTP server
alias http='python3 -m http.server'

# Docker cleanup
alias docker-clean='docker system prune -af'

# ═══════════════════════════════════════════════════════════
# DEVELOPMENT ALIASES
# ═══════════════════════════════════════════════════════════
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# ── Node.js ────────────────────────────────────────────────
alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'

# ── Cargo/Rust ─────────────────────────────────────────────
alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo test'
alias cbh='cargo build --release'

# ═══════════════════════════════════════════════════════════
# PATH ADDITIONS
# ═══════════════════════════════════════════════════════════
# Local bin directories
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

# Go bin
[ -d "$HOME/go/bin" ] && export PATH="$HOME/go/bin:$PATH"

# Cargo bin
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

# ═══════════════════════════════════════════════════════════
# ZSH OPTIONS
# ═══════════════════════════════════════════════════════════
# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Auto-cd into directories
setopt AUTO_CD

# Correction
setopt CORRECT
setopt CORRECT_ALL

# Completion
setopt COMPLETE_IN_WORD
setopt GLOB_COMPLETE
setopt HIST_IGNORE_ALL_DUPS
setopt MENU_COMPLETE

# ═══════════════════════════════════════════════════════════
# COMPLETION SETTINGS
# ═══════════════════════════════════════════════════════════
# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Group completions
zstyle ':completion:*' verbose yes
zstyle ':completion:*' descriptions format '%B%d%b'
zstyle ':completion:*:matches' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'

# ═══════════════════════════════════════════════════════════
# KEY BINDINGS
# ═══════════════════════════════════════════════════════════
# Use vim keybindings
bindkey -v

# Fixbackspace in vim mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# ── Prompt jump (shell integration) ────────────────────────
# Ctrl+Shift+Up/Down to jump between prompts (Ghostty feature)
# These work with Ghostty shell integration

# ── Edit command in $EDITOR ────────────────────────────────
autoload -z edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

# ═══════════════════════════════════════════════════════════
# ENVIRONMENT VARIABLES
# ═══════════════════════════════════════════════════════════
# Editor
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

# Less options
export LESS='-R --tabs=4'
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[1;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'

# Bat options
export BAT_THEME='Catppuccin Mocha'

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ═══════════════════════════════════════════════════════════
# Plugins (if using a plugin manager)
# ═══════════════════════════════════════════════════════════
# Uncomment if using zsh plugins
# plugins=(git fzf zoxide docker npm node)

# ═══════════════════════════════════════════════════════════
# WELCOME MESSAGE
# ═══════════════════════════════════════════════════════════
# Uncomment to show a welcome message
# echo ""
# echo "  Ghostty + Zellij + Catppuccin Mocha"
# echo "  Type 'zj' for Zellij, 'lg' for Lazygit"
# echo "  Press Ctrl+\` for quick terminal (Ghostty)"
# echo ""
