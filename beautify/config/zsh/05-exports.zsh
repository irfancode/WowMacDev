# ═══════════════════════════════════════════════════════════
#  05-exports.zsh — environment variables
# ═══════════════════════════════════════════════════════════

# ── Editor ─────────────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export GIT_EDITOR='nvim'
export EDITOR_TOOL='vim'          # scripts that want a plain TTY editor

# ── Pager / less ───────────────────────────────────────────
export PAGER='less'
export LESS='-R --tabs=4 --mouse --quit-if-one-screen'
export LESSHISTFILE='-|lesshst'

# ── XDG base directories ───────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# ── Colour / UI behaviour ──────────────────────────────────
# CLICOLOR_FORCE is deliberately NOT set: it forces ANSI codes into
# pipes and scripts. Tools use --color=auto instead (see 30-tools.zsh).
export MANPAGER="less -FRX"

# ── Homebrew ───────────────────────────────────────────────
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

# ── ripgrep ────────────────────────────────────────────────
# No RIPGREP_CONFIG_PATH on purpose: it would also change the
# behaviour of `rg` inside scripts and CI. Interactive-only
# defaults live in the alias in 30-tools.zsh.

# ── fd ─────────────────────────────────────────────────────
export FD_DEFAULT_PATH='.'
export FD_MAX_DEPTH=''

# ── fzf ────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border=rounded --info=inline-right --color=fg:#fcfcfa,bg:#1c1b1f,hl:#78dce8 --color=fg+:#fcfcfa,bg+:#2d2a2e,hl+:#78dce8 --color=info:#727072,prompt:#ab9df2,pointer:#fc9867 --color=marker:#a9dc76,spinner:#fc9867 --preview-window=border-rounded --bind=ctrl-/:toggle-preview"

export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window 'hidden'
  --bind 'ctrl-y:execute-silent(echo {} | pbcopy)+abort'
  --bind 'ctrl-r:reload(history 1 | rg -i --color=never {2..})'
"

# ── bat ────────────────────────────────────────────────────
export BAT_THEME='Catppuccin Mocha'
export BAT_STYLE='numbers,changes,header'
export BAT_PAGER='less -FR'

# ── delta (git diff pager) ─────────────────────────────────
export DELTA_PAGER='less -FRX'
export DELTA_FEATURES='decorations'

# ── eza ────────────────────────────────────────────────────
export EZA_COLORS='all'

# ── zoxide ─────────────────────────────────────────────────
export ZOXYDE_EXCLUDE_DIRS="$HOME/.Trash:$HOME/Library"

# ── direnv ─────────────────────────────────────────────────
export DIRENV_LOG_FORMAT='direnv: %t [%n] %m '
export DIRENV_WARNINGS=0

# ── Docker ─────────────────────────────────────────────────
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# ── Kubernetes ─────────────────────────────────────────────
# Set to 1 to bypass the production guard in 65-k8s.zsh.
# export KUBE_FORCE=1

# ── AWS ────────────────────────────────────────────────────
export AWS_PAGER=''               # set aws cli v2 pagers
export AWS_DEFAULT_OUTPUT='json'

# ── Terraform ──────────────────────────────────────────────
export TF_IN_AUTOMATION=0

# ── tldr / man ─────────────────────────────────────────────
export MANWIDTH=100

# ── Ollama (local LLM runtime, 8GB-tuned) ──────────────────
export OLLAMA_MAX_LOADED_MODELS=1
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_CTX_SIZE=2048
export OLLAMA_KEEP_ALIVE=15m
export OLLAMA_FLASH_ATTENTION=1
