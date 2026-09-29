# ═══════════════════════════════════════════════════════════
#  70-docker.zsh — containers
# ═══════════════════════════════════════════════════════════
#  The previous config had `alias docker-clean='docker system
#  prune -af'` — no prompt, no preview, and it deletes every
#  unused image and every stopped container on the machine.
#  It is replaced by an explicit, reporting, confirm-first
#  function. Plain `docker` is never aliased away.
# ═══════════════════════════════════════════════════════════

if ! have docker && ! have podman; then
  return 0
fi

# Use whichever engine exists.
if have docker;   then _ctr_engine=docker
elif have podman; then _ctr_engine=podman
fi

alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'
alias dimg='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"'
alias dvol='docker volume ls'
alias dnet='docker network ls'
alias dcomp='docker compose'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dlogs='docker compose logs -f --tail=100'
alias dexec='docker compose exec'
alias dcps='docker compose ps'
alias dprune='docker-keep-what'

# ── Safe inventory ────────────────────────────────────────
# Read-only: always safe, no confirmation.
docker-report() {
  print "── containers"
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null
  print "\n── disk usage"
  docker system df 2>/dev/null
  print "\n── images"
  docker images --format 'table {{.Repository}}:{{.Tag}}\t{{.Size}}' 2>/dev/null | head -20
  print "\n── volumes"
  docker volume ls 2>/dev/null
  print "\n── dangling images"
  print "  count: $(docker images -f dangling=true -q 2>/dev/null | wc -l | tr -d ' ')"
}

# ── The replacement for `docker-clean` ────────────────────
# Reports first, asks second, deletes third. Safe by default:
# only unused objects are touched, and volumes are preserved
# unless you explicitly ask for them.
docker-keep-what() {
  local -i with_volumes=0
  if [[ $1 == --volumes || $1 == -v ]]; then
    with_volumes=1
    shift
  fi

  print "── what would be removed:"
  print "  stopped containers: $(docker ps -aq --filter status=exited 2>/dev/null | wc -l | tr -d ' ')"
  print "  unused networks:    $(docker network ls -q --filter '!type=custom' 2>/dev/null | wc -l | tr -d ' ')"
  print "  dangling images:    $(docker images -f dangling=true -q 2>/dev/null | wc -l | tr -d ' ')"
  print "  build cache:        $(docker system df 2>/dev/null | awk '$1=="Build" && $2=="Cache" {print $6}')"
  if (( with_volumes )); then
    print -u2 "  ⚠  VOLUMES: --volumes was given, so unused volumes WILL be deleted."
  else
    print "  volumes:            kept (pass --volumes to also delete these)"
  fi
  print ""

  local reply
  print -n "Proceed? [y/N] "
  read -r reply
  if [[ $reply != [yY] ]]; then
    print "Aborted. Nothing was removed."
    return 1
  fi

  if (( with_volumes )); then
    docker system prune -af --volumes
  else
    docker system prune -af
  fi
}

# ── Reclaim space from the build cache only ───────────────
# Usually the single biggest win, and it cannot touch your data.
docker-buildcache() {
  local before after
  before=$(docker system df 2>/dev/null | awk '$1=="Build" && $2=="Cache" {print $6}')
  print "build cache before: $before"
  local reply
  print -n "Clear build cache? [y/N] "
  read -r reply
  [[ $reply == [yY] ]] || { print "Aborted."; return 1 }
  docker builder prune -af
  after=$(docker system df 2>/dev/null | awk '$1=="Build" && $2=="Cache" {print $6}')
  print "build cache after:  $after"
}
