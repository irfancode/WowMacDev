# WowMacDev 🚀

**Master consolidated repository for all of my macOS development tooling.**

A monorepo that unifies 13 repositories for provisioning, diagnosing, monitoring, and beautifying macOS — one command, one home, one source of truth.

## The Four Pillars

| Pillar | Folder | What it does | Merges |
|--------|--------|-------------|--------|
| **Provision** | `provisioning/` | Fresh Mac → full dev stack in one command | `omamac`, `mac-bootstrap`, `mac-catalyst`, `mac-app-sync`, `mac-dev-setup`, `macos-setup-tools` |
| **Diagnose** | `diagnostics/` | Health check, performance, disk, and optimization scripts | `macOS-System-Diagnostics`, `macos-setup-tools` |
| **Monitor** | `monitoring/` | System resource & admin management (React + FastAPI) | `MacAdmin`, `Mac-Sysmon` |
| **Beautify** | `beautify/` | Beautiful, ergonomic terminal setup | `chroma-terminal`, `dotfiles` |

## Quick Start

Provision a new Mac (one command):

```bash
bash provisioning/provision.sh bootstrap
```

Or via a sub-command (install / export / analyze / diff):

```bash
bash provisioning/provision.sh install   # install Brewfile packages
bash provisioning/provision.sh analyze   # summarize the Brewfile
bash provisioning/provision.sh diff      # installed vs Brewfile
```

Diagnose system health (quick / serial / JSON modes):

```bash
bash diagnostics/diagnose.sh          # quick health check
bash diagnostics/performance.sh       # real-time performance monitoring
bash diagnostics/disk-usage.sh        # disk usage
bash diagnostics/optimize.sh          # 20-step macOS customization
```

Install terminal themes and the CLI stack:

```bash
bash beautify/install.sh                       # full stack + default theme
bash beautify/install.sh --list                # list the 10 themes
bash beautify/install.sh --theme spectrum      # apply just a theme
bash beautify/install.sh --no-stack --theme void
```

Run the monitoring web dashboard (backend FastAPI + React frontend):

```bash
cd monitoring/macadmin/backend && pip install -r requirements.txt && uvicorn app.main:app --reload
cd monitoring/macadmin/frontend && npm install && npm run dev   # → http://localhost:5173
```
## Repo Map

```
WowMacDev/
├── provisioning/     # provision.sh unified CLI + Brewfile + sync/ + omamac engine
│   ├── provision.sh          # bootstrap / install / export / analyze / diff / apps / omamac delegate
│   ├── Brewfile              # 72 formulae, 33 casks, 84 VS Code extensions
│   ├── bootstrap.sh          # one-shot fresh-Mac bootstrap
│   ├── catalyst-install.sh    # reinstall your dev environment on any machine
│   ├── install/             # dev-tools.sh, macos.sh, brew.sh
│   ├── config/             # btop, ghostty, nvim, starship, zsh
│   ├── sync/               # export/install apps + configs (backup & restore)
│   ├── sync/               # export/install apps + configs (backup & restore)
│   └── omamac/             # declarative, reversible, verifiable Go setup engine
├── diagnostics/            # diagnose.sh, performance.sh, disk-usage.sh, optimize.sh, lib/ common.sh
├── monitoring/             # macadmin/ — React + FastAPI admin dashboard
├── beautify/               # install.sh + themes/ (10 themes) + config/ + nix/
└── blog/                   # Jekyll blog with the consolidated WowMacDev story
```

## Blog

- **[From Fresh Mac to Full Dev Stack: The WowMacDev Way](blog/wowmacdev-from-fresh-mac-to-full-dev-stack.md)** — the consolidated story behind this monorepo, merging the themes of all 13 repositories into one post.

## License

Each subproject retains its original license. See individual directories for details.