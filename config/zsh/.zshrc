# ── Source Profile ────────────────────────────────────────────
[ -f "$HOME/.zprofile" ] && . "$HOME/.zprofile"

# ── Starship prompt ─────────────────────────────────────────
eval "$(/opt/homebrew/bin/starship init zsh)"

# ── Tools & Aliases ─────────────────────────────────────────
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --group-directories-first'
alias la='eza -la --icons=auto --group-directories-first'
alias ltree='eza -T --icons=auto --group-directories-first'
alias cat='bat -p'
alias grep='rg'
alias findf='fd'

eval "$(zoxide init zsh --cmd cd)"

source <(fzf --zsh)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Quick nav ───────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'
alias home='cd ~'
alias v='nvim'
alias vim='nvim'
alias tmp='cd ~/Desktop && mkdir -p tmp && cd tmp'
alias desk='cd ~/Desktop'
alias docs='cd ~/Documents'
alias down='cd ~/Downloads'

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias df='df -h'
alias cls='clear'
alias path='echo -e ${PATH//:/\\n}'
alias ports='lsof -i -P | grep LISTEN'
alias myip='curl -s ifconfig.me && echo'
alias myiplocal="ipconfig getifaddr en0 2>/dev/null || ifconfig | grep 'inet ' | grep -v 127.0.0.1 | awk '{print \$2}'"
alias psa='ps aux'
alias psg='ps aux | rg -v rg | rg -i'
alias memtop='ps -eo pid,ppid,%mem,%cpu,comm --sort=-%mem | head -20'
alias cputop='ps -eo pid,ppid,%mem,%cpu,comm --sort=-%cpu | head -20'
alias clip='pbcopy'
alias copypath='pwd | pbcopy && echo "  Copied: $(pwd)"'
alias weather='curl -s "wttr.in/Kolkata?format=%C+%t+%h+%w" && echo'
alias cheat='curl -s "cheat.sh/$@" || true'
alias sniff='sudo tcpdump -i en0 -n'
alias dns='scutil --dns | rg "nameserver"'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo "  DNS flushed"'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
alias finder='open -a Finder ./'
alias ff='fastfetch'
alias sysinfo='fastfetch'

# ── FZF Supercharged ────────────────────────────────────────
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
export FZF_CTRL_T_OPTS="--preview 'bat -p --color=always {} 2>/dev/null || ls -la {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza -T --icons=auto {} 2>/dev/null | head -30'"

fbr() { local b; b=$(git branch --all | rg -v HEAD | fzf +m) && [ -n "$b" ] && git checkout $(echo "$b" | sed "s/.* //" | sed "s#remotes/[^/]*/##"); }
fgl() { git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | fzf --ansi --no-sort --reverse --tiebreak=index --bind "ctrl-o:execute:git show \$(echo {} | rg -o '[a-f0-9]{7,}') | delta" --preview "echo {} | rg -o '[a-f0-9]{7,}' | xargs -I@ sh -c 'git show --stat @ | head -30'"; }
fkill() { local p; p=$(ps -eo pid,ppid,%cpu,%mem,comm -r | rg -v rg | fzf --preview 'echo {}' --preview-window=up:3:wrap | awk '{print $1}') && [ -n "$p" ] && kill -9 "$p" && echo "  Killed PID $p"; }
fv() { local f; f=$(fzf --multi --preview 'bat -p --color=always {} 2>/dev/null') && [ -n "$f" ] && nvim "$f"; }

# ── AI / LLM ────────────────────────────────────────────────
ask() {
  llama-cli -m "$HOME/models/qwen2.5-coder-3b-instruct-Q4_K_M.gguf" \
    --prompt "$*" --single-turn -n 400 -t 8 -ngl 99 \
    -c 8192 --flash-attn on -ctk q8_0 -ctv q8_0 \
    --temp 0.1 --no-display-prompt --no-show-timings 2>/dev/null | \
    awk '/^> /{found=1; sub(/^> /,""); print; next} found' | sed '/^Exiting/d'
}

# ── Git shortcuts ───────────────────────────────────────────
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gundo='git reset HEAD~1'
alias gstash='git stash push -m'
alias gstash-pop='git stash pop'
alias gclean='git branch --merged | rg -v "\*|main|master" | xargs -r git branch -d && echo "  Cleaned merged branches"'

# ── Docker shortcuts ────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dclogs='docker compose logs -f'
alias dclean='docker system prune -af --volumes && echo "  Docker cleaned"'

# ── Zsh Settings ────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt HIST_IGNORE_DUPS HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS COMPLETE_IN_WORD MENU_COMPLETE INTERACTIVE_COMMENTS

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' completer _complete _approximate _prefix
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh_cache

# ── Language runtimes ───────────────────────────────────────
[ -f /opt/homebrew/opt/nvm/nvm.sh ] && { export NVM_DIR="$HOME/.nvm"; source /opt/homebrew/opt/nvm/nvm.sh; }
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in *":$PNPM_HOME:"*) ;; *) export PATH="$PNPM_HOME:$PATH" ;; esac
export EDITOR='nvim'
export VISUAL='nvim'
export LESS='-F -g -i -M -R -S -w -X -z-4'
export LESSOPEN='| /opt/homebrew/bin/bat -p --color=always %s 2>/dev/null'
export MANPAGER="sh -c 'col -b | bat -l man -p'"
export PAGER='bat -p'

# ── Colored man pages ───────────────────────────────────────
man() {
  env LESS_TERMCAP_md=$(printf '\e[1;38;5;209m') \
      LESS_TERMCAP_me=$(printf '\e[0m') \
      LESS_TERMCAP_se=$(printf '\e[0m') \
      LESS_TERMCAP_so=$(printf '\e[1;40;92m') \
      LESS_TERMCAP_ue=$(printf '\e[0m') \
      LESS_TERMCAP_us=$(printf '\e[1;34m') \
    man "$@"
}

# ── Java Development ────────────────────────────────────────
alias java11='sdk use java 11.0.31-amzn'
alias java17='sdk use java 17.0.19-amzn'
alias java21='sdk use java 21.0.11-amzn'
alias jv='java -version'
alias mvnci='mvn clean install -DskipTests'
alias mvnt='mvn clean test'
alias mvnp='mvn clean package -DskipTests'
alias mvns='mvn spring-boot:run'
export MAVEN_OPTS="-Xmx2g -XX:MaxMetaspaceSize=512m -Djava.awt.headless=true"
export GRADLE_OPTS="-Xmx2g -Dorg.gradle.daemon=true -Dorg.gradle.parallel=true"

# ── SDKMAN (must be at end) ─────────────────────────────────
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# ── MySQL ───────────────────────────────────────────────────
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# ── Welcome message ─────────────────────────────────────────
[ -z "$TMUX" ] && [ "$TERM_PROGRAM" != "vscode" ] && [ -z "$KITTY_WINDOW_ID" ] && {
  fastfetch 2>/dev/null
  echo ""
  echo "  ╭────────────────────────────────────────────────╮"
  echo "  │  ✅  Your Mac is ready!                        │"
  echo "  │                                                │"
  echo "  │  Try these commands:                           │"
  echo "  │    gs     → check git status                   │"
  echo "  │    weather → today's forecast                  │"
  echo "  │    cheat git → Git help guide                  │"
  echo "  │    ff     → show system info                   │"
  echo "  │    cls    → clear screen                       │"
  echo "  │                                                │"
  echo "  │  Need help? Visit:                             │"
  echo "  │  https://github.com/irfancode/mac-bootstrap    │"
  echo "  ╰────────────────────────────────────────────────╯"
  echo ""
}
