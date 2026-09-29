# ═══════════════════════════════════════════════════════════
#  55-zoxide.zsh — directory jumping
# ═══════════════════════════════════════════════════════════
#  zoxide learns which directories you actually visit and turns
#  them into a frecency-ranked jump target. It replaces most of
#  what `cd` plus history search was doing badly.
# ═══════════════════════════════════════════════════════════

if ! have zoxide; then
  return 0
fi

# zoxide's own init wires the chpwd hook that records frecency.
# Loaded after 50-fzf.zsh so that `zi` gets fzf-backed selection.
eval "$(zoxide init zsh)"

# ── Explicit commands (the auto-generated `z` stays available) ──
alias za='zoxide add'          # bookmark a directory
alias zq='zoxide query'        # resolve a query, print the path
alias zqi='zoxide query --interactive'   # fzf picker over all history
alias zdr='zoxide remove'      # forget a directory
alias zdf='zoxide delete'      # remove from the database

# ── Maintenance ───────────────────────────────────────────
# Recompute the database and drop dead entries. Safe to run.
zoxide-refresh() {
  zoxide import --from z 2>/dev/null
  zoxide dedupe 2>/dev/null
  print "zoxide: rebuilt from shell history and de-duplicated"
  print "  entries: $(zoxide query -l 2>/dev/null | wc -l | tr -d ' ')"
}

# What has zoxide learned about where you go?
zstats() {
  print "zoxide: $(zoxide query -l 2>/dev/null | wc -l | tr -d ' ') directories indexed"
  print "database: ${_ZO_DATA_DIR:-$XDG_DATA_HOME/zoxide}/db.zo"
  print ""
  print "top 15 by frecency:"
  zoxide query -l 2>/dev/null | head -15
}
