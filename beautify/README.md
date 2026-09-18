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
│   │   ├── hyper/      terminal/
│   │   ├── hyprland/  # Hyprland window border colors
│   │   └── nvim/      # Neovim colorscheme (chroma.lua)
├── config/
│   ├── ghostty/config          # Ghostty terminal config
│   │   #   font: JetBrainsMono Nerd Font Mono + Symbols Nerd Font fallback
│   │   #   theme: backs onto config-file = ?theme.ghostty (see install.sh)
│   ├── hyper/hyper.js          # Hyper 3.x base config (font/cursor/splits)
│   │   #   same NFM font; palette injected by scripts/hyper-apply-theme.js
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

Each theme ships ready-made configs for **Ghostty, Alacritty, Kitty, Foot, Hyper, macOS Terminal, Hyprland** (window borders) and a self-contained **Neovim** colorscheme (`nvim/chroma.lua`, loaded with `vim.cmd("colorscheme chroma-<theme>")`).

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

- **Best-in-class 2026 Hyper config** (`config/hyper/hyper.js`, mirrored in
  `provisioning/config/hyper/hyper.js`): full 3.4/3.5 config with
  `JetBrainsMono Nerd Font Mono` + `Symbols Nerd Font` fallback (icons remain
  exactly one cell wide), font smoothing/ligatures, cursor bar, padding,
  copy-on-select, 10k scrollback, splits/tabs/font-size keymaps. install_stack
  seeds `~/.hyper.js` if missing.
- **Hyper theme no longer overwrites your config**: `install.sh --theme` used
  to replace `~/.hyper.js` with a bare palette (dropping font/cursor/padding).
  It now runs `scripts/hyper-apply-theme.js`, which swaps only the Chroma
  palette keys and preserves the rich base config and any user edits.
- **Best-in-class 2026 Ghostty config** (`config/ghostty/config`, mirrored in
  `provisioning/config/ghostty/config`): switched to the **monospaced** Nerd
  Font build — `JetBrainsMono Nerd Font Mono` (+ bold/italic variants) with a
  `Symbols Nerd Font` fallback so every glyph renders at exactly one cell width
  (icons no longer drift off-grid). Added 1.3.x polish: `background-blur = 30`,
  `alpha-blending = linear-corrected`, `palette-generate`, `minimum-contrast`,
  grapheme-comparing, split/quick-terminal polish and full Cmd-based
  keybindings. Font casks: `font-jetbrains-mono-nerd-font` +
  `font-symbols-only-nerd-font` (install.sh + Brewfile + omamac defaults).
- **Ghostty theme no longer clobbers the main config**: previously
  `install.sh --theme` copied the palette over `~/.config/ghostty/config`,
  wiping the font/keybinding stack. It now writes
  `~/.config/ghostty/theme.ghostty`, which the main config pulls in with an
  optional `config-file = ?theme.ghostty` include.
- **Hyprland + Neovim variants** for all 10 themes: `themes/<name>/hyprland/`
  (window border colors from the palette) and `themes/<name>/nvim/chroma.lua`
  (self-contained 16-color colorscheme). `install.sh` copies both into
  `~/.config/hypr/hyprland.theme.conf` and `~/.config/nvim/colors/chroma.lua`
  and adds a `source` line to `hyprland.conf` so the border theme is loaded.
- **Chroma-colored single-line Starship prompt** (`config/starship.toml`):
  replaced the one-module-per-line format (which produced orphaned
  `on <branch>` rows and large vertical gaps) with a single compact line, and
  retargeted the palette from `catppuccin_mocha` to the Chroma `spectrum`
  palette so the prompt matches the Ghostty theme exactly.
- **Starship scan/performance tuning** (`config/starship.toml`): the `package`
  module scans the directory on every prompt; its default 30 ms budget aborts
  under transient I/O load (iCloud, Spotlight, builds) and prints warnings.
  Bumped `scan_timeout` to 500 ms and set `follow_symlinks = false` so the
  prompt never blocks or warns. Mirrored in
  `provisioning/config/starship/starship.toml`.
- **Shell integration hooks** (`config/zshrc`): kiro-cli now sources its
  `zshrc.pre.zsh` / `zshrc.post.zsh` blocks at the top/bottom of the file and
  `opencode`'s `bin/` is on `PATH` — both kept at the very edges so the rest of
  the config stays portable. Mirrored in
  `provisioning/config/zsh/.zshrc`.
- **New fastfetch config** (`config/fastfetch/config.jsonc`): auto logo with a
  palette-index tint, ordered vertically-padded stats, and custom keys. Shipped
  through both `beautify/install.sh` and `provisioning/bootstrap.sh`, so a
  fresh install gets a clean, tight system-info banner.
