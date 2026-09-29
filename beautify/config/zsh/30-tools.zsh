# ═══════════════════════════════════════════════════════════
#  30-tools.zsh — modern CLI replacements
# ═══════════════════════════════════════════════════════════
#  Every alias here is `command`-guarded, so the config still loads
#  on a machine that does not have the tool installed.
#
#  Two aliases from the old config were deliberately REMOVED:
#
#   alias cat='bat --style=numbers,changes --wrap=never'
#     --wrap=never does not wrap long lines, it makes them
#     unreachable: reading a minified JSON blob or a wide log line
#     silently truncates the content you asked to see. And because
#     a shell alias also expands on the command word, the very
#     common `cat > out.txt <<'EOF' ... EOF` would have run bat
#     with line numbers into the redirect and corrupted the file.
#     Use `bf` (below) or plain `cat` instead.
#
#   alias rg='rg --color=always ...'
#     --color=always forces ANSI escapes regardless of whether
#     stdout is a TTY, so `rg pattern | wc -l` counted escape
#     sequences. `--color=auto` below only colours a terminal.
# ═══════════════════════════════════════════════════════════

have() { (( ${+commands[$1]} )) }

# ── eza (ls) ──────────────────────────────────────────────
# NOTE: no --icons on the plain `ls` alias. Icons change column
# width, so `ls | wc -l` and any script reading `ls` output stops
# working. Icon-rich views are opt-in via `lsai` / `lt`.
if have eza; then
  alias ls='eza --group-directories-first'
  alias l='eza -F --group-directories-first'
  alias la='eza -la --group-directories-first --time-style=long-iso'
  alias ll='eza -lh --group-directories-first --git --time-style=long-iso'
  alias lla='eza -lah --group-directories-first --git --time-style=long-iso'
  alias lsai='eza -la --icons --group-directories-first'
  alias lt='eza --tree --level=2 --icons'
  alias lta='eza --tree --level=3 --icons --all'
  alias lt2='eza --tree --level=2 --icons --all'
  alias ltz='eza --tree --level=3 --icons --all --ignore-glob "node_modules|.git|.venv|target|dist|build"'
  alias lsblk='eza -l --oneline --classify'   # classify: dir/exe/socket
  alias lso='eza -l --sort=modified'          # newest first
  # Biggest things in the current directory, depth 1.
  alias lsb='eza -lah --sort=size | head -20'
fi

# ── bat (cat / less for source) ───────────────────────────
if have bat; then
  alias bf='bat'                              # plain, safe
  alias bfn='bat --style=numbers'             # with line numbers
  alias bfh='bat --language=help'             # colour a --help page
  alias bfl='bat --language=json'             # colour JSON
  alias bfy='bat --language=yaml'             # colour YAML
  alias bft='bat --language=typescript'       # colour TS/JS
  # Strip ANSI when piping, so `bat file | grep` stays matchable.
  alias batp='bat --paging=never --color=never'
fi

# ── fd / ripgrep ──────────────────────────────────────────
if have fd; then
  # --follow dropped: it follows symlinks, which can loop forever
  # inside a tree that contains a cycle. Opt in per-invocation.
  alias fd='fd --hidden'
  alias fdf='fd --type f'
  alias fdd='fd --type d'
  alias fdl='fd --type l'
fi

if have rg; then
  alias rg='rg --color=auto'                  # NOT --color=always
  alias rgi='rg --color=auto --ignore-case'
  alias rgw='rg --color=auto --word-regexp'
  alias rgl='rg --color=auto --files-with-matches'
  alias rgn='rg --color=auto --files-without-match'
  # "What uses this symbol?" — the single most useful rg wrapper.
  alias rgo='rg --color=auto --hidden --glob "!.git" -C 3'
fi

# ── delta (git diff) ──────────────────────────────────────
if have delta; then
  alias diff='delta --diff-so-fancy'
  alias diffo='delta --diff-so-fancy --diff-line-numbers'
fi

# ── Navigation ────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

# ── System ────────────────────────────────────────────────
alias c='clear'
alias h='history'
alias jc='jobs -l'                 # jobs with PIDs
alias ports='lsof -nP -iTCP -sTCP:LISTEN'
alias ip='curl -s https://ipinfo.io/ip'   # public IP, one request
alias localip="ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null"
alias path='print -l $path'        # PATH, one entry per line, readable

# ── Disk / size ───────────────────────────────────────────
alias du='dust -d 1'               # faster, prettier du
alias df='duf'                     # human-friendly df

# ── Misc quality-of-life ──────────────────────────────────
alias cls='clear'
alias reload='exec zsh -l'          # restart the login shell
alias zc='zoxide'
alias g='git'
alias clsx='clear; printf "\033[3J\033[H\033[2J"'

# Watch a command, aliasing the result — `wa -n1 'date +%s'`
if command -v watch >/dev/null 2>&1 || have watch; then
  alias wa='watch -n'
fi
