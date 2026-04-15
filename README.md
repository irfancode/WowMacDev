# 🎨 Terminal Setup: Ghostty + Zellij + Starship

<p align="center">
  <img src="https://img.shields.io/badge/macOS-Sonoma-purple?style=for-the-badge&logo=apple&logoColor=white"/>
  <img src="https://img.shields.io/badge/Zsh-v5.9-green?style=for-the-badge&logo=gnu-bash&logoColor=white"/>
  <img src="https://img.shields.io/badge/Terminal-Ghostty-blue?style=for-the-badge"/>
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/irfan3740/dotfiles?style=for-the-badge&logo=github"/>
  <img src="https://img.shields.io/github/forks/irfan3740/dotfiles?style=for-the-badge&logo=github"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge"/>
</p>

---

## ✨ Overview

A **powerful, beautiful, and lightning-fast** terminal configuration for macOS that combines the best modern CLI tools into a cohesive, productive workflow.

```
┌─────────────────────────────────────────────────────────────────┐
│  Ghostty + Zellij + Starship + Catppuccin Mocha               │
│                                                                 │
│   ❯ ~ dotfiles                                    master ±    │
│   │                                                           │
│   │  11:23:45 ❯ ls                                            │
│   │                                                           │
│   │  📁 config    📁 scripts    📄 README.md    📄 zshrc      │
│   │                                                           │
│   └───────────────────────────────────────────────────────────│
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Features

### Terminal Stack

| Tool | Purpose | Why It's Great |
|------|---------|----------------|
| **Ghostty** | Terminal Emulator | GPU-accelerated, native macOS feel, built with Zig |
| **Zellij** | Terminal Multiplexer | Modern Rust alternative to tmux, floating panes |
| **Starship** | Prompt | Cross-shell, shows git/rust/node at a glance |

### Productivity Tools

| Tool | Replaces | Benefit |
|------|----------|---------|
| **eza** | `ls` | Icons, git status, tree views |
| **bat** | `cat` | Syntax highlighting, git diff |
| **fd** | `find` | Faster, colorized, intuitive |
| **fzf** | history/grep | Fuzzy search everything |
| **ripgrep** | `grep` | 10x faster, smarter defaults |
| **zoxide** | `cd` | Learns your habits |
| **lazygit** | git CLI | Full-featured git TUI |

### Visual Design

- **Theme**: Catppuccin Mocha (purple-tinted, easy on eyes)
- **Font**: JetBrains Mono Nerd Font (ligatures, icons)
- **Cursor**: Blinking bar cursor
- **Transparency**: 92% opacity with blur

---

## 📦 What's Included

```
dotfiles/
│
├── 📄 README.md                    # This file
├── 📄 .gitignore                   # Git ignore rules
│
├── 📁 config/
│   ├── 🖥️  ghostty/
│   │   └── config                  # Ghostty configuration
│   │
│   ├── 🟣  zellij/
│   │   ├── config.kdl              # Zellij configuration
│   │   └── themes/
│   │       └── catppuccin-mocha.kdl
│   │
│   └── ⭐  starship.toml           # Starship configuration
│
├── 📁 scripts/
│   └── ⚡ install.sh               # One-command setup
│
└── 🐚 zshrc                        # Zsh configuration + aliases
```

---

## ⚡ Quick Start

### Prerequisites

- macOS (Sonoma or later recommended)
- [Homebrew](https://brew.sh) installed

### One-Command Setup

```bash
git clone https://github.com/irfan3740/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash scripts/install.sh
exec zsh
```

### Manual Install

```bash
# 1. Install all packages
brew install --cask ghostty
brew install zellij starship zoxide
brew install eza bat fd fzf ripgrep lazygit

# 2. Link configs
mkdir -p ~/.config/{ghostty,zellij/themes,starship}
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
ln -sf ~/dotfiles/config/zellij/config.kdl ~/.config/zellij/config.kdl
ln -sf ~/dotfiles/config/zellij/themes/catppuccin-mocha.kdl ~/.config/zellij/themes/catppuccin-mocha.kdl
ln -sf ~/dotfiles/config/starship.toml ~/.config/starship.toml
ln -sf ~/dotfiles/zshrc ~/.zshrc

# 3. Restart shell
exec zsh
```

---

## ⌨️ Keyboard Shortcuts

### Ghostty (Built-in)

| Shortcut | Action |
|:---------|:-------|
| `⌘ + T` | New tab |
| `⌘ + W` | Close tab |
| `⌘ + D` | Vertical split |
| `⌘ + ⇧ + D` | Horizontal split |
| `⌘ + 1-9` | Go to tab |
| `⌘ + F` | Search scrollback |
| `⌘ + Q` | Quit |
| `⌃ + ⇧ + Space` | Toggle quick terminal |

### Zellij (Alt-based)

| Shortcut | Action |
|:---------|:-------|
| `⌥ + N` | New pane |
| `⌥ + H/J/K/L` | Navigate (vim-style) |
| `⌥ + ↑↓←→` | Navigate (arrows) |
| `⌥ + T` | New tab |
| `⌥ + W` | Close tab |
| `⌥ + 1-5` | Go to tab |
| `⌥ + X` | Close pane |
| `⌥ + M` | Toggle zoom |
| `⌥ + Q` | Detach session |

### FZF (Fuzzy Finder)

| Shortcut | Action |
|:---------|:-------|
| `⌃ + R` | Search command history |
| `⌃ + T` | Search files |
| `⌥ + C` | cd into directory |

### Custom Aliases

```bash
# File listing
ls, la, ll, lta, lt2, lt3   # eza with icons

