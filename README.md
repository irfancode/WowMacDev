# Chroma Terminal Themes

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License">
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome">
  <img src="https://img.shields.io/badge/themes-10-ff6ac1.svg" alt="10 Themes">
  <img src="https://img.shields.io/badge/terminals-7-5af78e.svg" alt="7 Terminals">
  <img src="https://img.shields.io/badge/maintained-yes-ffd500.svg" alt="Maintained">
</p>

<p align="center">
  <b>10 beautiful themes</b> · <b>7 terminal emulators</b> · <b>1 command setup</b>
</p>

<p align="center">
  <i>Beautiful color schemes for Ghostty, Alacritty, Warp, Hyper.js, Foot, Kitty, and macOS Terminal.app — inspired by Monokai Pro</i>
</p>

---

```
  ╔══════════════════════════════════════════════════════════════╗
  ║                                                              ║
  ║    █████╗ ██╗  ██╗ ██████╗  ██████╗  ███╗   ███╗ █████╗    ║
  ║  ██╔════╝ ██║  ██║ ██╔══██╗ ██╔═══██╗ ████╗ ████║ ██╔══██╗ ║
  ║  ██║      ███████║ ██████╔╝ ██║   ██║ ██╔████╔██║ ███████║ ║
  ║  ██║      ██╔══██║ ██╔══██╗ ██║   ██║ ██║╚██╔╝██║ ██╔══██║ ║
  ║  ╚██████╗ ██║  ██║ ██║  ██║ ╚██████╔╝ ██║ ╚═╝ ██║ ██║  ██║ ║
  ║    ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝  ╚════╝  ╚═╝     ╚═╝ ╚═╝  ╚═╝ ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝
```

```
  ╔══════════════════════════════════════════════════════════════════╗
  ║  ┌────────────────────────────────────────────────────────────┐  ║
  ║  │  ~ » ls -la                    ┌─────┐                     │  ║
  ║  │  drwxr-xr-x  16 irfan  staff   │ ● ● │   ~ » _           │  ║
  ║  │  -rw-r--r--   1 irfan  staff   │ └───┘                     │  ║
  ║  │  -rwxr-xr-x   1 irfan  staff   │                          │  ║
  ║  │  ~ » git status                │                    │  ║
  ║  │  On branch main                │                          │  ║
  ║  │  nothing to commit              └──────────────────────────┘  ║
  ║  └────────────────────────────────────────────────────────────┘  ║
  ╚══════════════════════════════════════════════════════════════════╝
```

---

## 🎨 Theme Comparison

| # | Theme | Background | Foreground | Accent | Vibe |
|-------|-------|-----------|------------|--------|------|
| 1 | **Spectrum** | ⬤ `#2D2A2E` | ⬤ `#FCFCFA` | ⬤ `#FF6188` | Classic — the original full palette |
| 2 | **Solar** | ⬤ `#2D2A2E` | ⬤ `#FCFCFA` | ⬤ `#FC9867` | Warm amber tones |
| 3 | **Tidal** | ⬤ `#2D2A2E` | ⬤ `#FCFCFA` | ⬤ `#78DCE8` | Cool ocean blues |
| 4 | **Canopy** | ⬤ `#2D2A2E` | ⬤ `#FCFCFA` | ⬤ `#A9DC76` | Lush forest greens |
| 5 | **Void** | ⬤ `#2D2A2E` | ⬤ `#FCFCFA` | ⬤ `#AB9DF2` | Deep midnight purples |
| 6 | **Aurora** | ⬤ `#2D2A2E` | ⬤ `#FCFCFA` | ⬤ `#FF6188` | Vibrant northern lights |
| 7 | **Clay** | ⬤ `#2D2A2E` | ⬤ `#FCFCFA` | ⬤ `#FC9867` | Earthy rust tones |
| 8 | **Frost** | ⬤ `#2D2A2E` | ⬤ `#FCFCFA` | ⬤ `#78DCE8` | Cool ice blues |
| 9 | **Nebula** | ⬤ `#2D2A2E` | ⬤ `#FCFCFA` | ⬤ `#AB9DF2` | Cosmic violet hues |
| 10 | **Forge** | ⬤ `#2D2A2E` | ⬤ `#FCFCFA` | ⬤ `#FF6188` | Fiery ember energy |

---

