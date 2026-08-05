> **Superseded** by [mac-bootstrap](https://github.com/irfancode/mac-bootstrap) — a single-command setup script that automates everything in this guide.
# How to Set Up a Forward Deployment Engineering Mac in 2026

*A complete, step-by-step guide to building a terminal-first infrastructure engineering workstation on macOS.*

---

## Introduction

This guide walks through setting up a macOS development environment for **Forward Deployment Engineering** — container orchestration, multi-cloud deployment, infrastructure as code, secrets management, and system monitoring — all from the terminal.

The target machine is a MacBook Air M4 running macOS 27.0 (Sequoia), but these steps work on any Apple Silicon Mac running macOS 24+ (Sequoia).

### What you'll end up with

| Category | Tools |
|---|---|
| **Terminal** | Ghostty + Zsh + Starship + FZF + Zoxide |
| **Container Runtime** | OrbStack (Docker-compatible) |
| **Kubernetes** | kubectl, kind, Helm, Kustomize, k9s, Helmfile, kubectx |
| **Cloud CLIs** | AWS CLI v2, Google Cloud SDK, Azure CLI |
| **Infrastructure as Code** | Terraform, Ansible, Packer |
| **Languages** | Node.js, Go, Python, Rust, Java (OpenJDK) |
| **Security** | 1Password CLI, SOPS, age |
| **Editing** | Neovim + LazyVim |
| **Monitoring** | btop, glances, htop, procs |
| **CLI Utilities** | bat, lsd, ripgrep, jq, yq, httpie, doggo, mtr, dust, duf, ncdu, tldr, lazygit, gh |

---

## Phase 1: macOS Preparation

### 1.1 Enable command-line developer tools

```bash
xcode-select --install
```

A dialog will appear — click **Install** and wait for it to complete.

### 1.2 Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, add Homebrew to your PATH:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 1.3 Open OrbStack (one-time launch)

We install OrbStack early because it needs a manual launch to set up the VM.

```bash
brew install --cask orbstack
open -a OrbStack
```

Complete the onboarding wizard — grant `sudo` permissions when prompted. Once running, Docker commands work natively.

---

## Phase 2: Core Terminal & CLI

### 2.1 Install Ghostty (Terminal Emulator)

```bash
brew install --cask ghostty
```

Create the config directory and write the configuration:

```bash
mkdir -p ~/.config/ghostty
```

**`~/.config/ghostty/config`:**

```
font-family = JetBrainsMono NF
font-size = 15
font-thicken = true
theme = Catppuccin Mocha
background-opacity = 0.92
background-blur-radius = 20
window-padding-x = 8
window-padding-y = 6
window-padding-balance = true
window-decoration = false
macos-titlebar-style = tabs
macos-non-native-fullscreen = true
macos-option-as-alt = left
cursor-style = block
cursor-style-blink = false
mouse-hide-while-typing = true
copy-on-select = clipboard
shell-integration = detect
scrollback-limit = 10000000
keybind = cmd+d=new_split:right
keybind = cmd+shift+d=new_split:down
keybind = cmd+shift+h=goto_split:left
keybind = cmd+shift+l=goto_split:right
keybind = cmd+shift+k=goto_split:top
keybind = cmd+shift+j=goto_split:bottom
keybind = cmd+shift+z=toggle_split_zoom
keybind = cmd+shift+e=equalize_splits
keybind = ctrl+`=toggle_quick_terminal
```

Download the JetBrainsMono Nerd Font:

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

### 2.2 Install Modern CLI Replacements

```bash
brew install bat lsd ripgrep fzf jq yq tlrc tree duf doggo mtr httpie ncdu procs
```

Enable FZF key bindings and shell integration:

```bash
$(brew --prefix fzf)/install --key-bindings --completion --no-update-rc
```

### 2.3 Install Git Tooling

```bash
brew install lazygit gh
```

Configure `gh`:

```bash
gh auth login
```

### 2.4 Configure Zsh

**`~/.zshrc`:**

```zsh
# ── Source Profile Files ────────────────────────────────────
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
[ -f "$HOME/.zprofile" ] && . "$HOME/.zprofile"

# ── PATH ────────────────────────────────────────────────────
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
[ -d "$HOME/go/bin" ] && export PATH="$HOME/go/bin:$PATH"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

# ── STARSHIP PROMPT ─────────────────────────────────────────
eval "$(starship init zsh)"

# ── ZOXIDE - Smarter cd ────────────────────────────────────
eval "$(zoxide init zsh)"
alias za='zoxide add'
alias zq='zoxide query'
alias zqi='zoxide query --interactive'

# ── FZF - Fuzzy Finder ─────────────────────────────────────
export FZF_DEFAULT_COMMAND='find . -type f -not -path "./.git/*" 2>/dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='find . -type d -not -path "./.git/*" 2>/dev/null'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_R_OPTS='--height 40% --layout=reverse --border --preview "echo {}" --preview-window hidden --bind "ctrl-y:execute-silent(echo {} | pbcopy)+abort"'
[ -f ~/.fzf/shell/key-bindings.zsh ] && source ~/.fzf/shell/key-bindings.zsh
[ -f ~/.fzf/shell/completion.zsh ] && source ~/.fzf/shell/completion.zsh

# ── LSD ─────────────────────────────────────────────────────
alias ls='lsd'
alias ll='lsd -l'
alias lt='lsd --tree'
alias la='lsd -la'

# ── BAT ─────────────────────────────────────────────────────
alias cat='bat'
alias catt='bat --style=plain'

# ── RIPGREP ─────────────────────────────────────────────────
alias rg='rg --color=always --line-number --no-heading --smart-case'
alias rgi='rg --ignore-case'
alias rgw='rg --word-regexp'

# ── GIT ─────────────────────────────────────────────────────
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias lg='lazygit'

# ── CONTAINERS & KUBERNETES ────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias di='docker images'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs -f'
alias kx='kubectx'
alias kn='kubens'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias k9='k9s'
alias h='helm'
alias hf='helmfile'

# ── INFRASTRUCTURE AS CODE ─────────────────────────────────
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfw='terraform workspace'
alias ans='ansible'
alias asp='ansible-playbook'
alias op='op'

# ── MONITORING ─────────────────────────────────────────────
alias b='btop'
alias gl='glances'
alias ports='lsof -i -P -n | grep LISTEN'

# ── DEVELOPMENT ────────────────────────────────────────────
alias ni='npm install'
alias nr='npm run'
alias nrd='npm run dev'
alias cb='cargo build'
alias cr='cargo run'

# ── SYSTEM ─────────────────────────────────────────────────
alias c='clear'
alias http='python3 -m http.server'

# ── ZSH OPTIONS ────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY
setopt AUTO_CD CORRECT

# ── COMPLETION ─────────────────────────────────────────────
fpath=( "$HOME/.local/share/zsh/site-functions" $fpath )
fpath=( /opt/homebrew/share/zsh/site-functions $fpath )
[ -f /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc ] && \
  source /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*:matches' group-name ''
zstyle ':completion:*' use-cache on

# ── KEY BINDINGS ───────────────────────────────────────────
bindkey -v
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^e' edit-command-line

# ── ENVIRONMENT ────────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad

# ── ZSH PLUGINS ────────────────────────────────────────────
[ -f "$HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
  && source "$HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
  && source "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
```

### 2.5 Install Zsh Plugins

```bash
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
  ~/.local/share/zsh/plugins/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
  ~/.local/share/zsh/plugins/zsh-syntax-highlighting
```

### 2.6 Install Starship Prompt

```bash
brew install starship
```

**`~/.config/starship.toml`:**

```toml
format = """$directory$git_branch$git_status$cmd_duration$line_break$character"""

palette = "catppuccin_mocha"

[palettes.catppuccin_mocha]
text = "#cdd6f4"
surface = "#313244"
subtext = "#a6adc8"
overlay = "#585b70"
green = "#a6e3a1"
mauve = "#cba6f7"
blue = "#89b4fa"
teal = "#94e2d5"
peach = "#fab387"
maroon = "#f38ba8"

[directory]
style = "blue"
truncation_length = 2
truncate_to_repo = true

[git_branch]
symbol = " "
style = "mauve"

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "peach"

[cmd_duration]
min_time = 2000
style = "subtext"

[character]
success_symbol = "[❯](green)"
error_symbol = "[❯](maroon)"
vimcmd_symbol = "[❮](teal)"
```

Reload your shell:

```bash
exec zsh
```

---

## Phase 3: Container Runtime & Orchestration

### 3.1 OrbStack (Docker-compatible runtime)

Already installed in Phase 1. Verify it's running:

```bash
docker version
docker compose version
```

OrbStack replaces Docker Desktop entirely — it's faster, lighter, and includes a built-in Kubernetes cluster.

### 3.2 Kubernetes Toolchain

```bash
brew install kind kubernetes-cli helm kustomize k9s helmfile kubectx
```

Enable the built-in K8s cluster in OrbStack (GUI toggle in settings), or create a local cluster with kind:

```bash
kind create cluster --name fde
```

Verify:

```bash
kubectl cluster-info
kubectl get nodes
```

### 3.3 Configure kubectl completions (automatic via Homebrew)

```bash
# Add to .zshrc if not already there (already included in the template above)
source <(kubectl completion zsh)
```

---

## Phase 4: Cloud Provider CLIs

### 4.1 AWS CLI v2

```bash
brew install awscli
aws configure
```

You'll be prompted for your Access Key ID, Secret Access Key, region, and output format.

### 4.2 Google Cloud SDK

```bash
brew install --cask google-cloud-sdk
```

The SDK installs `gcloud`, `gsutil`, and `bq`. Initialize it:

```bash
gcloud init
gcloud auth login
```

### 4.3 Azure CLI

```bash
brew install azure-cli
az login
```

---

## Phase 5: Infrastructure as Code

### 5.1 Terraform

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

Verify:

```bash
terraform version
```

### 5.2 Ansible

```bash
brew install ansible
```

Verify:

```bash
ansible --version
```

### 5.3 Packer

```bash
brew install hashicorp/tap/packer
```

Verify:

```bash
packer version
```

---

## Phase 6: Language Runtimes

### 6.1 Node.js & npm

```bash
# Download and extract the latest LTS
curl -fsSL https://nodejs.org/dist/v22.23.0/node-v22.23.0-darwin-arm64.tar.gz \
  | tar -xz -C ~/.local/opt/
ln -sf ~/.local/opt/node-v22.23.0-darwin-arm64/bin/* ~/.local/bin/
```

Verify:

```bash
node --version   # v22.23.0
npm --version    # 11.17.0
```

### 6.2 Go

```bash
brew install go
```

Add to `~/.zshrc` if not already present:

```zsh
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

Verify:

```bash
go version
```

### 6.3 Python

macOS ships with Python 3.9 system-wide. For project work, install the latest via Homebrew:

```bash
brew install python@3.12
```

### 6.4 Rust

```bash
brew install rustup
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
rustup-init -y --no-modify-path
source "$HOME/.cargo/env"
```

Verify:

```bash
rustc --version   # 1.96.0
cargo --version   # 1.96.0
```

### 6.5 Java (OpenJDK)

```bash
brew install openjdk
```

Add to PATH (already in the `~/.zshrc` template above):

```zsh
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
```

Optionally symlink for system Java wrappers (requires `sudo`):

```bash
sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk \
  /Library/Java/JavaVirtualMachines/openjdk.jdk
```

Verify:

```bash
java --version   # openjdk 26.0.1
```

---

## Phase 7: Security & Secrets

### 7.1 1Password CLI

```bash
brew install --cask 1password-cli
```

Enable the 1Password CLI integration:
1. Open 1Password 8 → Settings → Developer
2. Enable the 1Password CLI integration
3. Turn on "Connect with 1Password CLI"

Verify:

```bash
op --version
op account list
```

### 7.2 SOPS (Secrets OPerationS)

```bash
brew install sops
```

Verify:

```bash
sops --version
```

### 7.3 age (modern file encryption)

```bash
brew install age
```

Generate a key pair:

```bash
mkdir -p ~/.config/age
age-keygen -o ~/.config/age/key.txt
```

---

## Phase 8: Monitoring & System Utilities

### 8.1 Install Monitoring Tools

```bash
brew install btop glances htop speedtest-cli
```

- **btop** — Live resource monitor with GPU, disk, network, and process views. Run with `btop`.
- **glances** — Comprehensive overview. Run with `glances`. Starts a web UI on port 61208.
- **htop** — Classic process viewer. Run with `sudo htop` for full visibility.

### 8.2 Disk Utilities

```bash
# dust is installed via cargo
source ~/.cargo/env
cargo install du-dust
```

Usage:

```bash
dust      # disk usage by directory (like du but better)
duf       # disk usage overview (like df but prettier)
ncdu      # interactive ncurses disk usage browser
```

### 8.3 Network Tools

```bash
doggo example.com     # modern DNS lookup
mtr google.com        # traceroute + ping in one
speedtest-cli         # bandwidth test
http httpie.io        # modern curl alternative
```

---

## Phase 9: Editor Setup (Neovim + LazyVim)

### 9.1 Install Neovim

```bash
brew install neovim
```

### 9.2 Install a Nerd Font (for icons)

Already done in Phase 2 if you installed JetBrainsMono Nerd Font.

### 9.3 Install LazyVim

```bash
# Backup existing config if any
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null

# Clone the LazyVim starter template
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
```

### 9.4 Launch and Install Plugins

```bash
nvim
```

LazyVim will automatically download its plugin manager (`lazy.nvim`) and install all bundled plugins. Wait for completion, then restart Neovim.

### 9.5 Verify LSP Support

```bash
# Install language servers
:MasonInstall lua-language-server stylua shfmt
```

---

## Phase 10: Productivity Applications

### 10.1 Window Manager

```bash
brew install --cask rectangle
```

Rectangle provides keyboard-driven window snapping — essential for a terminal-heavy workflow.

### 10.2 Communication & Productivity

```bash
brew install --cask \
  firefox \
  notion \
  whatsapp \
  zoom \
  microsoft-word \
  microsoft-powerpoint \
  onedrive
```

---

## Phase 11: Final Verification

Run this command to verify every tool is accessible:

```bash
echo "=== SHELL ==="
echo $SHELL && zsh --version | head -1
echo "=== TERMINAL ==="
ghostty --version 2>/dev/null || echo "ghostty installed via cask"
echo "=== CONTAINERS ==="
docker version 2>/dev/null | head -2
kind version 2>/dev/null | head -1
echo "=== K8s ==="
kubectl version --client 2>/dev/null | head -1
echo "=== IaC ==="
terraform version 2>/dev/null | head -1
ansible --version 2>/dev/null | head -1
packer version 2>/dev/null | head -1
echo "=== CLOUD ==="
aws --version 2>/dev/null | head -1
gcloud version 2>/dev/null | head -1
az version 2>/dev/null | head -1
echo "=== LANGUAGES ==="
node --version 2>/dev/null
go version 2>/dev/null | head -1
rustc --version 2>/dev/null
java --version 2>/dev/null | head -1
echo "=== SECURITY ==="
op --version 2>/dev/null
sops --version 2>/dev/null | head -1
age --version 2>/dev/null
echo "=== MONITORING ==="
btop --version 2>/dev/null
echo "=== CLI ==="
gh --version 2>/dev/null | head -1
lazygit --version 2>/dev/null | head -1
fzf --version 2>/dev/null
bat --version 2>/dev/null | head -1
lsd --version 2>/dev/null | head -1
rg --version 2>/dev/null | head -1
http --version 2>/dev/null | head -1
jq --version 2>/dev/null
yq --version 2>/dev/null | head -1
tldr --version 2>/dev/null
echo "=== DONE ==="
```

---

## Phase 12: Optional — Automation Script

For future clean installs, save this as `bootstrap.sh`:

```bash
#!/bin/bash
set -euo pipefail

echo "==> Installing Xcode CLI tools..."
xcode-select --install 2>/dev/null || true

echo "==> Installing Homebrew..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Installing Homebrew packages..."
brew update

# Formulae
brew install \
  bat lsd ripgrep fzf jq yq tlrc tree duf doggo mtr httpie ncdu procs \
  lazygit gh starship zoxide \
  kind kubernetes-cli helm kustomize k9s helmfile kubectx \
  awscli azure-cli \
  ansible \
  go rustup openjdk \
  sops age btop glances speedtest-cli neovim \
  python@3.12

# Casks
brew install --cask \
  orbstack ghostty google-cloud-sdk 1password-cli \
  rectangle firefox notion whatsapp zoom \
  microsoft-word microsoft-powerpoint onedrive \
  font-jetbrains-mono-nerd-font

echo "==> Setting up Rust..."
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
rustup-init -y --no-modify-path
source "$HOME/.cargo/env"
cargo install du-dust

echo "==> Installing Terraform & Packer (hashicorp tap)..."
brew tap hashicorp/tap
brew install hashicorp/tap/terraform hashicorp/tap/packer

echo "==> Setting up FZF..."
$(brew --prefix fzf)/install --key-bindings --completion --no-update-rc

echo "==> Installing Zsh plugins..."
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
  ~/.local/share/zsh/plugins/zsh-autosuggestions
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
  ~/.local/share/zsh/plugins/zsh-syntax-highlighting

echo "==> Setting up LazyVim..."
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

echo "==> Setup complete!"
echo "Next steps:"
echo "  1. Open OrbStack to finish setup"
echo "  2. Run 'gh auth login' to authenticate GitHub CLI"
echo "  3. Run 'aws configure' for AWS"
echo "  4. Run 'gcloud init' for Google Cloud"
echo "  5. Run 'az login' for Azure"
echo "  6. Open Neovim to install plugins"
```

Make it executable:

```bash
chmod +x bootstrap.sh
```

---

## Conclusion

In about 30 minutes of scripted setup (or 60 minutes walking through this guide step-by-step), you go from a factory-fresh macOS to a fully equipped Forward Deployment Engineering workstation.

The stack is:

```
Ghostty → Zsh → Starship → OrbStack → kubectl → Helm → Terraform → AWS/GCP/Azure → Neovim
```

Everything is terminal-first, reproducible via dotfiles and a bootstrap script, and ready to deploy infrastructure into any environment — cloud, on-prem, or at the edge.
