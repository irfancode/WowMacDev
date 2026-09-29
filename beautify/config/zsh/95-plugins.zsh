# ═══════════════════════════════════════════════════════════
#  95-plugins.zsh — optional enhancements (loaded LAST)
# ═══════════════════════════════════════════════════════════
#  Both plugins were already installed via Homebrew in the old
#  setup but never sourced, so they were pure dead weight. They
#  are cheap, so they stay on; each is individually guarded.
#
#  ORDER IS SIGNIFICANT:
#    1. autosuggestions  — after compinit, before anything uses widgets
#    2. direnv hook     — installs ZLE widgets of its own
#    3. syntax-highlighting — absolutely last; it re-wraps every
#       ZLE widget, so anything loaded afterwards gets clobbered.
# ═══════════════════════════════════════════════════════════

# ── zsh-autosuggestions ───────────────────────────────────
# Inline grey suggestion for the rest of the command, driven by history.
if [[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

  # Accept the suggestion with → (End); zsh sends ESC O C / ESC [ C.
  bindkey '^[[C' forward-char
  bindkey '^[[1;5C' vi-forward-word      # Alt-Right
  bindkey '^[[1;2C' vi-forward-word
  # Ctrl-F accepts too, which is more discoverable on a Mac keyboard.
  bindkey '^F' vi-forward-char
fi

# ── direnv ────────────────────────────────────────────────
# Canonical integration: direnv supplies its own chpwd/precmd
# hook, which both activates a new .envrc and correctly *undoes*
# the environment when you cd back out. A hand-rolled chpwd
# function gets the "cd into a project" case right only by
# accident and never clears the environment on the way out.
if have direnv; then
  eval "$(direnv hook zsh)"
fi

# ── zsh-syntax-highlighting (must be the final source) ─────
# Loaded after direnv because direnv's hook installs ZLE widgets
# of its own; highlighting has to be in place to wrap them.
if [[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor)
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