## ⚡ Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/irfancode/chroma-terminal/main/scripts/bootstrap.sh | bash
```

Or with the CLI tool:

```bash
curl -fsSL https://raw.githubusercontent.com/irfancode/chroma-terminal/main/utility/chroma-cli | bash -s -- --theme spectrum --terminal ghostty
```

---

## 🖥 Supported Terminals

| Terminal | Config File | Auto-Detect | Notes |
|----------|------------|-------------|-------|
| [Ghostty](https://ghostty.org) | `~/.config/ghostty/config` | ✅ | Full theme support |
| [Alacritty](https://alacritty.org) | `~/.config/alacritty/alacritty.toml` | ✅ | TOML format |
| [Warp](https://warp.dev) | `~/.warp/themes/` | ✅ | YAML format |
| [Hyper.js](https://hyper.is) | `~/.hyper.js` | ✅ | JS config |
| [Foot](https://codeberg.org/dnkl/foot) | `~/.config/foot/foot.ini` | ✅ | INI format |
| [Kitty](https://sw.kovidgoyal.net/kitty/) | `~/.config/kitty/kitty.conf` | ✅ | Conf format |
| [Terminal.app](https://support.apple.com/guide/terminal) | `~/Library/Preferences/com.apple.Terminal.plist` | ✅ | `.terminal` export |

---

## 🌈 Theme Showcase

Browse the `themes/` directory for all 10 Chroma themes:

| Directory | Description |
|-----------|-------------|
| `themes/spectrum/` | Classic full palette — warm, balanced, iconic |
| `themes/solar/` | Warm amber-toned vibes |
| `themes/tidal/` | Cool ocean-inspired blues |
| `themes/canopy/` | Lush forest greens |
| `themes/void/` | Deep midnight purples |
| `themes/aurora/` | Vibrant northern lights palette |
| `themes/clay/` | Earthy rust tones |
| `themes/frost/` | Cool ice blues |
| `themes/nebula/` | Cosmic violet hues |
| `themes/forge/` | Fiery ember energy |

Each theme directory contains config files for all supported terminals.

---

## 📦 Installation

### Ghostty

```bash
# Via the CLI tool
curl -fsSL https://raw.githubusercontent.com/irfancode/chroma-terminal/main/utility/chroma-cli | bash -s -- --theme spectrum --terminal ghostty

# Or manually — add to ~/.config/ghostty/config
palette = 0=#403E41
palette = 1=#FF6188
palette = 2=#A9DC76
palette = 3=#FFD500
palette = 4=#78DCE8
palette = 5=#AB9DF2
palette = 6=#78DCE8
palette = 7=#FCFCFA
palette = 8=#727072
palette = 9=#FF6188
palette = 10=#A9DC76
palette = 11=#FFD500
palette = 12=#78DCE8
palette = 13=#AB9DF2
palette = 14=#78DCE8
palette = 15=#FCFCFA
background = #2D2A2E
foreground = #FCFCFA
```

### Alacritty

```bash
curl -fsSL https://raw.githubusercontent.com/irfancode/chroma-terminal/main/utility/chroma-cli | bash -s -- --theme spectrum --terminal alacritty
```

Or copy the theme from `themes/spectrum/alacritty/spectrum.toml` into your `~/.config/alacritty/alacritty.toml`:

```toml
[colors]
[colors.primary]
background = "#2D2A2E"
foreground = "#FCFCFA"

[colors.normal]
black = "#403E41"
red = "#FF6188"
green = "#A9DC76"
yellow = "#FFD500"
blue = "#78DCE8"
magenta = "#AB9DF2"
cyan = "#78DCE8"
white = "#FCFCFA"

[colors.bright]
black = "#727072"
red = "#FF6188"
green = "#A9DC76"
yellow = "#FFD500"
blue = "#78DCE8"
magenta = "#AB9DF2"
cyan = "#78DCE8"
white = "#FCFCFA"
```

### Warp

```bash
curl -fsSL https://raw.githubusercontent.com/irfancode/chroma-terminal/main/utility/chroma-cli | bash -s -- --theme spectrum --terminal warp
```

Themes are installed to `~/.warp/themes/` as `.yaml` files. Select via Warp > Settings > Themes.

### Hyper.js

```bash
curl -fsSL https://raw.githubusercontent.com/irfancode/chroma-terminal/main/utility/chroma-cli | bash -s -- --theme spectrum --terminal hyper
```

Or edit `~/.hyper.js` and merge the theme plugin config.

### Foot

```bash
curl -fsSL https://raw.githubusercontent.com/irfancode/chroma-terminal/main/utility/chroma-cli | bash -s -- --theme spectrum --terminal foot
```

Or add the `[colors]` section to `~/.config/foot/foot.ini`.

### Kitty

```bash
curl -fsSL https://raw.githubusercontent.com/irfancode/chroma-terminal/main/utility/chroma-cli | bash -s -- --theme spectrum --terminal kitty
```

Or include the theme file in `~/.config/kitty/kitty.conf`.

### Terminal.app (macOS)

```bash
curl -fsSL https://raw.githubusercontent.com/irfancode/chroma-terminal/main/utility/chroma-cli | bash -s -- --theme spectrum --terminal terminal
```

Or double-click the `.terminal` file in `themes/spectrum/terminal/` and set as default.

---

## 🤝 How to Contribute

1. **Fork** the repo
2. **Add** a new theme or improve an existing one
3. **Submit** a PR with your changes

Guidelines:
- Keep the Chroma spirit — warm, vibrant, high-contrast where appropriate
- Ensure 16 ANSI colors + background + foreground are defined
- Test on at least one terminal before submitting
- Update the comparison table if adding a new theme

Run the validation script:

```bash
node scripts/validate.mjs themes/spectrum/alacritty/spectrum.toml
```

---

## 📄 License

MIT © 2025 [irfancode](https://github.com/irfancode)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

## 🙏 Credits & Inspiration

- **[Monokai Pro](https://monokai.pro)** by **Wimer Hazenberg** — the original, iconic color scheme that inspired everything here
- All **terminal emulator teams** for building incredible tools we use every day
- The **open source community** for making beautiful development environments accessible to everyone

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/irfancode">irfancode</a>
</p>
<p align="center">
  ⭐ Star us on GitHub — it helps!
</p>
