# WowMacDev — Beautify

Unified terminal theming & setup toolkit, merged from:

| Upstream repo | What it contributed |
|---|---|
| `chroma-terminal` | 10 Chroma themes (Monokai Pro inspired) × 7 terminals + theme applier |
| `dotfiles` | Ghostty + Zellij + Starship stack, shell config, Nix home/darwin config |

## Layout

```
beautify/
├── install.sh                  # ← unified installer (theme + stack)
├── themes/                     # 10 themes × 7 terminal formats
│   ├── aurora/ canopy/ clay/ forge/ frost/
│   ├── nebula/ solar/ spectrum/ tidal/ void/
│   │   ├── ghostty/   alacritty/  kitty/  foot/
│   │   └── warp/      hyper/      terminal/
├── config/
│   ├── ghostty/config          # Ghostty terminal config
│   ├── zellij/                 # Zellij multiplexer + Catppuccin theme
│   ├── starship.toml           # Starship prompt
│   └── zshrc                   # shell aliases, fzf/zoxide integration
└── nix/                        # home-manager + nix-darwin flake
```

## Quick start

```bash
# Apply a theme + install the full stack (interactive theme picker)
./install.sh

# Apply a specific theme, install stack
./install.sh --theme spectrum

# Only apply the theme (no tools/configs)
./install.sh --theme void --no-stack

# Only install tools & configs (leave your theme alone)
./install.sh --only-stack

# Preview everything
./install.sh --theme spectrum --dry-run

# List themes
./install.sh --list
```

## Themes

| Theme | Vibe | Palette base |
|---|---|---|
| `spectrum` | Classic Chroma | Monokai Pro neutral |
| `aurora` | Northern lights | Pink/red accents |
| `void` | Midnight minimal | Deep black + red |
| `nebula` | Cosmic | Violet + pink |
| `solar` | Warm amber | Warm neutrals |
| `frost` | Ice blues | Cool blues |
| `forge` | Ember | Rust/orange |
| `tidal` | Ocean | Deep blue + pink |
| `clay` | Forest earth | Green/brown |
| `canopy` | Forest canopy | Green/red |

Each theme ships ready-made configs for **Ghostty, Alacritty, Kitty, Foot, Warp, Hyper, and macOS Terminal**.

## Fixes applied during consolidation

- **zshrc**: fixed `AICHAVT_*` → `AICHAT_*` typo; replaced the machine-specific
  `/nix/store/...fzf` path with a portable `commands[fzf]`-relative source.
- **nix/home.nix**: removed broken `../.gitconfig` / `../.vimrc` references;
  now symlinks the real `beautify/config` files.
- **nix/darwin-configuration.nix**: replaced invalid `global => {…}` Homebrew
  syntax with the standard `casks = [ … ]` list.
- The installer no longer mutates an existing `.hyper.js`/`alacritty.toml`
  destructively — user configs are backed up before appending.
