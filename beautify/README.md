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
│   ├── starship.light.toml     # high-contrast light prompt (profile light)
│   ├── fastfetch/config.jsonc  # fastfetch system-info layout + logo
│   ├── zshrc                   # thin loader: sources config/zsh/*.zsh in order
│   └── zsh/                    # ← the shell, split by concern
│       ├── 00-paths.zsh        #   PATH, de-duplicated and ordered
│       ├── 05-exports.zsh     #   LESS/GIT_PAGER/AWS_PAGER…
│       ├── 10-history.zsh      #   history file, sharing, trimming
│       ├── 20-keys.zsh        #   ZLE key bindings
│       ├── 30-tools.zsh       #   eza/bat/fd/rg aliases, watch
│       ├── 45-git.zsh         #   git aliases
│       ├── 50-fzf.zsh         #   fzf + history/file/dir pickers
│       ├── 55-zoxide.zsh      #   zoxide
│       ├── 60-cloud.zsh       #   AWS/Azure/GCP awareness
│       ├── 65-k8s.zsh         #   kubectl helpers + production guard
│       ├── 70-docker.zsh      #   docker helpers + guarded cleanup
│       ├── 80-functions.zsh   #   env-show, hget, killport, afzf…
│       ├── 90-prompt.zsh      #   Starship init + `profile`
│       └── 95-plugins.zsh     #   autosuggestions, direnv, syntax-highlighting
├── scripts/
│   ├── make-terminal-profiles.swift   # creates the Dev:* Apple Terminal profiles
│   └── hyper-apply-theme.js
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

## The shell (Apple Terminal workstation)

`config/zshrc` is only a loader. It locates itself, then sources every
`config/zsh/NN-*.zsh` in numeric order, so each file stays small enough to read
in one sitting and a change is confined to one place.

```zsh
_zshrc="${ZDOTDIR:-$HOME}/.zshrc"
ZSH_CONFIG_DIR="${_zshrc:A:h}/zsh"
typeset -gU path PATH          # no duplicate PATH entries
for _f in "$ZSH_CONFIG_DIR"/[0-9][0-9]-*.zsh; do source "$_f"; done
```

Modules are plain `.zsh` files, not plugins, so there is no load order to
remember beyond the filename. The two kiro-cli `zshrc.pre/post` hooks are
preserved at the very top and bottom.

### Terminal profiles

`scripts/make-terminal-profiles.swift` creates five Apple Terminal profiles
under the `Dev:` prefix. Terminal stores its profiles in
`com.apple.Terminal`'s plist as archived `NSFont`/`NSColor` objects, which
cannot be hand-written — hence the Swift script rather than plist surgery.

| Profile | Use |
|---|---|
| `Dev:Default` | everyday work |
| `Dev:Production` | production alerting colours |
| `Dev:Remote` | high-contrast, for SSH boxes |
| `Dev:Light` | light background, AA-contrast prompt |
| `Dev:Focus` | no decorations |

Switch at any time with `profile <name>`, or run `profile` to list them. This
sets `STARSHIP_CONFIG` for the current shell *and* retints the running Terminal
windows, so the prompt and the window background always agree.

```zsh
profile            # list
profile light      # light window + starship.light.toml
profile default    # back to normal
```

Starship has no per-profile configuration, which is why
`~/.config/starship.light.toml` is a second symlink to the tracked file.

### Prompt

`config/starship.toml` is a single line. On the left: the last command's status,
directory, git branch with dirty state, and the command duration when it was
slow. On the right: host, cloud account, container, Kubernetes context, and
runtime versions — each appearing only when it is actually active.

Kubernetes contexts are colour-coded, and anything matching `prod`/`production`
is bold red. The `package` module is **disabled**: it forces a tree walk on
every prompt, and its timeout warnings are worse than the information is worth.

### Key bindings

| Keys | Action |
|---|---|
| `Ctrl+R` | fzf search over history |
| `Ctrl+T` | fzf pick files, insert into the buffer |
| `Alt+C` | fzf jump to a directory |
| `Ctrl+A` / `Ctrl+E` | start / end of line (Emacs muscle memory) |
| `Alt+E` | edit the whole line in `$EDITOR` |
| `Ctrl+Y` | paste from the system clipboard |
| `→` (End) | accept the autosuggestion |
| `Alt+←` / `Alt+→` | move by word |

### Safety guards

The old config had destructive commands behind friendly aliases. These are now
functions that refuse and explain:

- **`docker-clean`** used to be an unguarded `docker system prune -af`. It now
  reports what would go, asks for confirmation, and keeps volumes.
- **`kubectl`** in a production-looking context now requires typing `prod`
  before a mutating verb runs. Read-only verbs pass through untouched, and
  `KUBE_FORCE=1` bypasses it deliberately.
- **`awsprod`** refuses to run unless the profile actually looks like
  production.
- **`hget`** and the cloud helpers never mutate state or make a network call
  you did not ask for.

`cloud-env-report` reads the SDK config files on disk rather than shelling out,
so it stays instant and cannot make a stray network call from your prompt.

## Safety, update, uninstall

```bash
# update
git -C /Users/irfan/WowMacDev pull
cd /Users/irfan/WowMacDev/beautify && ./install.sh --only-stack   # relink + reinstall

# rebuild the Terminal profiles after a font or colour change
swift scripts/make-terminal-profiles.swift

# uninstall
rm ~/.zshrc ~/.config/starship.toml ~/.config/starship.light.toml
rm -rf ~/.config/starship
# then restore the old shell config from the newest backup:
ls -t config/.backup-*/ && cp config/.backup-<newest>/zshrc ~/.zshrc
```

`install.sh` never overwrites a previous `.zshrc` silently: it copies it into
`config/.backup-<timestamp>/zshrc` first.

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
  module scans the directory on every prompt and its timeout warnings are worse
  than the information is worth, so it is now `disabled = true` rather than
  merely given a bigger `scan_timeout`. `follow_symlinks = false` keeps the
  remaining git module from walking into linked trees.
- **Shell integration hooks** (`config/zshrc`): kiro-cli now sources its
  `zshrc.pre.zsh` / `zshrc.post.zsh` blocks at the top/bottom of the file and
  `opencode`'s `bin/` is on `PATH` — both kept at the very edges so the rest of
  the config stays portable. The rest of the shell moved into `config/zsh/`
  (see above), and the loader resolves its own directory so it works from any
  `ZDOTDIR`.
- **zsh-autosuggestions and zsh-syntax-highlighting are now actually loaded.**
  Both were installed via Homebrew in the old setup but never sourced, so they
  were dead weight while Powerlevel10k was installed and unused.
- **direnv now really works.** The previous hand-rolled `chpwd` hook activated
  a `.envrc` only by accident and never cleared the environment when you left
  the directory. It is replaced with direnv's own `eval "$(direnv hook zsh)"`,
  loaded before syntax-highlighting so the ZLE widgets it installs are wrapped.
- **PATH is de-duplicated and ordered.** It contained `.local/bin` three times
  and `.docker/bin` seven times, and `/usr/local/bin` came before
  `/opt/homebrew/bin`, so an old binary could shadow the one you just
  installed. `typeset -gU path PATH` plus an explicit order fixes both.
- **New `Dev:*` Apple Terminal profiles** with a light variant of the prompt
  (see above), selectable in one command via `profile`.
- **New fastfetch config** (`config/fastfetch/config.jsonc`): auto logo with a
  palette-index tint, ordered vertically-padded stats, and custom keys. Shipped
  through both `beautify/install.sh` and `provisioning/bootstrap.sh`, so a
  fresh install gets a clean, tight system-info banner.
