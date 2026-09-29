# ═══════════════════════════════════════════════════════════
#  65-k8s.zsh — Kubernetes workflow + production guard
# ═══════════════════════════════════════════════════════════
#  The central safety feature: `kubectl` is wrapped so that any
#  state-changing subcommand run against a context whose name looks
#  like production must be confirmed out loud first. Read-only
#  verbs (get, describe, logs, top, explain, api-resources, diff)
#  are never interrupted.
#
#  Bypass for automation:  KUBE_FORCE=1 kubectl delete pod x
# ═══════════════════════════════════════════════════════════

(( $+commands[kubectl] )) || return 0

# ── Context / namespace ───────────────────────────────────
alias k='kubectl'
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias kx='kubectl exec -it'
alias ktop='kubectl top'
alias kctx='kubectl config current-context'
alias kdesc='kubectl describe'

# Tail logs from every replica of a workload at once.
(( $+commands[stern] )) && alias kstern='stern'

# Switch context/namespace. Installed via brew (kubectx, kubens).
(( $+commands[kubectx] )) && alias kctxs='kubectx'
(( $+commands[kubens] ))  && alias kns='kubens'

# ── Is the active context production? ─────────────────────
# Matches the names people actually use: prod, production, prd,
# live, and the usual vendor markers.
k8s_is_prod() {
  local ctx ns
  ctx=$(kubectl config current-context 2>/dev/null) || return 1
  ns=${KUBECONV_NS:-${KUBECTL_NS:-default}}
  if [[ $ctx == *prod* || $ctx == *prd* || $ctx == *live* || $ctx == *Live* ]]; then
    return 0
  fi
  [[ $ns == *prod* ]] && return 0
  return 1
}

# Human-readable statement of where destructive commands would land.
k8s_guard_banner() {
  local ctx ns
  ctx=$(kubectl config current-context 2>/dev/null)
  ns=${KUBECONV_NS:-}
  print -u2 ""
  print -u2 "  ╔══════════════════════════════════════════════╗"
  print -u2 "  ║  PRODUCTION KUBERNETES                          ║"
  print -u2 "  ╚══════════════════════════════════════════════╝"
  print -u2 "   context : $ctx"
  [[ -n $ns ]] && print -u2 "   namespace: $ns"
  print -u2 "   command : kubectl $*"
  print -u2 ""
}

# Verbs that actually change cluster state. Read-only verbs
# (get, describe, logs, top, explain, api-resources, diff) and
# interactive ones (exec, cp, port-forward, attach) are NOT listed:
# prompting for them trains you to type 'prod' without reading,
# which defeats the whole mechanism.
_k8s_is_mutating() {
  case $1 in
    delete|apply|create|replace|patch|edit|scale|rollout|drain|cordon|\
    uncordon|taint|annotate|label|expose|run|set|auth) return 0 ;;
    *) return 1 ;;
  esac
}

# ── The guard ─────────────────────────────────────────────
# ${commands[kubectl]} is zsh's executable lookup table, so it
# still resolves to the real binary even though `kubectl` is now
# a function. No recursion, no manual search.
kubectl() {
  local bin=${commands[kubectl]:-}
  if [[ -z $bin ]]; then
    print -u2 "kubectl: not found"
    return 127
  fi

  # Fast path: automation, or a read-only verb.
  if [[ ${KUBE_FORCE:-0} == 1 ]]; then
    "$bin" "$@"
    return $?
  fi

  if _k8s_is_mutating $1 && k8s_is_prod; then
    k8s_guard_banner "$@"
    local reply
    print -n "Type the word 'prod' to continue: "
    read -r reply
    if [[ $reply != prod ]]; then
      print -u2 "Aborted. Nothing was sent to the cluster."
      return 1
    fi
  fi

  "$bin" "$@"
}

# Keep completion working for the wrapper.
(( $+_comps )) && compdef _kubectl kubectl 2>/dev/null

# ── Read-only overview helpers ────────────────────────────
# One screen, everything you normally check after a deploy.
k8s-health() {
  local ctx
  ctx=$(kubectl config current-context 2>/dev/null)
  print "── context: $ctx"
  print "── nodes:"
  kubectl get nodes -o wide 2>/dev/null | head -20
  print "── pods not running:"
  kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded 2>/dev/null
  print "── recent warning events:"
  kubectl get events -A --field-selector type=Warning \
    --sort-by=.lastTimestamp 2>/dev/null | tail -20
}

# Which namespaces have the most CrashLoopBackOff pods.
k8s-crashloops() {
  kubectl get pods -A 2>/dev/null \
    | awk '/CrashLoopBackOff|Error|ImagePullBackOff/ {print $1}' \
    | sort | uniq -c | sort -rn
}

# Follow logs across every replica of a deployment.
k8s-tail() {
  local deploy=${1:?usage: k8s-tail <deployment> [namespace]}
  local ns=${2:-${KUBECONV_NS:-default}}
  if (( $+commands[stern] )); then
    stern "$deploy" -n "$ns"
  else
    # Fallback: fan out over the pods ourselves.
    local pods
    pods=$(kubectl get pods -n "$ns" -l "app=$deploy" -o name 2>/dev/null)
    [[ -z $pods ]] && { print -u2 "no pods matched app=$deploy in $ns"; return 1 }
    # shellcheck disable=SC2086
    exec kubectl logs -f --prefix $pods
  fi
}

# Re-run every failed deployment in a namespace.
k8s-rollback() {
  local ns=${1:-${KUBECONV_NS:-default}}
  local dep
  dep=$(kubectl get deployments -n "$ns" 2>/dev/null \
          | awk 'NR>1 && $2!=$5 {print $1}' | fzf --prompt='rollback> ' --header='not fully rolled out') || return 1
  [[ -z $dep ]] && return 1
  print -u2 "rollout undo $dep -n $ns"
  kubectl rollout undo "deployment/$dep" -n "$ns"
}
