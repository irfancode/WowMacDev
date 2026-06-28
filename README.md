# 🚀 Mac Bootstrap

> **Provision a new macOS machine in minutes.**
> One command, one repo, zero guesswork.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![macOS](https://img.shields.io/badge/macOS-27.0+-brightgreen)
![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-M4-ff69b4)

---

## ✨ What It Does

After a clean macOS install (or a new Mac), run this repo and get:

| Category | What Gets Set Up |
|---|---|
| **📦 Package Management** | Homebrew, 55+ formulae, 12 casks, Mac App Store apps |
| **🖥️ Terminal** | Ghostty (Catppuccin Mocha, JetBrainsMono NF, 88% opacity, blur) |
| **⌨️ Shell** | Zsh + Starship prompt + zoxide + fzf + autosuggestions + syntax highlighting |
| **📝 Editor** | Neovim (LazyVim) with LSP, treesitter, telescope, mason |
| **☕ Lang Runtimes** | Node.js 22, Go 1.26, Rust 1.96, Python 3.14/3.13/3.12, Java 26 |
| **🐳 Containers** | OrbStack, Docker 29, Podman, kind, k9s |
| **☸️ Kubernetes** | kubectl, helm, helmfile, kustomize |
| **🏗️ IaC & Cloud** | Terraform, Packer, Ansible, AWS CLI, Azure CLI, gcloud CLI, 1Password CLI |
| **🔧 CLI Power Tools** | bat, ripgrep, lsd, lazygit, procs, btop, duf, ncdu, doggo, httpie, yq, sops, age |
| **⚙️ macOS Preferences** | Dark mode, fast key repeat, auto-hide Dock, tap-to-click, Finder settings |
| **📅 Apps** | Firefox Nightly, Zen, Office, Notion, WhatsApp, Spark, OneDrive, Rectangle, Zoom |
| **🔄 Auto-Updater** | `update-tools` — keeps everything current via a single CLI command |

---

## 🚦 Quick Start

### Fresh Mac (one-liner)

```bash
curl -fsSL https://raw.githubusercontent.com/<YOUR_USER>/mac-bootstrap/main/bootstrap.sh | bash
```

### From a local clone

```bash
git clone https://github.com/<YOUR_USER>/mac-bootstrap.git ~/mac-bootstrap
cd ~/mac-bootstrap
chmod +x bootstrap.sh install/*.sh scripts/*.sh
./bootstrap.sh
```

---

## 📂 Repository Structure

```
mac-bootstrap/
├── bootstrap.sh                 # 🎯 Main entry point (run this)
├── Brewfile                     # Homebrew formulae & casks
├── install/
│   ├── brew.sh                  # Homebrew installation & packages
│   ├── dev-tools.sh             # Node, Go, Neovim, fzf, rg, bat, lsd, etc.
│   └── macos.sh                 # System preferences (Dock, keyboard, Finder, etc.)
├── config/
│   ├── zsh/
│   │   ├── .zshrc               # Zsh config with aliases, completions, plugins
│   │   └── .zprofile            # Brew + OrbStack shellenv
│   ├── ghostty/
│   │   └── config               # Ghostty terminal (Catppuccin Mocha theme)
│   ├── starship/
│   │   └── starship.toml        # Starship prompt config
│   ├── btop/
│   │   └── btop.conf            # btop resource monitor config
│   └── nvim/                    # Neovim config (LazyVim-based)
│       ├── init.lua
│       ├── lazy-lock.json
│       └── lua/
│           ├── config/          # options.lua, keymaps.lua, autocmds.lua, lazy.lua
│           └── plugins/         # example.lua (LSP, treesitter, mason)
├── scripts/
│   └── update-tools.sh          # 🔄 Self-updater for all CLI tools
├── inventory/
│   └── system-snapshot.json     # 📸 Full snapshot of the original machine
└── blog/
    └── setting-up-a-new-mac.md   # 📝 Blog post about the methodology
```

---

## 🧩 What Each Phase Does

### Phase 0 — Prerequisites
- Installs Xcode Command Line Tools (if missing)
- Installs Rosetta 2 (for any x86_64 binaries)

### Phase 1 — Homebrew & Packages
- Installs Homebrew (if missing)
- Installs all 55+ formulae and 12 casks from `Brewfile`
- Installs Mac App Store apps via `mas`
- Installs npm global packages and cargo binaries

### Phase 2 — macOS Preferences
- Dark mode, fast key repeat, tap-to-click
- Auto-hide Dock with zero delay, magnification
- Finder: list view, show hidden files, path bar, extensions
- Hot corners (bottom-left → Mission Control)
- Screenshot settings

### Phase 3 — Developer Tools
Downloads and installs standalone ARM64 binaries:
- **Neovim** (latest stable)
- **Node.js** (v22 LTS line)
- **Go** (latest stable)
- **Rust** (via rustup)
- **fzf**, **ripgrep**, **bat**, **lsd**, **lazygit**, **zoxide**, **starship**, **gh**

### Phase 4 — Shell & Configs
- Installs `.zshrc` and `.zprofile` with rich aliases
- Sets up Starship prompt (Catppuccin Mocha)
- Configures Ghostty terminal
- Configures btop resource monitor
- Installs Neovim config (LazyVim)
- Installs Zsh plugins (autosuggestions, syntax highlighting)
- Sets up fzf key bindings and completions

### Phase 5 — Final Touches
- Creates standard directory layout (`~/.local/bin`, `~/.local/state`, `~/go`)
- Installs the `update-tools` script for self-maintenance
- Installs cargo tools

---

## 🔄 Staying Updated

After bootstrap, keep everything current with:

```bash
# Check what's outdated
update-tools

# Update everything
update-tools --update

# Update a specific tool
update-tools --update neovim
```

The script manages: Neovim, Node.js, fzf, ripgrep, starship, zoxide, bat, lsd, lazygit, GitHub CLI, Homebrew, npm global packages, and pip.

---

## 🧠 Design Philosophy

This repo is built from **a real machine snapshot** — everything here exists because it's actually used daily. Nothing is aspirational.

- **Fast by default**: standalone ARM64 binaries where possible (no compiling)
- **No sudo required**: everything installs to `~/.local/` and `~/.config/`
- **Idempotent**: safe to run multiple times
- **Self-maintaining**: `update-tools` keeps everything current
- **Portable**: works on any Apple Silicon Mac running macOS 27.0+

---

## 🛠️ Customizing for Your Own Setup

1. **Fork this repo**
2. Update `Brewfile` with your packages
3. Drop your configs into `config/`
4. Edit `macos.sh` to match your preferences
5. Push and run the one-liner on your next Mac

---

## 📸 Original Machine

This bootstrap was generated from a snapshot of **"Singularity"**, a MacBook Air M4 with macOS 27.0. The full inventory lives in [`inventory/system-snapshot.json`](inventory/system-snapshot.json).

---

## 📄 License

MIT
