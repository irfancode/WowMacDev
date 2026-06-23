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

brew install \
  bat lsd ripgrep fzf jq yq tlrc tree duf doggo mtr httpie ncdu procs \
  lazygit gh starship zoxide \
  kind kubernetes-cli helm kustomize k9s helmfile kubectx \
  awscli azure-cli \
  ansible \
  go rustup openjdk \
  sops age btop glances speedtest-cli neovim \
  python@3.12

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

echo "==> Installing Terraform & Packer..."
brew tap hashicorp/tap
brew install hashicorp/tap/terraform hashicorp/tap/packer

echo "==> Setting up FZF..."
$(brew --prefix fzf)/install --key-bindings --completion --no-update-rc

echo "==> Installing Zsh plugins..."
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions \
  ~/.local/share/zsh/plugins/zsh-autosuggestions 2>/dev/null || true
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting \
  ~/.local/share/zsh/plugins/zsh-syntax-highlighting 2>/dev/null || true

echo "==> Setting up LazyVim..."
[ ! -d ~/.config/nvim ] && git clone https://github.com/LazyVim/starter ~/.config/nvim && rm -rf ~/.config/nvim/.git

echo "==> Done!"
echo "Next: open OrbStack, run gh auth login, aws configure, gcloud init, az login"