# File viewing
cat <file>                   # bat with syntax highlighting
catp <file>                  # plain output

# Git
gs   # git status
gl   # git log --graph
gd   # git diff
lg   # lazygit

# Navigation
z <dir>    # zoxide (smart cd)
zi        # interactive select

# Development
zj         # zellij
ni         # npm install
nr         # npm run
cb         # cargo build
cr         # cargo run
```

---

## 🎨 Screenshots

### Ghostty with Catppuccin Mocha

```
┌─────────────────────────────────────────────────────────────────┐
│ ❯ ~/Projects/dotfiles ⭐                                        │
│ ❯ ls -la                                                       │
│ total 120                                                       │
│ drwxr-xr-x   8 irfan  staff   256 Apr 15 08:32 .                │
│ drwxr-xr-x   5 irfan  staff   160 Apr 15 08:32 ..               │
│ -rw-r--r--   1 irfan  staff  4652 Apr 15 08:32 README.md         │
│ drwxr-xr-x   8 irfan  staff   256 Apr 15 08:31 config/           │
│ drwxr-xr-x   3 irfan  staff    96 Apr 15 08:32 scripts/          │
│ -rw-r--r--   1 irfan  staff  13951 Apr 15 08:31 zshrc            │
│                                                                 │
│ ❯ █                                                            │
└─────────────────────────────────────────────────────────────────┘
```

### Zellij Workspace

```
┌─────────────────────────────────────────────────────────────────┐
│ [1] zellij (Catppuccin) │ [2] editor │ [3] server │ + │        │
├─────────────────────────┬───────────────────────────────────────┤
│                         │                                       │
│  ~ dotfiles            │  ❯ nvim config/ghostty/config         │
│  ❯ git status          │                                       │
│                                                                 │
│  M config/zellij/...   │  # Ghostty Configuration              │
│  ?? scripts/           │  font-family = JetBrainsMono          │
│                        │  theme = Catppuccin Mocha             │
│                        │                                       │
│                        │                                       │
├─────────────────────────┴───────────────────────────────────────┤
│  ❯ ⌥N new pane │ ⌥Q detach │ ⌥W close │ zellij 0.44.1         │
└─────────────────────────────────────────────────────────────────┘
```

### Starship Prompt

```
┌─────────────────────────────────────────────────────────────────┐
│  10:23:45 ❯                                                        │
│                                                                 │
│  ╭─[~]──────────────────────────────────────────[irfan]──╮     │
│  │  ⭐ master ±                                     10:23 │     │
│  ╰────────────────────────────────────────────────────────╯     │
│  ❯ █                                                            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Customization

### Change Theme

**Starship**: Edit `~/.config/starship.toml`
```toml
palette = "catppuccin_mocha"  # or "tokyo-night", "dracula"
```

**Ghostty**: Browse themes
```bash
ghostty +list-themes
```

### Add Keybindings

**Zellij**: Edit `~/.config/zellij/config.kdl`
```kdl
keybinds clear-defaults=true {
    normal {
        bind "Alt p" { NewPane; }  // Your custom binding
    }
}
```

### Update Aliases

Edit `~/.zshrc` and modify the alias section.

---

## 🐛 Troubleshooting

### Config not loading?

```bash
# Ghostty
ghostty +show-config

# Zellij
zellij setup --check

# Starship
starship config
```

### Restart services

```bash
# Reload Ghostty config
⌘ + ⇧ + ,

# Reload shell
exec zsh

# Restart Zellij
pkill zellij && zj
```

---

## 📚 Resources

- [Ghostty Documentation](https://ghostty.org/docs)
- [Zellij Documentation](https://zellij.dev/documentation)
- [Starship Documentation](https://starship.rs/config)
- [Catppuccin Themes](https://github.com/catppuccin/catppuccin)
- [eza](https://github.com/eza-community/eza)
- [fzf](https://github.com/junegunn/fzf)

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or PRs.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

## 📄 License

MIT License - feel free to use, modify, and share.

---

<p align="center">
  Made with ❤️ for the terminal enthusiasts
</p>

<p align="center">
  <a href="https://github.com/irfan3740/dotfiles">⭐ Star this repo</a>
  ·
  <a href="https://github.com/irfan3740/dotfiles/issues">🐛 Report Bug</a>
  ·
  <a href="https://github.com/irfan3740/dotfiles/issues">💡 Request Feature</a>
</p>
