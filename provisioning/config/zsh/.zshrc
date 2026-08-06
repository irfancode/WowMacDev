# ═══════════════════════════════════════════════════════════
# .zshrc — Zsh interactive shell configuration (WowMacDev)
# A comprehensive developer terminal powerhouse.
# Works with starship + zoxide + fzf + eza + bat + zellij.
# ═══════════════════════════════════════════════════════════

# ── Source login profile (brew, PATH, SDKMAN) ─────────────
[ -f "$HOME/.zprofile" ] && . "$HOME/.zprofile"
[ -f "$HOME/.profile" ]  && . "$HOME/.profile" 2>/dev/null

# ── History ───────────────────────────────────────────────
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$HOME/.zsh_history"
HISTDUP=erase
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS INC_APPEND_HISTORY HIST_NO_STORE

# ── Shell behavior ─────────────────────────────────────────
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS COMPLETE_IN_WORD
setopt MENU_COMPLETE INTERACTIVE_COMMENTS
unsetopt BEEP

# ── Prompt: Starship ───────────────────────────────────────
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# ── Smart directory navigation: zoxide ─────────────────────
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# ── Completion system (before fzf bindings) ────────────────
autoload -Uz compinit
compinit -d "$HOME/.zcompdump"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' completer _complete _approximate _prefix
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh_cache"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format "%B%d%b"
zstyle ':completion:*:warnings' format "%bd%b"

# ── Zsh plugins: robust sourcing from BOTH locations ───────
# Plugins are installed by Homebrew (brew install) OR cloned by
# bootstrap.sh into ~/.local/share/zsh/plugins. Try both paths.
_zsh_plugin() {
    local name="$1" file="$2"
    local brew_base="/opt/homebrew/share"
    local git_base="$HOME/.local/share/zsh/plugins"
    for base in "$brew_base" "$git_base"; do
        if [ -f "$base/$file" ]; then
            source "$base/$file"
            return 0
        fi
    done
    return 1
}

_zsh_plugin zsh-autosuggestions zsh-autosuggestions/zsh-autosuggestions.zsh
_zsh_plugin zsh-syntax-highlighting zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Fzf integration ──────────────────────────────────────────
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh) 2>/dev/null || true
fi

# ═══════════════════════════════════════════════════════════
#  ALIASES
# ═══════════════════════════════════════════════════════════

# ── Modern replacements ────────────────────────────────────
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --group-directories-first'
alias la='eza -la --icons=auto --group-directories-first'
alias lla='eza -la --git --icons=auto'
alias lt='eza --tree --level=2 --icons=auto'
alias ltg='eza --tree --level=3 --group-directories-first --icons=auto'
alias cat='bat -p'
alias cate='bat --style=numbers,changes --wrap=never'
alias grep='rg'
alias findf='fd'
alias fd='fd --hidden --follow'
alias rgi='rg --ignore-case'
alias rgw='rg --word-regexp'

# ── Quick nav ──────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'
alias home='cd ~'
alias desk='cd ~/Desktop'
alias docs='cd ~/Documents'
alias down='cd ~/Downloads'
alias dev='cd ~/dev 2>/dev/null || cd ~/Developer 2>/dev/null || cd ~'
alias tmp='cd ~/Desktop && mkdir -p tmp && cd tmp'

# ── Editor ──────────────────────────────────────────────────
alias v='nvim'
alias vim='nvim'
alias nv='nvim'

# ── Safe file ops ───────────────────────────────────────────
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h -d 1'
alias cls='clear'
alias c='clear'

