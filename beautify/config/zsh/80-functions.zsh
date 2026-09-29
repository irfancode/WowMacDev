# ═══════════════════════════════════════════════════════════
#  80-functions.zsh — general helpers
# ═══════════════════════════════════════════════════════════

# ── Environment overview ──────────────────────────────────
# The single command that answers "where am I and what am I
# pointed at?" without any network calls beyond a cached read.
env-show() {
  print "── machine"
  print "  host    : $(hostname -s 2>/dev/null)${SSH_CONNECTION:+  (SSH session)}"
  print "  os      : $(sw_vers -productName 2>/dev/null) $(sw_vers -productVersion 2>/dev/null) ($(uname -m))"
  print "  shell   : ${SHELL##*/} $(zsh --version 2>/dev/null | awk '{print $2}')"
  print "  uptime  : $(uptime | sed 's/^ *//')"
  print "  dir     : $PWD"

  print "\n── git"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local br
    br=$(git branch --show-current 2>/dev/null)
    print "  repo    : $(git rev-parse --show-toplevel 2>/dev/null)"
    print "  branch  : ${br:-<detached>}"
    print "  changes : $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') file(s)"
  else
    print "  not a git repository"
  fi

  print "\n── kubernetes"
  if (( $+commands[kubectl] )); then
    local ctx
    ctx=$(kubectl config current-context 2>/dev/null)
    if [[ -n $ctx ]]; then
      if k8s_is_prod 2>/dev/null; then
        print -r -- "  context : $ctx  %F{red}⚠ PRODUCTION%f"
      else
        print "  context : $ctx"
      fi
    else
      print "  no context set"
    fi
  else
    print "  kubectl not installed"
  fi

  print "\n── cloud"
  cloud-env-report 2>/dev/null || print "  no cloud context"

  print "\n── runtimes"
  (( $+commands[python3] )) && print "  python  : $(python3 --version 2>/dev/null | awk '{print $2}')"
  (( $+commands[node] ))    && print "  node    : $(node --version 2>/dev/null)"
  (( $+commands[go] ))       && print "  go      : $(go version 2>/dev/null | awk '{print $3}')"
  (( $+commands[cargo] ))    && print "  rust    : $(cargo --version 2>/dev/null | awk '{print $2}')"
  if (( $+commands[java] )); then
    # macOS ships a `java` stub that errors out when no JDK is
    # installed, so only report a version that actually parsed.
    local jv=$(java -version 2>&1 | head -1)
    [[ $jv == *'"'* ]] && print "  java    : ${${(s:\" :)jv}[2]}"
  fi
  (( $+commands[terraform] )) && print "  tf      : $(terraform version 2>/dev/null | head -1 | awk '{print $2}' | tr -d 'v')"
  [[ -n $VIRTUAL_ENV ]] && print "  venv    : ${VIRTUAL_ENV:t}"
  [[ -n $AWS_PROFILE ]] && print "  profile : $AWS_PROFILE"
}

# ── Where did that command come from? ──────────────────────
which-all() {
  if (( $# == 0 )); then
    print -u2 "usage: which-all <command>"
    return 1
  fi
  local c
  for c in "$@"; do
    print "── $c"
    whence -a "$c" 2>/dev/null || print "  (not found)"
  done
}

# ── Extract an archive, choosing the right tool ────────────
unpack() {
  (( $# )) || { print -u2 "usage: unpack <archive>"; return 1 }
  local f=$1
  case $f in
    *.tar.gz|*.tgz)  tar -xzf  "$f" ;;
    *.tar.bz2|*.tbz2) tar -xjf  "$f" ;;
    *.tar.xz|*.txz)  tar -xJf  "$f" ;;
    *.tar.zst)       tar --zstd -xf "$f" ;;
    *.tar)           tar -xf   "$f" ;;
    *.zip)           unzip     "$f" ;;
    *.7z)            7z x      "$f" ;;
    *.rar)           unrar x   "$f" ;;
    *.gz)            gunzip    "$f" ;;
    *.bz2)           bunzip2   "$f" ;;
    *.xz)            unxz      "$f" ;;
    *)               print -u2 "unpack: unknown archive type: $f"; return 1 ;;
  esac
}

# ── Create a file and open it in $EDITOR ───────────────────
e() {
  (( $# )) || { print -u2 "usage: e <file>"; return 1 }
  (( -e $1 )) || { mkdir -p "${1:h}"; : > "$1" }
  ${EDITOR:-nvim} "$1"
}

# ── Pretty JSON / YAML ────────────────────────────────────
pj() { (( $+commands[jq] )) && jq . || { print -u2 "jq not installed"; return 1 }; }
py() { (( $+commands[yq] )) && yq . || { print -u2 "yq not installed"; return 1 }; }

# ── A quick HTTP check, with sane defaults ─────────────────
# `hget example.com/health` — curl defaults, highlighted body,
# timing in the footer.
hget() {
  (( $# )) || { print -u2 "usage: hget <url> [curl args...]"; return 1 }
  local url=$1
  # Default to https, and upgrade an explicit http:// to https://.
  # Anything that already carries a scheme is left alone.
  if [[ $url != *://* ]]; then
    url="https://$url"
  elif [[ $url == http://* ]]; then
    url="https://${url#http://}"
  fi
  local -a url_and_args
  url_and_args=( "$url" "${@:2}" )

  local tmp=$(mktemp)
  local -i code
  code=$(curl -sSL --max-time 30 -o "$tmp" -w '%{http_code}' "${url_and_args[@]}") || {
    rm -f "$tmp"
    print -u2 "request failed"
    return 1
  }

  # Colour by class, so 2xx/3xx read green, 4xx yellow, 5xx red.
  local -i r=$(( code / 100 ))
  local colour=green
  (( r == 4 )) && colour=yellow
  (( r >= 5 )) && colour=red
  print -r -- "%F${colour}${code}%f  $(wc -c < "$tmp" | tr -d ' ')B  ${url_and_args[1]}"
  print
  bat --color=always --style=numbers "$tmp" 2>/dev/null || cat "$tmp"
  rm -f "$tmp"
}

# ── Ports, with the process that owns them ─────────────────
port() {
  (( $# )) || { lsof -nP -iTCP -sTCP:LISTEN; return }
  lsof -nP -iTCP:"$1" -sTCP:LISTEN
}

# ── What is using this port, and can I stop it? ───────────
killport() {
  (( $# )) || { print -u2 "usage: killport <port>"; return 1 }
  local -a pids
  pids=( ${(f)"$(lsof -ti tcp:"$1" 2>/dev/null)"} )
  (( ${#pids} )) || { print "nothing listening on port $1"; return 1 }
  print "port $1 held by pid(s): ${(j:, :)pids}"
  local reply
  print -n "Send SIGTERM? [y/N] "
  read -r reply
  [[ $reply == [yY] ]] || { print "Aborted."; return 1 }
  kill -TERM $pids 2>/dev/null
  print "sent SIGTERM to ${(j:, :)pids}"
}

# ── Machine summary (fastfetch if present) ─────────────────
sysinfo() {
  if have fastfetch; then
    fastfetch
  elif have neofetch; then
    neofetch
  else
    system_profiler SPHardwareDataType 2>/dev/null | head -20
  fi
}

# ── Aliases and functions, searchable ──────────────────────
# `afzf git` — find any alias or function matching a pattern.
afzf() {
  local q=${1:-}
  local -a entries
  entries=(
    ${(f)"$(alias)"}
    ${(f)"$(functions - 2>/dev/null)"}
  )
  print -l $entries | grep -iE "$q" 2>/dev/null | fzf --prompt='search> ' --header='aliases + functions'
}
