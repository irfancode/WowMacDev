<p align="center">
  <img src="https://img.shields.io/badge/macOS-Sonoma%2B-blue?style=for-the-badge&logo=apple" alt="macOS">
  <img src="https://img.shields.io/badge/Homebrew-4.0%2B-orange?style=for-the-badge&logo=homebrew" alt="Homebrew">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Version-1.0.0-purple?style=for-the-badge" alt="Version">
</p>

<h1 align="center">Mac Catalyst</h1>
<p align="center"><strong>Recreate your macOS development environment on any machine in minutes</strong></p>

<p align="center">
  <a href="#-features">Features</a> •
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-usage">Usage</a> •
  <a href="#-whats-included">What's Included</a> •
  <a href="#-configuration">Configuration</a>
</p>

---

## Features

- **One-command setup** - Install all your apps, CLI tools, and VS Code extensions with a single command
- **Dry-run mode** - Preview what will be installed before making any changes
- **Idempotent** - Run multiple times safely; already-installed packages are skipped
- **Cross-architecture** - Works on both Apple Silicon and Intel Macs
- **Auto-updates Brewfile** - Export your current setup anytime with one command
- **Diff tool** - Compare your current system against the Brewfile
- **Detailed logging** - Colorful, informative output with progress tracking

---

## Quick Start

### On a New Mac

```bash
# Clone the repository
git clone https://github.com/irfancode/mac-catalyst.git
cd mac-catalyst

# Run the installer
./install.sh
```

### Preview Installation (Dry Run)

```bash
./install.sh --dry-run
```

---

## Usage

### Installation Script

```bash
./install.sh [OPTIONS]
```

| Option | Description |
|--------|-------------|
| `-n, --dry-run` | Show what would be installed without making changes |
| `-v, --verbose` | Enable detailed output with full package lists |
| `--skip-rosetta` | Skip Rosetta 2 installation (Apple Silicon) |
| `--skip-shell` | Skip shell configuration prompts |
| `-h, --help` | Show help message |

### Export Script

After installing new packages, update your Brewfile:

```bash
./export.sh              # Export current setup to Brewfile
./export.sh --dry-run    # Preview what would be exported
```

### Analyze Script

View a detailed breakdown of your Brewfile:

```bash
./analyze.sh
```

### Diff Script

Compare installed packages vs Brewfile:

```bash
./diff.sh
```

Shows:
- **Missing** - Packages in Brewfile but not installed
- **Extra** - Packages installed but not in Brewfile

---

## What's Included

### CLI Tools (38 packages)

| Category | Tools |
|----------|-------|
| **Shell** | `fish`, `starship`, `zoxide`, `tmux` |
| **Editor** | `neovim`, `tree-sitter`, `luarocks` |
| **Git** | `git`, `gh` (via install script) |
| **Search** | `ripgrep`, `fd`, `fzf`, `ffind` |
| **Listing** | `eza`, `lsd`, `bat`, `tree` |
| **System** | `htop`, `btop`, `bottom`, `macos-trash` |
| **Dev** | `node`, `nvm`, `pnpm`, `yarn`, `python@3.13` |
| **DevOps** | `kubectl`, `k9s`, `helm`, `docker` (cask) |
| **AI** | `aichat` |
| **Utils** | `wget`, `tldr`, `topgrade` |

### GUI Applications (30 apps)

| Category | Applications |
|----------|--------------|
| **Browsers** | Chrome, Firefox Developer Edition, Edge, Floorp, Zen, Dia |
| **Terminals** | Ghostty, Hyper, Warp |
| **Editors** | VS Code, Zed |
| **Dev Tools** | Docker Desktop, Kiro CLI, LM Studio |
| **Productivity** | Notion, Craft, Rectangle, Raycast |
| **Microsoft** | Word, Excel, PowerPoint, OneNote, OneDrive |
| **Communication** | WhatsApp, Messenger, Spark, Zoom |
| **Fonts** | Fira Code, JetBrains Mono (Nerd Fonts) |

### VS Code Extensions (84 extensions)

| Category | Extensions |
|----------|------------|
| **Python** | Python, Pylance, Black, isort, Jupyter, debugpy |
| **Azure** | App Service, Functions, Bicep, Containers, CosmosDB |
| **AWS** | AWS Toolkit, Amazon Q |
| **Git** | GitLens, Git History, Git Ignore |
| **Themes** | One Dark, Dracula, Tokyo Night, Material Theme |
| **AI** | GitHub Copilot Chat, Gemini Code Assist |
| **DevOps** | Kubernetes, Docker, Helm |
| **Languages** | Go, Astro, MDX, YAML |
| **Utils** | Prettier, ESLint, Markdownlint, Spell Checker |

---

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                     Mac Catalyst Workflow                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  CURRENT MAC                          NEW MAC                    │
│  ───────────                          ────────                   │
│                                                                  │
│  ┌─────────────┐                    ┌─────────────┐             │
│  │ Install new │                    │ Clone repo  │             │
│  │   apps...   │                    │             │             │
│  └──────┬──────┘                    └──────┬──────┘             │
│         │                                  │                     │
│         ▼                                  ▼                     │
│  ┌─────────────┐                    ┌─────────────┐             │
│  │ ./export.sh │                    │ ./install.sh│             │
│  │             │                    │             │             │
│  │ Brewfile    │  ──── GitHub ────▶ │ installs    │             │
│  └──────┬──────┘                    │ everything  │             │
│         │                           └──────┬──────┘             │
│         ▼                                  │                     │
│  ┌─────────────┐                           │                     │
│  │ git commit  │                           ▼                     │
│  │ && git push │                    ┌─────────────┐             │
│  └─────────────┘                    │  Done! 🎉   │             │
│                                     └─────────────┘             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
mac-catalyst/
├── Brewfile           # All packages, casks, and extensions
├── install.sh         # Main installation script
├── export.sh          # Export current setup to Brewfile
├── analyze.sh         # Analyze Brewfile contents
├── diff.sh            # Compare system vs Brewfile
└── README.md          # This file
```

---

## Post-Installation Steps

Some things can't be automated:

1. **Sign in to apps** - Most applications require manual authentication
2. **macOS Settings** - Configure System Preferences to your liking
3. **Git configuration**:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your@email.com"
   ```
4. **SSH keys** - Generate and add to GitHub/GitLab:
   ```bash
   ssh-keygen -t ed25519 -C "your@email.com"
   pbcopy < ~/.ssh/id_ed25519.pub
   # Add to GitHub/GitLab settings
   ```

---

## Examples

### Full verbose installation
```bash
./install.sh --verbose
```

### Dry run with verbose output
```bash
./install.sh -nv
```

### Quick installation (skip prompts)
```bash
./install.sh --skip-shell
```

### Export and commit in one go
```bash
./export.sh && git add Brewfile && git commit -m "Update: $(date +%Y-%m-%d)" && git push
```

---

## Requirements

- macOS Sonoma or later
- Admin privileges (for some installations)
- Internet connection

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/irfancode">irfancode</a>
</p>
