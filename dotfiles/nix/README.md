# Nix Configuration

Declarative package management for consistent development environment across all machines.

## Why Nix?

- **Reproducible** — Same config = same environment
- **Multi-version** — Run nodejs_18 and nodejs_20 side by side
- **Rollbacks** — Instant rollback if something breaks
- **Cross-platform** — Works on macOS + Linux

## Quick Start

### 1. Install Nix

```bash
sh <(curl https://nixos.org/nix/install) --daemon
```

### 2. Clone Dotfiles

```bash
git clone https://github.com/yourusername/dotfiles ~/dotfiles
cd ~/dotfiles/nix
```

### 3. Install Packages

```bash
# Using flake (recommended)
nix run .# --command nix-shell -p neovim nodejs_22 python312 --run zsh

# Or using nix-env
nix-env -f packages.nix -iA pkgs.neovim pkgs.nodejs_22
```

### 4. Enable Home Manager

```bash
# Install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/release.tar.gz home-manager
nix-channel update

# Apply configuration
home-manager switch -f home.nix
```

## Package List

### Developer Tools

| Package | Version | Notes |
|---------|---------|-------|
| neovim | latest | Vim-fork editor |
| nodejs | 22 | JavaScript runtime |
| python | 312 | Python runtime |
| git | latest | Version control |
| github-cli | latest | GitHub CLI |

### Languages

| Package | Version | Notes |
|---------|---------|-------|
| go | latest | Go compiler |
| rust | latest | Rust compiler |
| ruby | 3.3 | Ruby interpreter |

### CLI Utilities

| Package | Purpose |
|---------|---------|
| bat | Cat clone with syntax highlighting |
| eza | Modern ls replacement |
| fd | Fast find alternative |
| fzf | Fuzzy finder |
| ripgrep | Fast grep alternative |
| tmux | Terminal multiplexer |
| btop | System monitor |
| starship | Fast prompt |
| zellij | Terminal workspace |
| zoxide | Smart cd |
| yazi | Fast file navigator |
| lazygit | TUI git client |
| httpie | HTTP client |
| hugo | Static site generator |
| nushell | Modern shell |

## Usage Examples

```bash
# Enter development shell with all tools
nix-shell shell.nix

# Install a single package
nix-env -iA pkgs.neovim

# List installed packages
nix-env -q

# Uninstall package
nix-env -e neovim

# Rollback
nix-env --rollback
```

## File Structure

```
nix/
├── flake.nix              # Flake-based config (modern)
├── packages.nix          # Declarative packages
├── shell.nix            # Development shell
├── darwin-configuration.nix  # Nix Darwin (macOS)
├── home.nix             # Home Manager config
└── README.md           # This file
```

## Troubleshooting

### Permission Denied

If you get permission errors:
```bash
sudo chown -R $(whoami) /nix
```

### Binary Cache

Nix downloads from binary cache by default. To use custom cache:
```bash
mkdir -p ~/.config/nix
echo "substituters = https://cache.nixos.org https://nix-community.org" > ~/.config/nix/nix.conf
echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWzcy0ou3ROlCqRljwUP3S1oM1n猪noM=" >> ~/.config/nix/nix.conf
```

### Apple Silicon (M1/M2/M3)

Nix works on Apple Silicon but may need Rosetta:
```bash
softwareupdate --install-rosetta
```

## Alternatives

- **Homebrew** — Simpler, more packages, macOS-native
- **MacPorts** — Older, more isolation
- **Guix** — GNU's Nix fork

## More Resources

- [Nix Official](https://nixos.org)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/)
- [Home Manager](https://github.com/nix-community/home-manager)