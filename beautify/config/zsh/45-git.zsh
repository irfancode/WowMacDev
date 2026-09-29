# ═══════════════════════════════════════════════════════════
#  45-git.zsh — git aliases and helpers
# ═══════════════════════════════════════════════════════════
#  Hard rule: no alias here performs a destructive git operation.
#  `git reset --hard`, `git clean -fdx`, `git push --force` and
#  `git branch -D` are always spelled out in full, so the intent
#  is visible in the shell history and in a screen share.
# ═══════════════════════════════════════════════════════════

# ── Read-only / safe ──────────────────────────────────────
alias gs='git status --short --branch'
alias gst='git status'
alias ga='git add'
alias gaa='git add --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gl='git log --oneline --graph --decorate --all -20'
alias glf='git log --follow -p -- $CURRENT_FILE'
alias gb='git branch'
alias gba='git branch --all --verbose --no-abbrev'
alias gco='git checkout'
alias gsw='git switch'
alias gswc='git switch --create'
alias gt='git tag'
alias gstash='git stash'
alias gsta='git stash push'
alias gstp='git stash pop'
alias gremote='git remote -v'
alias gblame='git blame -w -C -C'
alias gwho='git shortlog -sn --all --no-merges'

# ── Readable history ──────────────────────────────────────
alias ggraph='git log --graph --pretty=format:"%C(auto)%h%d %s %C(dim)(%an, %ar)" --all'
alias greflog='git reflog --date=relative --pretty="%h %gd %gs (%cr)"'

# ── Fetch / prune ─────────────────────────────────────────
alias gf='git fetch --all --prune'
alias gfp='git fetch --all --prune --tags'

# ── Commit ────────────────────────────────────────────────
alias gc='git commit'
alias gca='git commit --amend --no-edit'
alias gcae='git commit --amend'      # opens $EDITOR, stated explicitly

# ── Push / pull ───────────────────────────────────────────
# No `gp = push --force`. Plain push only.
alias gp='git push'
alias gpf='git push --force-with-lease'   # safe force: refuses if remote moved
alias gpl='git pull --rebase'
alias gps='git push --set-upstream origin HEAD'

# ── Intent-revealing helpers (functions, not aliases) ─────

# Branches not merged into the current branch.
gmerged()  { git branch --merged "${1:-HEAD}" | grep -v '\*' | sed 's/^ *//;s/ *$//' ; }
gunmerged(){ git branch --no-merged "${1:-HEAD}" | sed 's/^ *//;s/ *$//' ; }

# Branches with no upstream / gone upstream.
gstale()   { git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads \
                | awk '$2 ~ /\[gone\]/ {print $1}' ; }

# Undo the last commit, keeping the work in the working tree.
guncommit(){ git reset --soft HEAD~1 ; }

# Inspect a file's history without leaving the terminal.
ghistory() {
  (( $# )) || { print -u2 "usage: ghistory <file>"; return 1 }
  git log --follow --stat --patch -- "$1" | less -R
}

# Copy a diff to the clipboard with syntax highlighting preserved
# for pasting into a PR description.
gdiff-copy() {
  if [[ -n $1 ]]; then
    git diff "$1" | delta --paging=never | pbcopy
  else
    git diff | delta --paging=never | pbcopy
  fi
  print "diff copied to clipboard"
}

# Interactive branch switcher over all local + remote branches.
gbswitch() {
  local target
  target=$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes \
             | grep -v 'HEAD$' \
             | fzf --preview 'git log --oneline -5 {}' --preview-window 'right:60%' \
             | sed 's|^origin/||') || return 1
  [[ -z $target ]] && return 1
  git switch "$target"
}

# Branches sorted by most recent commit.
grecent() {
  git for-each-ref --sort=-committerdate --format='%(committerdate:short) %(refname:short) %(authorname)' \
      refs/heads | head -15
}
