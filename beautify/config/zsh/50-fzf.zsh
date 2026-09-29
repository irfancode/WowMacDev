# ═══════════════════════════════════════════════════════════
#  50-fzf.zsh — fuzzy finding
# ═══════════════════════════════════════════════════════════
#  Layered on top of the default keymap:
#    Ctrl+R  search shell history (and copy with Ctrl+Y)
#    Ctrl+T  find files under $PWD, preview with bat
#    Alt+C   jump to a directory
#  Extra:
#    Ctrl+Alt+T / Ctrl+Alt+R  find processes / hosts
# ═══════════════════════════════════════════════════════════

if ! have fzf; then
  return 0
fi

# Respect the palette from 05-exports.zsh.
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git --max-depth 4'
export FZF_TMUX=1
export FZF_CTRL_T_OVERWRITE_OPENER=''
export LESSHISTFILE=''

# Preview pane: bat when it exists, plain head otherwise.
if have bat; then
  export FZF_DEFAULT_PREVIEW='bat --color=always --style=numbers --line-range=:500 {}'
else
  export FZF_DEFAULT_PREVIEW='head -100 {}'
fi

# fzf >= 0.58 ships self-contained shell integration via `fzf --zsh`,
# which binds Ctrl+R / Ctrl+T / Alt+C and tab-completion in one go.
# Older builds need the two sourced files instead.
if ! source <(fzf --zsh) 2>/dev/null; then
  local _fzf_base="${commands[fzf]:h}"
  [[ -r $_fzf_base/../share/fzf/completion.zsh  ]] && source "$_fzf_base/../share/fzf/completion.zsh"
  [[ -r $_fzf_base/../share/fzf/key-bindings.zsh ]] && source "$_fzf_base/../share/fzf/key-bindings.zsh"
  unset _fzf_base
fi

# ── Process picker ────────────────────────────────────────
fkill() {
  local -a pids
  pids=(${(f)"$(ps -axo pid=,user=,comm= | grep -vE 'fzf|grep' | fzf --multi --prompt='kill> ' --header='select processes' --preview 'echo')"})
  [[ -z $pids ]] && return 0
  print -r -- "will terminate:"
  print -r -- $pids
  local -i i
  for i in {1..$#pids}; do
    # Strip the leading "pid user comm" fields down to just the pid.
    local pid="${${(s: :)pids[i]}[1]}"
    kill -TERM "$pid" 2>/dev/null || print -u2 "could not signal $pid"
  done
  print "sent SIGTERM (use kill -9 <pid> to force)"
}

# ── Docker container picker ───────────────────────────────
fcont() {
  (( $+commands[docker] )) || { print -u2 "docker not installed"; return 1 }
  local c
  c=$(docker ps -a --format '{{.ID}}  {{.Image}}  {{.Status}}  {{.Names}}' \
        | fzf --prompt='container> ' --header='docker ps -a') || return 1
  [[ -z $c ]] && return 1
  docker exec -it "${${(s:  :)c}[4]}" bash 2>/dev/null \
    || docker exec -it "${${(s:  :)c}[4]}" sh
}

# ── Kubernetes pod picker ─────────────────────────────────
fpod() {
  (( $+commands[kubectl] )) || { print -u2 "kubectl not installed"; return 1 }
  local p
  p=$(kubectl get pods -o wide 2>/dev/null | fzf --prompt='pod> ' \
        --preview 'kubectl describe {} 2>/dev/null | head -40' \
        --preview-window 'right:60%') || return 1
  [[ -z $p ]] && return 1
  print -r -- "$p"
}

# ── Kubernetes context switcher ───────────────────────────
fctx() {
  (( $+commands[kubectl] )) || { print -u2 "kubectl not installed"; return 1 }
  (( $+commands[kubectx] )) || { print -u2 "kubectx not installed"; return 1 }
  kubectx
}

# ── SSH host switcher ─────────────────────────────────────
fhost() {
  [[ -f $HOME/.ssh/config ]] || { print -u2 "no ~/.ssh/config"; return 1 }
  local h
  h=$(awk '/^[[:space:]]*Host[[:space:]]/ && $2 !~ /[*?!]/ {print $2}' "$HOME/.ssh/config" \
        | sort -u | fzf --prompt='ssh> ' --header='ssh hosts') || return 1
  [[ -z $h ]] && return 1
  print -r -- "ssh $h"
  ssh "$h"
}

# ── Kill a background job by fuzzy selection ──────────────
fjob() {
  local j
  j=$(jobs -l | fzf --prompt='job> ' --header='background jobs') || return 1
  [[ -z $j ]] && return 1
  print -r -- "$j"
}