# ── Network & system ────────────────────────────────────────
alias path='echo -e "${PATH//:/\\n}"'
alias ports='lsof -i -P -n | grep LISTEN'
alias myip='curl -s ifconfig.me && echo'
alias myiplocal="ipconfig getifaddr en0 2>/dev/null || ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print \$2}'"
alias psa='ps aux'
alias psg='ps aux | rg -v rg | rg -i'
alias memtop='ps -eo pid,ppid,%mem,%cpu,comm --sort=-%mem | head -20'
alias cputop='ps -eo pid,ppid,%mem,%cpu,comm --sort=-%cpu | head -20'
alias clip='pbcopy'
alias copypath='pwd | pbcopy && echo "  Copied: $(pwd)"'
alias weather='curl -s "wttr.in/?format=%C+%t+%h+%w" && echo'
alias sniff='sudo tcpdump -i en0 -n'
alias dns='scutil --dns | rg "nameserver"'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo "  DNS flushed"'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
alias finder='open -a Finder ./'

# ── System info ─────────────────────────────────────────────
alias ff='fastfetch'
alias sysinfo='fastfetch'

# ── HTTP / API ──────────────────────────────────────────────
alias http='python3 -m http.server'
alias get='xh GET'
alias post='xh POST'

# ── Git shortcuts ───────────────────────────────────────────
alias g='git'
alias gs='git status'
alias gss='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gundo='git reset HEAD~1'
alias gstash='git stash push -m'
alias gstash-pop='git stash pop'
alias gpull='git pull --rebase'
alias glog='git log --stat'
alias glast='git log -1 --stat'
alias gclean='git branch --merged | rg -v "\*|main|master" | xargs -r git branch -d && echo "  cleaned merged branches"'

# ── Docker ──────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dclogs='docker compose logs -f'
alias dclean='docker system prune -af --volumes && echo "  Docker cleaned"'
alias dlf='docker logs -f'

# ── Kubernetes ──────────────────────────────────────────────
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias kgs='kubectl get services'
alias kgn='kubectl get nodes'
alias kl='kubectl logs -f'
alias kx='kubectl exec -it'
alias kctx='kubectl config current-context'
alias kstates='kubectl get statefulset'

# ── Terraform ───────────────────────────────────────────────
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tffm='terraform fmt -recursive'

# ── Helm ────────────────────────────────────────────────────
alias hls='helm list'

# ── Zellij (multiplexer) ────────────────────────────────────
alias zj='zellij'
alias zja='zellij attach'
alias zjl='zellij list-sessions'
alias zjk='zellij kill-session'
alias zjd='zellij delete-session'

# ── LazyGit ─────────────────────────────────────────────────
alias lg='lazygit'

# ── Node.js ─────────────────────────────────────────────────
alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrw='npm run watch'
alias npdev='pnpm dev'
alias npb='pnpm build'

# ── Rust / Cargo ─────────────────────────────────────────────
alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo test'
alias cbh='cargo build --release'
alias cw='cargo watch -x run'

# ── Go ───────────────────────────────────────────────────────
alias grun='go run'
alias gtest='go test ./...'
alias gbuild='go build ./...'
alias gfmt='go fmt ./...'

# ── Python ───────────────────────────────────────────────────
alias py='python3'
alias pi='pip install -r requirements.txt'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias act='source .venv/bin/activate'

# ── Java / Maven / Gradle ───────────────────────────────────
alias jv='java -version'
alias mvnci='mvn clean install -DskipTests'
alias mvnt='mvn clean test'
alias mvnp='mvn clean package -DskipTests'
alias mvns='mvn spring-boot:run'
alias gradlew='./gradlew'

# ═══════════════════════════════════════════════════════════
#  FZF SUPERCHARGED
# ═══════════════════════════════════════════════════════════
export FZF_DEFAULT_OPTS="
  --height 60% --layout=reverse --border --info=inline
  --prompt=' ❯ ' --pointer='❯' --marker='✓'
  --color='fg:#FCFCFA,bg:#2D2A2E,hl:#FC9867'
  --color='fg+:#FCFCFA,bg+:#403E41,hl+:#FF6188'
  --color='info:#AB9DF2,prompt:#A9DC76,pointer:#FC9867'
  --color='marker:#A9DC76,spinner:#FFD866,header:#78DCE8'
"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -p --color=always {} 2>/dev/null || eza -la {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden'

