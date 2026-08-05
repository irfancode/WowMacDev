---
layout: post
title: "Ghostty + Zellij + Starship: Building the Ultimate Terminal Setup in 2026"
date: 2026-04-15
categories: terminal productivity developer-tools
---

> **TL;DR** — I built a terminal setup using Ghostty, Zellij, and Starship that looks beautiful, runs blazingly fast, and makes me genuinely enjoy working in the command line. Here's everything you need to recreate it.

## The Problem with "Default" Terminals

If you're like most developers, you've been using the same terminal setup for years. Maybe iTerm2 with some custom colors, or the default Terminal.app with a downloaded theme. It works, but it never *felt* right.

I wanted something that was:
- ⚡ **Fast** — No lag, no stutter, instant response
- 🎨 **Beautiful** — A cohesive visual experience
- ⌨️ **Powerful** — Built-in multiplexing, smart navigation
- 🔧 **Maintainable** — Config-as-code, portable to new machines

So I spent a weekend building the terminal setup I've always wanted.

## The Stack

Here's what I chose:

| Tool | Purpose | Why It's Great |
|------|---------|----------------|
| **Ghostty** | Terminal Emulator | GPU-accelerated, native macOS feel, built with Zig |
| **Zellij** | Terminal Multiplexer | Modern Rust alternative to tmux, floating panes |
| **Starship** | Prompt | Cross-shell, shows git/rust/node at a glance |

## Why These Tools?

### Ghostty: The Terminal That Gets It Right

Built by Mitchell Hashimoto (co-founder of HashiCorp), Ghostty is written in Zig and uses Metal GPU acceleration on macOS. The result? *Fast.*

But more importantly, it gets the defaults right. No configuration needed for a good experience out of the box. Built-in splits, tabs, shell integration, and a beautifully minimal UI.

```bash
# Install
brew install --cask ghostty
```

### Zellij: tmux, Modernized

Zellij is written in Rust and offers features that tmux doesn't have:
- Floating panes
- Built-in layouts
- Web client mode
- WASM plugin support

And it uses `Alt` instead of `Ctrl` for keybindings — your fingers will thank you.

```bash
# Install
brew install zellij
```

### Starship: Context-Aware Prompt

Starship shows you relevant information based on what you're doing:
- Git branch and status
- Node.js/Rust/Python version
- Command execution time
- Current directory

All in a beautiful, fast prompt that works across shells.

```bash
# Install
brew install starship
```

## The Visual Experience

### Catppuccin Mocha

I chose [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) as the theme — a warm, purple-tinted palette that's easy on the eyes during long coding sessions.

```
Colors:
  🟣 Lavender  #b4befe  (keywords, operators)
  🔵 Blue     #89b4fa  (strings, paths)
  🟢 Green    #a6e3a1  (success, git added)
  🔴 Red      #f38ba8  (errors, git deleted)
  🟠 Peach    #fab387  (warnings, modified)
```

### The Prompt

```
╭─[~/Projects/dotfiles]────────────────────────────────[irfan]──╮
│  ⭐ master ±                                                   │
╰───────────────────────────────────────────────────────────────╯
❯
```

Git status, branch, and directory — all visible at a glance.

## Productivity Boosters

### eza: ls, but Beautiful

```bash
# Instead of ls -la
ls

# Shows icons, git status, colors
📁 config    📄 README.md    📄 zshrc    📁 scripts
```

### bat: cat, but Better

```bash
# Syntax highlighting, line numbers, git diffs
bat config/ghostty/config
```

### zoxide: cd, but Smarter

```bash
# Instead of typing the full path
z dotfiles

# Or interactive select
zi
```

### fzf: Search Everything

```bash
# Fuzzy search command history
Ctrl+R

# Fuzzy search files
Ctrl+T

# cd into directories
Alt+C
```

### lazygit: Git TUI

```bash
lg  # Full git interface
```

## The Keybindings

### Ghostty (macOS Cmd)

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
| `⌥ + X` | Close pane |

## The Install Script

Here's the beautiful part — one command to rule them all:

```bash
git clone https://github.com/irfancode/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash scripts/install.sh
```

The script:
1. Installs Homebrew if needed
2. Installs all packages (Ghostty, Zellij, Starship, eza, bat, fd, fzf, ripgrep, lazygit, zoxide)
3. Creates config directories
4. Symlinks all config files
5. Prints next steps

## What I Learned

### 1. Modern Tools Are Actually Good

I was skeptical of "modern replacements" for classic tools. But tools like ripgrep, fd, and eza genuinely outperform their predecessors — often by 10x or more.

### 2. Config-as-Code Pays Off

Having my entire terminal setup in a git repo means:
- I can set up a new machine in 5 minutes
- I can track changes and roll back
- I can share my setup with others

### 3. The Terminal Can Be Beautiful

We spend hours every day in our terminals. Why settle for "functional" when it can also be gorgeous?

## Before & After

### Before
```
Last login: Tue Apr 15 10:23:45 on ttys001
MacBook-Pro:~ irfan$ ls
Applications	Desktop		Documents	Downloads
MacBook-Pro:~ irfan$
```

### After
```
╭─[~/dotfiles]────────────────────────────────────────────[irfan]──╮
│  ⭐ master ±                                                   │
╰───────────────────────────────────────────────────────────────╯
❯ ls

📁 config    📄 README.md    📄 zshrc    📁 scripts    📁 .git
❯
```

## Get Started

```bash
# Clone the repo
git clone https://github.com/irfancode/dotfiles.git ~/dotfiles

# Run install
cd ~/dotfiles && bash scripts/install.sh

# Restart shell
exec zsh

# Open Ghostty
open -a Ghostty
```

## Conclusion

A great terminal setup isn't about showing off — it's about creating an environment where you *want* to work. Every millisecond saved, every keystroke avoided, every beautiful color scheme adds up.

Give it a try. Your future self will thank you.

## Resources

- [Ghostty](https://ghostty.org)
- [Zellij](https://zellij.dev)
- [Starship](https://starship.rs)
- [Catppuccin](https://github.com/catppuccin/catppuccin)
- [My Dotfiles](https://github.com/irfancode/dotfiles)
