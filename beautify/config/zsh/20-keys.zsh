# ═══════════════════════════════════════════════════════════
#  20-keys.zsh — key bindings
# ═══════════════════════════════════════════════════════════
#  Console-consistent vim mode.
#
#  Ctrl+Shift+Up/Down prompt-jump was removed: that is a Ghostty
#  shell-integration feature and this setup targets Apple Terminal.
#
#  Ctrl+R / Ctrl+T / Alt+C are owned by 50-fzf.zsh (fzf history,
#  file finder, directory finder) and are NOT bound here.
# ═══════════════════════════════════════════════════════════

bindkey -v

# ── Line / word editing ───────────────────────────────────
bindkey '^?'     backward-delete-char
bindkey '^H'     backward-delete-char
bindkey '^U'     kill-whole-line          # clear to start
bindkey '^K'     kill-line                # clear to end
bindkey '^W'     backward-kill-word
bindkey '^A'     beginning-of-line
bindkey '^E'     end-of-line
bindkey '^T'     transpose-chars

# Word deletion treats '-', '_', '/', '.' and '=' as word
# characters, which is what you want when editing flags and paths.
autoload -Uz backward-kill-word
zle -N backward-kill-word

# Home/End as the terminal sends them. These are ESC-sequences,
# distinct from Ctrl+A / Ctrl+E, so both spellings work.
bindkey '^[[H'   beginning-of-line
bindkey '^[[F'   end-of-line
bindkey '^[[1~'  beginning-of-line
bindkey '^[[4~'  end-of-line
bindkey '^[[3~'  delete-char

# Transpose whole words on Ctrl+_. (Alt+_ / Ctrl+Shift+_ varies
# by keyboard layout, so this stays unbound rather than guessing.)
autoload -Uz transpose-words
zle -N transpose-words

# ── History on the current buffer ─────────────────────────
# Incremental prefix search: type a few chars, press Up.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A'   up-line-or-beginning-search
bindkey '^[[B'   down-line-or-beginning-search
bindkey '^[[5~'  up-line-or-history
bindkey '^[[6~'  down-line-or-history

# ── Editor + clipboard ────────────────────────────────────
autoload -Uz edit-command-line
zle -N edit-command-line
# Ctrl+A / Ctrl+E keep their Emacs meaning (start / end of line);
# the multiline editor moves to Alt+E so that muscle memory for
# "Ctrl+E = end of line" is not broken.
bindkey '^e'     end-of-line
bindkey '^[[e'   edit-command-line        # Alt+E

autoload -Uz copypaste
zle -N copypaste
bindkey '^y'     copypaste               # paste from system clipboard

# ── Scrolling ─────────────────────────────────────────────
bindkey '^[[5;5~' backward-half-line
bindkey '^[[6;5~' forward-half-line

# ── Debugging aid ─────────────────────────────────────────
# Unbound-key report. Essential when a keymap misbehaves.
bindkey '^[[27;5;~' list-expand-or-keep