fbr() { local b; b=$(git branch --all | rg -v HEAD | fzf +m) && [ -n "$b" ] && git checkout "$(echo "$b" | sed 's/.* //;s#remotes/[^/]*/##')"; }
fgl() { git log --graph --color=always --format="%C(auto)%h%d %s %C(blue)%cr" | fzf --ansi --no-sort --reverse --tiebreak=index --preview "echo {} | rg -o '[a-f0-9]{7,}' | head -1 | xargs -I@ git show --stat @"; }
fkill() { local p; p=$(ps -eo pid,ppid,%cpu,%mem,comm -r | rg -v rg | fzf --preview 'echo {}' | awk '{print $1}') && [ -n "$p" ] && kill -9 "$p" && echo "  killed PID $p"; }
fv() { local f; f=$(fzf --multi --preview 'bat -p --color=always {} 2>/dev/null || eza --tree --level=2 {}') && [ -n "$f" ] && nvim "$f"; }
fzcd() { local d; d=$(fd --type d --hidden | fzf --height 40% --preview 'eza --tree --level=2 {}') && cd "$d"; }
fld() { find . -maxdepth 1 -iname "*$1*" 2>/dev/null; }
fps() { ps aux | rg -i "$1" | rg -v "rg -i $1"; }

# ═══════════════════════════════════════════════════════════
#  ENV VARS
# ═══════════════════════════════════════════════════════════
export PAGER='bat -p'
export LESS='-F -g -i -M -R -S -w -X -z-4'
export MANPAGER="sh -c 'col -b | bat -l man -p'"
export BAT_THEME="Catppuccin Mocha"
export GIT_PAGER='delta --dark'

# ── Language runtimes ─────────────────────────────────────────
[ -f /opt/homebrew/opt/nvm/nvm.sh ] && {
    export NVM_DIR="$HOME/.nvm"
    source /opt/homebrew/opt/nvm/nvm.sh
}
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in *":$PNPM_HOME:"*) ;; *) export PATH="$PNPM_HOME:$PATH" ;; esac

# ── Maven / Gradle JVM tuning ────────────────────────────────
export MAVEN_OPTS="-Xmx2g -XX:MaxMetaspaceSize=512m -Djava.awt.headless=true"
export GRADLE_OPTS="-Xmx2g -Dorg.gradle.daemon=true -Dorg.gradle.parallel=true"

# ═══════════════════════════════════════════════════════════
#  KEY BINDINGS
# ═══════════════════════════════════════════════════════════
# Vim-style editing in the command line.
bindkey -v
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# ═══════════════════════════════════════════════════════════
#  ZELLIJ AUTO-ATTACH (optional)
# ═══════════════════════════════════════════════════════════
# Uncomment to auto-attach to an existing session on new terminal.
# [[ $TERM_PROGRAM == "ghostty" && -z ${ZELLIJ+x} ]] && zellij attach -c "$(hostname -s)"

# ═══════════════════════════════════════════════════════════
#  MOTD / WELCOME
# ═══════════════════════════════════════════════════════════
if [ -z "$TMUX" ] && [ "$TERM_PROGRAM" != "vscode" ] && [ -z "$KITTY_WINDOW_ID" ]; then
    if command -v fastfetch >/dev/null 2>&1; then
        fastfetch 2>/dev/null
    fi
    echo ""
    echo "  ╭──────────────────────────────────────────────╮"
    echo "  │  ✅  Your Mac is ready!                      │"
    echo "  │                                              │"
    echo "  │  gs      → git status        ls  → eza       │"
    echo "  │  cat     → bat               cd  → zoxide    │"
    echo "  │  ctrl+t  → fzf files         ctrl+r → history│"
    echo "  │  zj      → zellij            lg  → lazygit   │"
    echo "  │  ff      → system info       k   → kubectl   │"
    echo "  │                                              │"
    echo "  │  https://github.com/irfancode/WowMacDev      │"
    echo "  ╰──────────────────────────────────────────────╯"
    echo ""
fi