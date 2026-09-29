# ═══════════════════════════════════════════════════════════
#  90-prompt.zsh — Starship
# ═══════════════════════════════════════════════════════════
#  Config lives in ~/.config/starship.toml (a symlink into the
#  beautify repo, so it is version-controlled).
#
#  Load order note: this file runs BEFORE 95-plugins.zsh, because
#  zsh-syntax-highlighting must be the last thing sourced or it
#  highlights its own hooks. Autosuggestions must come after
#  compinit (10-history.zsh) and before widgets are used.
# ═══════════════════════════════════════════════════════════

if have starship; then
  # zsh appends a space to the right prompt, which leaves a visible
  # gap before the right edge when $fill / right_format are in use.
  ZLE_RPROMPT_INDENT=0
  eval "$(starship init zsh)"
else
  # Minimal fallback so the shell is never promptless.
  autoload -Uz colors && colors
  setopt PROMPT_SUBST
  PROMPT='%F{cyan}%~%f %# '
fi

# ── Profile switching ─────────────────────────────────────
# `profile <name>` switches two things together so they can never
# drift out of sync:
#   1. the Apple Terminal colour scheme (background, ANSI, cursor,
#      selection) — this is the bulk of the visual change
#   2. STARSHIP_CONFIG, if a starship.<name>.toml exists next to
#      the main config (only `light` does today, because the
#      palette colours are tuned for a dark background)
#
# NOTE: Starship 1.26 has no support for custom preset tables —
# `starship preset` accepts only its 12 built-in names — so this
# deliberately uses STARSHIP_CONFIG rather than a preset name.
profile() {
  local -A scheme
  scheme=(
    default   'Dev:Default'
    prod      'Dev:Production'
    remote    'Dev:Remote'
    light     'Dev:Light'
    focus     'Dev:Focus'
  )

  if [[ -z $1 ]]; then
    print -r -- "usage: profile <name>"
    local k
    for k in ${(ko)scheme}; do
      printf '  %-9s  Terminal scheme %s\n' $k "'${scheme[$k]}'"
    done
    return 1
  fi

  local name=$1
  if (( ! ${+scheme[$name]} )); then
    print -u2 "profile: unknown '$name'. Valid: ${(k)scheme}"
    return 1
  fi

  # 1. Starship prompt config
  local cfg="$XDG_CONFIG_HOME/starship.toml"
  if [[ -r $XDG_CONFIG_HOME/starship.$name.toml ]]; then
    cfg="$XDG_CONFIG_HOME/starship.$name.toml"
  else
    cfg="$XDG_CONFIG_HOME/starship.toml"
  fi
  export STARSHIP_CONFIG=$cfg
  print "starship  -> ${cfg:t}"

  # 2. Apple Terminal colour scheme
  if [[ $TERM_PROGRAM == Apple_Terminal ]]; then
    local s=${scheme[$name]}
    if defaults read com.apple.Terminal 'Window Settings' 2>/dev/null | grep -q "\"$s\""; then
      # Retint the CURRENT window immediately, not just the default
      # for new ones. Without this, `profile light` looks like it
      # did nothing until you opened a new tab.
      if osascript -e "tell application \"Terminal\"
        repeat with w in windows
          repeat with t in tabs of w
            try
              set current settings of t to \"$s\"
            end try
          end repeat
        end repeat
      end tell" >/dev/null 2>&1; then
        print "terminal  -> $s  (applied to this window)"
      else
        print "terminal  -> $s  (set as default; retint this window manually)"
      fi
      # Also the default, so new windows inherit it.
      defaults write com.apple.Terminal 'Default Window Settings' -string "$s"
    else
      print "terminal  -> scheme '$s' not found. Create the profiles with:"
      print "            swift ~/.config/starship/../scripts/make-terminal-profiles.swift"
      print "            (or: cd ~/WowMacDev/beautify && swift scripts/make-terminal-profiles.swift)"
    fi
  else
    print "terminal  -> n/a (not Apple Terminal)"
  fi

  # 3. Production gets an immediate, unmissable reminder.
  if [[ $name == prod ]]; then
    print -u2 ""
    print -u2 "  ╔══════════════════════════════════════════════╗"
    print -u2 "  ║  PRODUCTION PROFILE ACTIVE                   ║"
    print -u2 "  ╚══════════════════════════════════════════════╝"
    print -u2 "  Verify kubectl context and cloud profile before every write."
    print -u2 ""
  fi
  return 0
}
