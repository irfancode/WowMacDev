# Setting Up a New Mac: One Command, Zero Guessing

I recently got a new MacBook Air with the M4 chip. Like every developer,
I faced **the ritual**: install Homebrew, wait for Xcode CLT, remember
what CLI tools I actually use, search for that one config file, tweak
Dock settings, realize I forgot something, start over.

Then I realized: I've done this dance six times in my career. Why not
**encode it once and be done forever**?

---

## The Problem

When you get a new Mac, you need:

- **55+ Homebrew packages** (and remembering which ones)
- **12 desktop apps** (and finding each download page)
- **macOS preferences** (dark mode, key repeat, Dock behavior)
- **Language runtimes** (Node, Go, Rust, Python, Java — with specific versions)
- **CLI tools** that don't come from Homebrew (Neovim, fzf, bat, ripgrep, lsd)
- **Config files** for your terminal, editor, shell, prompt
- **Cloud CLIs** (AWS, Azure, GCP, Kubernetes, Terraform)
- **A way to stay updated** without manual checking

Each of these is a distraction from doing actual work.

---

## The Solution: One Repo to Rule Them All

I built [`mac-bootstrap`](https://github.com/<YOUR_USER>/mac-bootstrap) — a
single GitHub repository that provisions a complete development environment
on any Apple Silicon Mac running macOS 27.0+.

### The One-Liner

```bash
curl -fsSL https://raw.githubusercontent.com/<YOUR_USER>/mac-bootstrap/main/bootstrap.sh | bash
```

That's it. Walk away. Come back to a fully configured machine.

---

## How It Works

The bootstrap is structured in **5 phases**, each building on the last:

### Phase 0: Prerequisites (30 seconds)
Xcode Command Line Tools and Rosetta 2 — the foundation everything else
needs. The script detects what's missing and installs quietly.

### Phase 1: Homebrew (3-5 minutes)
A single `brew bundle` against a curated `Brewfile` installs everything
from `btop` to `azure-cli`. This is the largest phase because it pulls
in desktop apps like Notion, Office, and OrbStack.

### Phase 2: macOS Preferences (1 second)
Dark mode. Fast key repeat. Auto-hide Dock with zero delay. Tap to click.
Finder shows hidden files, path bar, extensions. Hot corners. These are
the tweaks I make on every Mac — now they're codified.

```bash
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write NSGlobalDomain KeyRepeat -int 1
```

### Phase 3: Developer Tools (2-3 minutes)
This is where the magic happens. Instead of compiling from source or
forcing every tool through Homebrew, the script downloads **pre-built
ARM64 binaries** from GitHub releases:

- **Neovim** — my daily driver editor (LazyVim-based)
- **Node.js** — v22 LTS, self-contained
- **Go** — latest stable, self-contained
- **Rust** — via rustup
- **fzf, ripgrep, bat, lsd, lazygit, zoxide, starship, gh** — all ARM64 binaries

Everything lands in `~/.local/bin/` and `~/.local/opt/`. No sudo, no
system pollution, no dependency hell.

```bash
install_gh_release "sharkdp/bat" "bat-*-aarch64-apple-darwin.tar.gz" "bat"
install_gh_release "lsd-rs/lsd" "lsd-*-aarch64-apple-darwin.tar.gz" "lsd"
```

### Phase 4: Shell & Configs (instant)
My entire terminal stack gets installed in one shot:

- **Ghostty** with Catppuccin Mocha theme, JetBrainsMono NF, 88% opacity
- **Starship** prompt with custom palette
- **Zsh** with 100+ aliases, autosuggestions, syntax highlighting, fzf integration
- **Neovim** config (LazyVim with LSP, treesitter, telescope, mason)
- **btop** resource monitor

### Phase 5: Self-Maintenance (instant)
The crown jewel: `update-tools` — a script that checks and updates
every tool in the stack with a single command.

```bash
# Check what's outdated
update-tools

# Update everything
update-tools --update
```

It knows about Neovim, Node.js, fzf, ripgrep, starship, zoxide, bat,
lsd, lazygit, gh, Homebrew, npm, and pip. It scrapes the latest GitHub
release tags, compares versions, and upgrades cleanly.

---

## Why This Approach Works

### 1. It's Real
This isn't aspirational. Every tool in this repo is used daily.
The `system-snapshot.json` captures exact versions, preferences,
and disk layout from my actual machine.

### 2. It's Fast
ARM64 pre-built binaries download and extract in seconds. No `make`,
no `cmake`, no waiting for compilation.

### 3. It's Portable
Everything goes to `~/.local/` — no system files touched. Works on
any Apple Silicon Mac running macOS 27.0+.

### 4. It's Idempotent
Run it once, run it ten times. Same result. Configs are backed up
before overwriting.

### 5. It's Self-Maintaining
The `update-tools` script means I never have to think about updates
again. A daily LaunchAgent checks silently; I run `update-tools --update`
when I want to upgrade.

---

## The Stack at a Glance

```
┌─────────────────────────────────────────────┐
│               Terminal                       │
│  Ghostty + Starship + Zsh + fzf + zoxide    │
├─────────────────────────────────────────────┤
│                Editor                        │
│          Neovim (LazyVim)                    │
├─────────────────────────────────────────────┤
│         Language Runtimes                    │
│  Node 22  Go 1.26  Rust 1.96  Python 3.14   │
├─────────────────────────────────────────────┤
│        Containers & Orchestration            │
│  OrbStack  Docker  kind  k9s  Helm  kustom. │
├─────────────────────────────────────────────┤
│         Infrastructure as Code              │
│  Terraform  Packer  Ansible  sops  age       │
├─────────────────────────────────────────────┤
│         Cloud CLIs                           │
│  AWS  Azure  GCP  1Password                  │
├─────────────────────────────────────────────┤
│         CLI Power Tools                      │
│  bat  rg  lsd  lazygit  procs  btop  duf    │
│  doggo  httpie  yq  speedtest  mtr  ncdu    │
├─────────────────────────────────────────────┤
│         Applications                         │
│  Firefox Nightly  Zen  Notion  Office        │
│  WhatsApp  Spark  Rectangle  Zoom           │
└─────────────────────────────────────────────┘
```

---

## Steal This Setup

The entire repo is MIT-licensed. Fork it, customize it, make it yours:

```bash
git clone https://github.com/<YOUR_USER>/mac-bootstrap.git
```

Three things to change:

1. **`Brewfile`** — swap packages you don't use
2. **`config/`** — drop in your own zshrc, ghostty config, nvim config
3. **`install/macos.sh`** — adjust defaults to your taste

Then push to your own GitHub and the one-liner is ready.

---

## The Result

After running the bootstrap on a clean MacBook Air M4, I had:

- 55 Homebrew packages installed and current
- 12 desktop applications ready to launch
- A terminal that feels like home (Ghostty + Starship + Catppuccin)
- Neovim with full LSP, treesitter, and telescope
- All language runtimes at their latest stable versions
- Kubernetes tooling (kubectl, helm, kind, k9s)
- Cloud CLIs authenticated and ready
- Every CLI tool I reach for daily
- An auto-updater that keeps it all fresh

Time spent: **~8 minutes** (most of it waiting on downloads).
Previously: **half a day** of context-switching and "what was that tool called?"

---

## What's Next

I'm considering adding:

- **macOS restore from backup** (Desktop, Documents, etc.)
- **SSH key generation and GitHub setup**
- **Git config with signing**
- **Docker image cache pre-warming**

But honestly, 80% of the pain is gone. The last 20% is personal
(credentials, dotfiles for specific projects). And now when I get
my next Mac, I'll run one command and be coding in 10 minutes.

---

*Want the code? [github.com/<YOUR_USER>/mac-bootstrap](https://github.com/<YOUR_USER>/mac-bootstrap)*
