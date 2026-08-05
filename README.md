# WowMacDev 🚀

**Master consolidated repository for all of my macOS development tooling.**

A monorepo that unifies 13 repositories for provisioning, diagnosing, monitoring, and beautifying macOS — one command, one home, one source of truth.

## The Four Pillars

| Pillar | What it does | Repos |
|--------|-------------|-------|
| **Provision** | Fresh Mac → full dev stack in one command | `omamac`, `mac-bootstrap`, `mac-catalyst`, `mac-app-sync`, `mac-dev-setup` |
| **Diagnose** | Health check 16+ components in ~2s | `macOS-System-Diagnostics`, `macos-setup-tools` |
| **Monitor** | System resource & admin management | `MacAdmin`, `Mac-Sysmon` |
| **Beautify** | Beautiful, ergonomic terminal setup | `chroma-terminal`, `dotfiles` |

## Quick Start

Provision a new Mac:

```bash
curl -fsSL https://raw.githubusercontent.com/irfancode/WowMacDev/main/mac-bootstrap/bootstrap.sh | bash
```

Diagnose system health:

```bash
bash macOS-System-Diagnostics/diagnose-mac.sh
```

Install terminal themes:

```bash
cd chroma-terminal && bash utility/install.sh
```

## Repo Map

```
WowMacDev/
├── omamac/                        # Declarative, reversible, verifiable Mac setup (Go binary)
├── mac-bootstrap/                 # One-command full environment provisioning
├── mac-catalyst/                  # Recreate your dev environment on any machine
├── mac-app-sync/                  # Backup & restore apps, tools, and configs
├── mac-dev-setup/                 # Forward Deployment Engineering setup guide
├── macOS-System-Diagnostics/      # 16+ component health check in ~2 seconds
├── macos-setup-tools/             # Setup, diagnostics, performance, disk scripts
├── MacAdmin/                      # Native macOS system administration (React + FastAPI)
├── Mac-Sysmon/                    # System resource monitor (placeholder)
├── MacAdmin-master/               # Placeholder (empty upstream)
├── MacDevEnv/                     # Placeholder (empty upstream)
├── chroma-terminal/               # 10 Monokai Pro-inspired themes, 7 terminals
└── dotfiles/                      # Ghostty + Zellij + Starship terminal stack
```

## Blog

- **[From Fresh Mac to Full Dev Stack: The WowMacDev Way](blog/wowmacdev-from-fresh-mac-to-full-dev-stack.md)** — the consolidated story behind this monorepo, merging the themes of all 13 repositories into one post.

## License

Each subproject retains its original license. See individual directories for details.
