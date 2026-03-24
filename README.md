# Mac App Sync

Backup and restore all your Mac apps on any new Mac.

## Features

- Export all Homebrew formulae and casks
- Export App Store apps (via mas)
- Export npm/pnpm/yarn global packages
- Export /Applications and ~/Applications
- One-command restore on new Mac

## Quick Start

### On Your Current Mac

```bash
# Clone or copy this repo
git clone https://github.com/irfancode/mac-app-sync.git
cd mac-app-sync

# Export your apps
./mac-app-sync.sh export
```

### On Your New Mac

```bash
# Clone your repo
git clone https://github.com/irfancode/mac-app-sync.git
cd mac-app-sync

# Install everything
./mac-app-sync.sh install
```

## Usage

| Command | Description |
|---------|-------------|
| `./mac-app-sync.sh export` | Save current apps to `exports/` |
| `./mac-app-sync.sh install` | Install apps from `exports/` |
| `./mac-app-sync.sh update` | Update packages, then install |
| `./mac-app-sync.sh sync` | Export + push to GitHub |

## Prerequisites for New Mac

1. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```

2. Homebrew will be auto-installed if missing

3. For App Store apps, you'll need to sign in with your Apple ID

## Exported Files

| File | Description |
|------|-------------|
| `exports/homebrew_formulas.txt` | CLI tools via Homebrew |
| `exports/homebrew_casks.txt` | GUI apps via Homebrew |
| `exports/app_store_apps.txt` | App Store apps |
| `exports/npm_packages.txt` | npm global packages |
| `exports/pnpm_packages.txt` | pnpm global packages |
| `exports/yarn_packages.txt` | yarn global packages |
| `exports/system_applications.txt` | /Applications apps |
| `exports/user_applications.txt` | ~/Applications apps |

## Manual Edits

Edit `exports/*.txt` files to customize your installation:
- Remove apps you don't want
- Add new apps
- Use `#` for comments

## Notes

- App Store apps export their App ID and name for mas CLI
- Some apps may require Rosetta 2 on Apple Silicon
- Some apps may require manual activation/license keys

## License

MIT
