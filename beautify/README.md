# WowMacDev — Beautify

Unified terminal theming & setup toolkit, merged from:

| Upstream repo | What it contributed |
|---|---|---|
| `chroma-terminal` | 10 Chroma themes (Monokai Pro inspired) × 10 targets + theme applier |
| `dotfiles` | Ghostty + Zellij + Starship stack, shell config, Nix home/darwin config |

## Layout

```
beautify/
├── install.sh                  # ← unified installer (theme + stack)
├── themes/                     # 10 themes × 10 targets
│   ├── aurora/ canopy/ clay/ forge/ frost/
│   ├── nebula/ solar/ spectrum/ tidal/ void/
│   │   ├── ghostty/   alacritty/  kitty/  foot/
│   │   ├── warp/      hyper/      terminal/
│   │   ├── hyprland/  # Hyprland window border colors
│   │   └── nvim/      # Neovim colorscheme (chroma.lua)
├── config/
│   ├── ghostty/config          # Ghostty terminal config
│   ├── zellij/                 # Zellij multiplexer + Catppuccin theme
│   ├── starship.toml           # Starship prompt — Chroma 'spectrum' palette
│   ├── fastfetch/config.jsonc  # fastfetch system-info layout + logo
│   └── zshrc                   # shell aliases, fzf/zoxide integration
└── nix/                        # home-manager + nix-darwin flake
```

`install.sh --theme <name>` writes a theme's files across every target it can
reach. `--only-stack` (or the same files under `provisioning/config/`) installs
the always-on stack configs — Ghostty, Zellij, **starship** and **fastfetch** —
so the prompt and system-info banner are Chroma-colored and tightly laid out.

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

Each theme ships ready-made configs for **Ghostty, Alacritty, Kitty, Foot, Warp, Hyper, macOS Terminal, Hyprland** (window borders) and a self-contained **Neovim** colorscheme (`nvim/chroma.lua`, loaded with `vim.cmd("colorscheme chroma-<theme>")`).

To use the Neovim theme with LazyVim, drop `nvim/chroma.lua` into `~/.config/nvim/colors/chroma.lua` and set `vim.cmd.colorscheme("chroma-spectrum")` (or whatever theme) in your config; `install.sh --theme <name>` copies it automatically.

## Fixes applied during consolidation

- **zshrc**: fixed `AICHAVT_*` → `AICHAT_*` typo; replaced the machine-specific
  `/nix/store/...fzf` path with a portable `commands[fzf]`-relative source.
- **nix/home.nix**: removed broken `../.gitconfig` / `../.vimrc` references;
  now symlinks the real `beautify/config` files.
- **nix/darwin-configuration.nix**: replaced invalid `global => {…}` Homebrew
  syntax with the standard `casks = [ … ]` list.
- The installer no longer mutates an existing `.hyper.js`/`alacritty.toml`
  destructively — user configs are backed up before appending.

## Recent changes

- **Hyprland + Neovim variants** for all 10 themes: `themes/<name>/hyprland/`
  (window border colors from the palette) and `themes/<name>/nvim/chroma.lua`
  (self-contained 16-color colorscheme). `install.sh` copies both into
  `~/.config/hypr/hyprland.theme.toml` and `~/.config/nvim/colors/chroma.lua`.
- **Chroma-colored single-line Starship prompt** (`config/starship.toml`):
  replaced the one-module-per-line format (which produced orphaned
  `on <branch>` rows and large vertical gaps) with a single compact line, and
  retargeted the palette from `catppuccin_mocha` to the Chroma `spectrum`
  palette so the prompt matches the Ghostty theme exactly.
- **New fastfetch config** (`config/fastfetch/config.jsonc`): auto logo with a
  palette-index tint, ordered vertically-padded stats, and custom keys. Shipped
  through both `beautify/install.sh` and `provisioning/bootstrap.sh`, so a
  fresh install gets a clean, tight system-info banner.
