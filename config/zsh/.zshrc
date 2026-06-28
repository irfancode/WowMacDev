# .zshrc - Minimal Zsh Configuration
# Ghostty + Starship + Zoxide + FZF + Ripgrep

# ── Source Profile Files ────────────────────────────────────
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
[ -f "$HOME/.zprofile" ] && . "$HOME/.zprofile"

# ── PATH ────────────────────────────────────────────────────
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
[ -d "$HOME/go/bin" ] && export PATH="$HOME/go/bin:$PATH"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
# Homebrew keg-only tools
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
# Google Cloud SDK
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"

# ── STARSHIP PROMPT ─────────────────────────────────────────
eval "$(starship init zsh)"

# ── ZOXIDE - Smarter cd ────────────────────────────────────
eval "$(zoxide init zsh)"
alias za='zoxide add'
alias zq='zoxide query'
alias zqi='zoxide query --interactive'

# ── FZF - Fuzzy Finder ─────────────────────────────────────
export FZF_DEFAULT_COMMAND='find . -type f -not -path "./.git/*" 2>/dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='find . -type d -not -path "./.git/*" 2>/dev/null'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_R_OPTS='--height 40% --layout=reverse --border --preview "echo {}" --preview-window hidden --bind "ctrl-y:execute-silent(echo {} | pbcopy)+abort"'

[ -f ~/.fzf/shell/key-bindings.zsh ] && source ~/.fzf/shell/key-bindings.zsh
[ -f ~/.fzf/shell/completion.zsh ] && source ~/.fzf/shell/completion.zsh

# ── LSD (Modern ls with icons) ─────────────────────────────
alias ls='lsd'
alias ll='lsd -l'
alias lt='lsd --tree'
alias la='lsd -la'

# ── BAT (Modern cat) ────────────────────────────────────────
alias cat='bat'
alias catt='bat --style=plain'

# ── RIPGREP ────────────────────────────────────────────────
alias rg='rg --color=always --line-number --no-heading --smart-case'
alias rgi='rg --ignore-case'
alias rgw='rg --word-regexp'

# ── GIT ALIASES ────────────────────────────────────────────
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# ── SYSTEM UTILITIES ───────────────────────────────────────
alias c='clear'
alias ports='lsof -i -P -n | grep LISTEN'
alias http='python3 -m http.server'
alias ut='update-tools'
alias ut-update='update-tools --update'

# ── OPENCODE ──────────────────────────────────────────────
[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"
alias oc='opencode'

# ── DEVELOPMENT ALIASES ────────────────────────────────────
alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias cb='cargo build'
alias cr='cargo run'
alias lg='lazygit'

# ── CONTAINER ALIASES ─────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias di='docker images'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs -f'
alias kx='kubectx'
alias kn='kubens'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias k9='k9s'
alias h='helm'
alias hf='helmfile'

# ── INFRASTRUCTURE ────────────────────────────────────────
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfw='terraform workspace'
alias packer='packer'
alias ans='ansible'
alias asp='ansible-playbook'
alias op='op'  # 1Password CLI

# ── MONITORING ────────────────────────────────────────────
alias b='btop'
alias htop='sudo htop'  # runs with warning
alias gl='glances'
alias duf='duf'
alias dust='dust'

# ── ZSH OPTIONS ────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY
setopt AUTO_CD CORRECT

# ── COMPLETION ─────────────────────────────────────────────
# user-local completions (gh, starship, etc.)
fpath=( "$HOME/.local/share/zsh/site-functions" $fpath )
# Homebrew completions
fpath=( /opt/homebrew/share/zsh/site-functions $fpath )
# Google Cloud SDK completion
[ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ] && \
  source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*:matches' group-name ''
zstyle ':completion:*' use-cache on

# ── KEY BINDINGS ───────────────────────────────────────────
bindkey -v
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^e' edit-command-line

# ── ENVIRONMENT ────────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ── TOOL UPDATES ────────────────────────────────────────────
# daily check for tool updates (quiet, only once per day)
_irfan_daily_tool_check() {
  local stamp="$HOME/.local/state/tool-update-check"
  mkdir -p "$HOME/.local/state"
  if [ ! -f "$stamp" ] || [ "$(date +%j)" != "$(date -r "$stamp" +%j 2>/dev/null)" ]; then
    touch "$stamp"
    update-tools --quiet 2>/dev/null
  fi
}
# daily automatic check at shell start:
_irfan_daily_tool_check

# ── ZSH PLUGINS ────────────────────────────────────────────
[ -f "$HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
  && source "$HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
# syntax-highlighting must be sourced LAST
[ -f "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
  && source "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ── TERMINAL COLORS ─────────────────────────────────────────
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad


