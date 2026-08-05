# Mac App Sync

A comprehensive shell script solution to backup and restore all your Mac applications, development tools, and configurations to any new Mac.

## Features

- **Complete App Inventory**: Captures Homebrew formulae, casks, App Store apps, and more
- **Development Tools**: Exports npm, pnpm, yarn, pip, pipx, Ruby gems, and VS Code extensions
- **System Apps**: Lists all apps in `/Applications` and `~/Applications`
- **Configuration Backup**: Saves shell configs, Git config, and other dotfiles
- **Docker Support**: Exports Docker image list for later restoration
- **Interactive Installation**: Smart prompts and error handling
- **GitHub Sync**: Push your app list to GitHub for easy access anywhere

## Supported Package Managers

| Manager | What it manages |
|---------|-----------------|
| Homebrew | macOS/Linux CLI tools and GUI apps |
| npm | Node.js packages |
| pnpm | Node.js packages (alternative) |
| yarn | Node.js packages (alternative) |
| pip/pip3 | Python packages |
| pipx | Isolated Python applications |
| gem | Ruby gems |
| mas | Mac App Store applications |
| VS Code | Code editor extensions |

## Quick Start

### Step 1: Export on Current Mac

```bash
# Clone the repo
git clone https://github.com/irfancode/mac-app-sync.git
cd mac-app-sync

# Export all your apps
./mac-app-sync.sh export

# Push to GitHub for backup
./mac-app-sync.sh sync
```

### Step 2: Install on New Mac

```bash
# Clone your repo
git clone https://github.com/irfancode/mac-app-sync.git
cd mac-app-sync

# Install everything
./mac-app-sync.sh install
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `./mac-app-sync.sh export` | Export all apps and configs to `exports/` |
| `./mac-app-sync.sh install` | Install apps from exports/ |
| `./mac-app-sync.sh update` | Update existing packages, then install |
| `./mac-app-sync.sh sync` | Export and push to GitHub |
| `./mac-app-sync.sh list` | Show summary of exported items |
| `./mac-app-sync.sh verify` | Check if export files exist |
| `./mac-app-sync.sh clean` | Remove export files |
| `./mac-app-sync.sh help` | Show help message |

### Workflows

#### Initial Setup (on source Mac)
```bash
# Export your apps
./mac-app-sync.sh export

# Review what was exported
./mac-app-sync.sh list

# Edit exports as needed
nano exports/homebrew_casks.txt   # Remove apps you don't want
nano exports/npm_packages.txt      # Add custom packages

# Push to GitHub
./mac-app-sync.sh sync
```

#### Fresh Mac Setup
```bash
# Install Xcode Command Line Tools first
xcode-select --install

# Clone your repo (or copy the folder)
git clone https://github.com/irfancode/mac-app-sync.git
cd mac-app-sync

# Run installer
./mac-app-sync.sh install
```

#### Periodic Updates
```bash
# On source Mac - update and sync
./mac-app-sync.sh update
./mac-app-sync.sh sync
```

## Exported Files

The script creates these files in `exports/`:

| File | Description | Example |
|------|-------------|---------|
| `homebrew_formulas.txt` | CLI tools via Homebrew | git, curl, wget |
| `homebrew_casks.txt` | GUI apps via Homebrew | firefox, slack, docker |
| `app_store_apps.txt` | App Store apps (ID + Name) | `409183694 Keynote` |
| `system_applications.txt` | /Applications | Safari, Xcode |
| `user_applications.txt` | ~/Applications | Custom apps |
| `npm_packages.txt` | npm global packages | typescript, yarn |
| `pnpm_packages.txt` | pnpm global packages | - |
| `yarn_packages.txt` | yarn global packages | - |
| `pip_packages.txt` | pip global packages | black, flake8 |
| `pipx_packages.txt` | pipx packages | - |
| `gem_packages.txt` | Ruby gems | bundler, rake |
| `vscode_extensions.txt` | VS Code extensions | ms-python.python |
| `docker_images.txt` | Docker image list | nginx:latest |
| `mas_account.txt` | App Store account | your@email.com |

## Customization

### Excluding Apps

Edit the export files and:
- Add `#` before any line to comment it out
- Delete lines for apps you don't want
- Add new apps you want to install

Example `exports/homebrew_casks.txt`:
```
# firefox               # Don't reinstall Firefox
slack
# microsoft-office     # Don't want Office
visual-studio-code
```

### Adding Custom Apps

Add apps not captured by the script:
```
# Custom apps
my-special-tool
another-app
```

### Comment Syntax

Lines starting with `#` are treated as comments:
```
# Development tools
git
node
python@3.12

# Communication (commented out)
# slack
# discord
```

## Requirements

### For Export (Source Mac)
- macOS (Big Sur or later)
- Bash 3.2+
- Homebrew (optional but recommended)
- Git (optional, for sync feature)

### For Install (New Mac)
- macOS (Big Sur or later)
- Bash 3.2+
- Xcode Command Line Tools (`xcode-select --install`)
- Git (for cloning repo)
- Internet connection

### For App Store Apps
- Apple ID signed into Mac App Store
- Run `mas signin` after installation

## Troubleshooting

### "brew: command not found"
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### "mas: command not found"
```bash
# Install mas CLI
brew install mas
```

### "code: command not found"
Open VS Code and run: `Cmd+Shift+P` → "Shell Command: Install 'code' command in PATH"

### GitHub sync fails
```bash
# Login to GitHub CLI
gh auth login
```

### Installation fails for some packages
- Check `exports/install_log_*.txt` for errors
- Some packages may have different names on different macOS versions
- Some apps require manual license activation

### Apple Silicon (M1/M2/M3) issues
- Homebrew auto-detects and installs correctly
- Some Intel-only apps will need Rosetta 2:
  ```bash
  softwareupdate --install-rosetta
  ```

## File Structure

```
mac-app-sync/
├── mac-app-sync.sh      # Main orchestrator script
├── export_apps.sh       # Export all apps and configs
├── install_apps.sh      # Install apps from exports
├── README.md            # This file
├── LICENSE              # MIT License
├── .gitignore           # Git ignore file
├── exports/             # Exported app lists
│   ├── homebrew_formulas.txt
│   ├── homebrew_casks.txt
│   └── ...
└── configs/             # Saved configurations
    ├── gitconfig
    └── ...
```

## Advanced Usage

### Selective Installation

Install only specific categories by editing `install_apps.sh` or running specific commands:
```bash
# Only install Homebrew packages
./export_apps.sh && brew install $(cat exports/homebrew_formulas.txt)
./export_apps.sh && brew install --cask $(cat exports/homebrew_casks.txt)
```

### Export Without Git Tracking

```bash
./mac-app-sync.sh export
# Edit exports as needed
# Don't run sync - just copy the folder manually
```

### Using on Multiple Macs

Create separate export files for different Macs:
```bash
# Export from MacBook Air
./export_apps.sh
cp exports/homebrew_casks.txt exports/homebrew_casks_macbook_air.txt

# Export from MacBook Pro
# ... (switch Mac)
./export_apps.sh
cp exports/homebrew_casks.txt exports/homebrew_casks_macbook_pro.txt
```

### Docker Images

Docker images require special handling:
```bash
# Export on source Mac
docker save $(docker images -q) -o ~/docker_images.tar

# Import on new Mac
docker load -i ~/docker_images.tar
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on a fresh macOS installation
5. Submit a pull request

## License

MIT License - feel free to use, modify, and distribute.

## Credits

Created for macOS power users who frequently switch or set up new Macs.
