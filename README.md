# 🎨 Terminal Setup: Ghostty + Zellij + Starship

<p align="center">
  <img src="https://img.shields.io/badge/macOS-Sonoma-purple?style=for-the-badge&logo=apple&logoColor=white"/>
  <img src="https://img.shields.io/badge/Zsh-v5.9-green?style=for-the-badge&logo=gnu-bash&logoColor=white"/>
  <img src="https://img.shields.io/badge/Terminal-Ghostty-blue?style=for-the-badge"/>
</p>

<p align="center">
  <a href="https://github.com/irfancode/dotfiles/actions/workflows/pages.yml">
    <img src="https://img.shields.io/github/deployments/irfancode/dotfiles/github-pages?style=for-the-badge&logo=github"/>
  </a>
  <img src="https://img.shields.io/github/stars/irfancode/dotfiles?style=for-the-badge&logo=github"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge"/>
</p>

✨ A **powerful, beautiful, and lightning-fast** terminal configuration for macOS featuring **Ghostty**, **Zellij**, **Starship**, and **Catppuccin Mocha** theme.

🌐 **Live Demo**: https://irfancode.github.io/dotfiles/

---

## 🚀 Quick Start

```bash
git clone https://github.com/irfancode/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash scripts/install.sh
exec zsh
```

---

## 📦 Features

### Terminal Stack
- **Ghostty** — GPU-accelerated terminal built with Zig
- **Zellij** — Modern Rust-based terminal multiplexer
- **Starship** — Cross-shell prompt with git/language info

### Productivity Tools
- **eza** — Modern `ls` with icons and git status
- **bat** — Modern `cat` with syntax highlighting
- **fd** — Fast, colorized file finder
- **fzf** — Fuzzy finder for everything
- **ripgrep** — 10x faster grep
- **zoxide** — Smarter `cd` that learns your habits
- **lazygit** — Full-featured git TUI

### Visual Design
- **Theme**: Catppuccin Mocha (purple-tinted)
- **Font**: JetBrains Mono Nerd Font
- **Cursor**: Blinking bar cursor

---

## ⌨️ Keyboard Shortcuts

### Ghostty (Cmd)
| Shortcut | Action |
|:---------|:-------|
| `⌘ + T` | New tab |
| `⌘ + D` | Vertical split |
| `⌘ + ⇧ + D` | Horizontal split |
| `⌘ + F` | Search |
| `⌘ + Q` | Quit |

### Zellij (Alt)
| Shortcut | Action |
|:---------|:-------|
| `⌥ + N` | New pane |
| `⌥ + H/J/K/L` | Navigate panes |
| `⌥ + T` | New tab |
| `⌥ + Q` | Detach |

### Aliases
| Command | Description |
|---------|-------------|
| `zj` | Start Zellij |
| `lg` | Lazygit TUI |
| `z <dir>` | Jump to directory |
| `Ctrl + R` | Search history |

---

## 📁 File Structure

```
dotfiles/
├── _config.yml              # Jekyll config
├── _posts/                  # Blog posts
├── _layouts/               # Page templates
├── _includes/               # Reusable components
├── assets/                  # CSS, images
├── config/                  # App configs
│   ├── ghostty/
│   ├── zellij/
│   └── starship.toml
├── scripts/
│   └── install.sh          # One-command setup
└── zshrc                   # Shell config
```

---

## 🌐 Blog

The blog is built with Jekyll and deployed to GitHub Pages.

### Enable GitHub Pages

1. Go to **Settings → Pages** in your repo
2. Set **Source** to "GitHub Actions"
3. The workflow will auto-deploy on push

### Local Development

```bash
bundle install
bundle exec jekyll serve
# Visit http://localhost:4000
```

---

## 🔧 Customization

### Change Theme
Edit `~/.config/starship.toml`:
```toml
palette = "catppuccin_mocha"
```

### Browse Ghostty Themes
```bash
ghostty +list-themes
```

### Add Zellij Keybindings
Edit `~/.config/zellij/config.kdl`

---

## 📚 Resources

- [Ghostty](https://ghostty.org) · [Zellij](https://zellij.dev) · [Starship](https://starship.rs)
- [Catppuccin](https://github.com/catppuccin/catppuccin)
- [eza](https://github.com/eza-community/eza) · [fzf](https://github.com/junegunn/fzf)

---

## 🤝 Contributing

Contributions welcome! Open issues or PRs.

---

<p align="center">
  Made with ❤️ for terminal enthusiasts<br>
  <a href="https://github.com/irfancode/dotfiles">⭐ Star this repo</a>
</p>
