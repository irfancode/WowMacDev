# macOS Dotfiles

Automated setup script for new Mac machines.

## What's Included

- **38 Homebrew formulae** (CLI tools)
- **30 Homebrew casks** (GUI applications)
- **84 VS Code extensions**

### Key Applications

| Category | Apps |
|----------|------|
| Browsers | Chrome, Firefox Dev Edition, Edge, Floorp, Zen, Dia |
| Dev Tools | VS Code, Docker, Neovim, Ghostty, Hyper, Warp, Zed |
| Productivity | Notion, Craft, Rectangle, Raycast, Spark |
| Microsoft | Word, Excel, PowerPoint, OneNote, OneDrive |
| Communication | WhatsApp, Messenger, Zoom |
| AI Tools | LM Studio, ChatGPT (via aichat CLI) |

### CLI Tools

- `fish` - Friendly interactive shell
- `neovim` - Modern Vim
- `starship` - Cross-shell prompt
- `fzf` - Fuzzy finder
- `ripgrep`, `fd`, `eza` - Modern replacements for grep, find, ls
- `bat` - Better cat
- `zoxide` - Smart cd
- `tmux` - Terminal multiplexer
- `k9s` - Kubernetes CLI
- `git`, `helm`, `kubectl` - DevOps tools

## Quick Start

### On a New Mac

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles

# Run the installer
chmod +x install.sh
./install.sh
```

### Update Brewfile

After installing new packages, update the Brewfile:

```bash
cd ~/dotfiles
./export.sh
git commit -am "Update Brewfile"
git push
```

## Manual Steps After Install

Some things can't be automated:

1. **Sign in to apps** - Most apps require manual sign-in
2. **macOS Settings** - Configure in System Preferences
3. **SSH keys** - Generate and add to GitHub/GitLab:
   ```bash
   ssh-keygen -t ed25519 -C "your@email.com"
   pbcopy < ~/.ssh/id_ed25519.pub
   # Add to GitHub/GitLab settings
   ```
4. **Git config** - Set your identity:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your@email.com"
   ```

## Files

| File | Description |
|------|-------------|
| `Brewfile` | All packages, casks, and VS Code extensions |
| `install.sh` | Main installation script |
| `export.sh` | Regenerate Brewfile from current system |

## Requirements

- macOS (tested on macOS Sonoma+)
- Admin privileges (for some installations)

## License

MIT
