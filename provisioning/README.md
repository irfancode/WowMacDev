# WowMacDev — Provisioning

Unified macOS provisioning toolkit, merged from five upstream repos:

| Upstream repo | What it contributed |
|---|---|
| `omamac` | Declarative, reversible, verifiable setup engine (Go binary, modules, plugins, journal, backup/restore) |
| `mac-bootstrap` | One-shot fresh-Mac bootstrap (Brewfile, config files, install scripts, inventory) |
| `mac-catalyst` | Brewfile-driven install/export/analyze/diff workflow with dry-run |
| `mac-app-sync` | Cross-machine app/config backup & restore (brew, npm, pip, gem, mas, VS Code, Docker) |
| `mac-dev-setup` | Forward Deployment Engineer toolchain guide (superseded by bootstrap) |

## Layout

```
provisioning/
├── provision.sh              # ← unified CLI entry point
├── bootstrap.sh              # one-shot fresh-Mac setup (Phases 0-5)
├── Brewfile                  # consolidated package list (formulae + casks + vscode)
├── catalyst-install.sh       # original mac-catalyst installer (brew bundle)
├── install/                  # bootstrap phase scripts
│   ├── brew.sh               # Homebrew + `brew bundle install`
│   ├── macos.sh              # macOS preferences
│   ├── dev-tools.sh          # Node, Go, Neovim, fzf, etc.
│   └── mas-list.txt          # App Store app IDs
├── config/                   # dotfile configs (zsh, starship, ghostty, btop, nvim)
├── scripts/update-tools.sh   # daily updater + launch agent
├── sync/                     # app-sync engine
│   ├── export_apps.sh        # export all app/config manifests
│   ├── install_apps.sh       # restore on a new Mac
│   ├── export-brewfile.sh    # brew bundle dump → Brewfile
│   ├── diff.sh               # compare installed vs Brewfile
│   ├── analyze.sh            # summarize the Brewfile
│   ├── exports/              # generated manifests (git-tracked)
│   └── configs/              # saved shell/git configs
├── inventory/system-snapshot.json
└── omamac/                   # the Go engine (see its own README)
```

## Quick start

```bash
# One-shot fresh-Mac setup (install + configs + dotfiles + updater)
./provision.sh bootstrap

# Or step by step:
./provision.sh install     # brew bundle install from Brewfile
./provision.sh export      # capture current brew state → Brewfile
./provision.sh diff        # what's missing / extra vs Brewfile
./provision.sh analyze     # summary of the Brewfile

# Cross-machine app sync
./provision.sh apps export      # snapshot apps & configs to sync/exports/
./provision.sh apps install     # restore on a new Mac
./provision.sh apps sync        # export + push to GitHub
./provision.sh apps list        # show exported item counts

# Advanced engine
./provision.sh omamac install --dry-run
./provision.sh omamac doctor
./provision.sh omamac backup
```

## Design notes

- **omamac** remains the opinionated, production-shaped engine: modules with
  `install/update/remove/verify` hooks, an append-only journal for safe
  rollback, and `backup`/`restore`. `mac-bootstrap` provides the battle-tested
  one-liner path; both read from the same consolidated `Brewfile`.
- The `apps export/install` flow captures far more than brew: npm/pnpm/yarn,
  pip/pipx, Ruby gems, App Store apps, VS Code extensions, Docker images, and
  shell/git configs — so a new Mac can be rebuilt from `sync/exports/`.
- All entry points are `set -euo pipefail` safe and idempotent.
