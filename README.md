<p align="center">
  <img src="https://img.shields.io/badge/macOS-27.0+-black?style=for-the-badge&logo=apple&logoColor=white" alt="macOS">
  <img src="https://img.shields.io/badge/Apple%20Silicon-M4-blue?style=for-the-badge&logo=apple&logoColor=white" alt="Apple Silicon">
  <img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge" alt="MIT">
</p>

<div align="center">
  <h1>mac-bootstrap</h1>
  <p><strong>Set up a new Mac exactly like mine — with one command.</strong></p>
  <p>This repo captures every tool, setting, and configuration from a real MacBook Air M4 (macOS 27.0).<br>
  Run the command below on any new Mac, and it will install everything automatically.</p>
</div>

---

## Step-by-Step Quick Start

### Step 1: Open Terminal

On your new Mac:

1. Press **Command + Space** to open Spotlight Search
2. Type **Terminal**
3. Press **Enter**

A black (or white) window will appear with a blinking cursor. This is the Terminal — it's how we'll install everything.

### Step 2: Run This One Command

Copy and paste this entire line into Terminal, then press **Enter**:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/irfancode/mac-bootstrap/main/bootstrap.sh)"
```

**What happens next:** The Terminal will start printing messages. This is normal. It will take **30–60 minutes** depending on your internet speed. You don't need to do anything — just let it run.

> **Note:** If you see a popup asking you to install "Xcode Command Line Tools" or to enter your password, just follow the on-screen instructions.

### Step 3: Restart Terminal

When the script finishes, close the Terminal window and open it again (Command + Space → "Terminal" → Enter).

Your Mac is now fully set up! You'll see a colored prompt with icons — that means everything worked.

---

## What Gets Installed

Here's everything the script installs on your Mac:

| Category | What You Get | Why You Want It |
|---|---|---|
| **Terminal** | Ghostty + JetBrainsMono font | A beautiful, modern terminal that's way better than the default |
| **Shell** | Starship prompt + FZF + Zoxide | A colorful prompt and instant file/cd search |
| **Languages** | Node.js, Python, Go, Rust, Java, Zig | Run almost any programming language |
| **Git** | Git + GitHub CLI (`gh`) | For downloading code from GitHub |
| **Docker** | Docker Desktop | Run apps in containers (like a lightweight virtual machine) |
| **Kubernetes** | kubectl, Helm, k9s | The industry standard for running containers at scale |
| **Databases** | SQLite, MySQL client, PostgreSQL, MongoDB | Work with databases locally |
| **Editors** | Neovim (advanced), VS Code, IntelliJ IDEA | Write code with the best tools |
| **Browsers** | Microsoft Edge, Dia browser | Alternatives to Safari |
| **AI / LLM** | ollama, llama.cpp | Run AI models on your own Mac (no internet needed) |
| **Fonts** | 6 Nerd Fonts (JetBrains Mono, Fira Code, etc.) | Beautiful programming fonts with icons |
| **macOS Settings** | Dark mode, fast keyboard, Finder tweaks | Makes your Mac feel better to use |

---

## What You Need Before Starting

- **A Mac with Apple Silicon** (M1, M2, M3, M4 — any Mac from 2020 or later)
- **macOS 24+** (Sequoia or newer — check in System Settings → General → About)
- **Internet connection** (WiFi is fine)
- **At least 30GB free disk space** (the script installs a lot)
- **Time:** 30–60 minutes (mostly waiting for downloads)

---

## Detailed Walkthrough (for complete beginners)

### Running the script step-by-step

When you run the command from Step 2, here's exactly what happens:

```
Phase 0: Installing Xcode Command Line Tools
```
- This installs Apple's developer tools. A popup window may appear — click **Install** and wait. When it finishes, go back to Terminal and press **Enter**.

```
Phase 1: Installing Homebrew & packages
```
- This installs 177+ command-line tools and 25+ applications. You'll see a lot of text scrolling. This is the longest phase (20–40 minutes).

```
Phase 2: Setting macOS preferences
```
- This changes your Mac to dark mode, makes the keyboard repeat faster, enables tap-to-click on the trackpad, and adjusts Finder settings. No action needed.

```
Phase 3: Installing developer tools
```
- Installs Node.js and Rust if they aren't already installed via Homebrew.

```
Phase 4: Installing configuration files
```
- Copies `.zshrc`, `.zprofile`, Starship prompt, Ghostty terminal config, btop monitor config, and Neovim editor config to your home folder.

```
Phase 5: Final touches
```
- Creates folders for tools and installs SDKMAN (Java version manager).

### After the script finishes

1. **Close and reopen Terminal** — you'll see a beautiful colored prompt with Mac icon and time
2. **Open Ghostty** — find it in your Applications folder (or press Command+Space, type "Ghostty", Enter). This is your new terminal app
3. **Authenticate GitHub** — run this in Terminal:
   ```bash
   gh auth login
   ```
   Follow the prompts to log into your GitHub account.

### Optional: Install Java versions

If you need Java:

```bash
source ~/.sdkman/bin/sdkman-init.sh    # Enable Java version manager
sdk install java 11.0.31-amzn          # Install Java 11
sdk install java 17.0.19-amzn          # Install Java 17
sdk install java 21.0.11-amzn          # Install Java 21
```

---

## What the Script Does NOT Do

The script is designed to be safe. These things are intentional:

| Not included | Reason |
|---|---|
| ❌ Delete any of your files | It never removes or overwrites existing documents |
| ❌ Install paid software | No Adobe, Microsoft 365 subscription, etc. |
| ❌ Change your wallpaper | Only system settings (dark mode, dock, keyboard) |
| ❌ Send data anywhere | Everything runs 100% locally on your Mac |
| ❌ Require accounts | No sign-ups needed (except `gh auth login` is optional) |

---

## If Something Goes Wrong

### Common issues and how to fix them

| Problem | Solution |
|---|---|
| `command not found: brew` | Close Terminal and reopen it. If it still fails, run: `eval "$(/opt/homebrew/bin/brew shellenv)"` |
| "Xcode CLT" popup | Click **Install**, wait for it to finish, go back to Terminal and press **Enter** |
| "Password" prompt | Type your Mac login password. The characters won't show as you type — that's normal. Press **Enter** |
| "This app needs to be updated" | You're running an Intel-only app on Apple Silicon. Most things work, but some very old tools won't. |
| Script stops with a red `✗` | Take a screenshot and [open an issue](https://github.com/irfancode/mac-bootstrap/issues) |

### How to run a fresh install

If something goes wrong and you want to start over:

1. Reinstall macOS (erase and reinstall from Recovery Mode)
2. Run the bootstrap command again

---

## What Each File Does

| File | What It Does |
|---|---|
| `bootstrap.sh` | **The main script.** Run this. It calls everything else in order. |
| `Brewfile` | The shopping list of 177+ tools and 25+ apps to install. |
| `install/brew.sh` | Installs Homebrew (if missing) and runs `brew bundle install` using the Brewfile. |
| `install/macos.sh` | Changes macOS settings (dark mode, keyboard speed, dock, Finder). |
| `install/dev-tools.sh` | Installs Node.js and Rust if they're not already installed. |
| `install/mas-list.txt` | App Store app IDs (currently just uBlock Origin). |
| `config/zsh/.zshrc` | Your shell configuration — aliases, prompt, search, plugins. |
| `config/zsh/.zprofile` | Sets up PATH so your Mac can find installed tools. |
| `config/starship/starship.toml` | The colored prompt you see in Terminal. |
| `config/ghostty/config` | Ghostty terminal settings (Monokai Pro theme, font, splits). |
| `config/btop/btop.conf` | btop system monitor settings. |
| `config/nvim/` | Neovim editor config (LazyVim with Monokai Pro theme). |
| `scripts/update-tools.sh` | Script to update all tools daily (from the [keeper](https://github.com/irfancode/keeper) project). |
| `scripts/com.irfan.tool-updater.plist` | Launch agent that runs update-tools automatically every day. |
| `inventory/system-snapshot.json` | A complete record of what was installed when this repo was created. |

---

## How It Works (simple explanation)

1. Your Mac comes with almost nothing installed
2. `bootstrap.sh` starts by installing **Homebrew** — the "app store" for developer tools
3. Homebrew reads `Brewfile` and installs everything listed there (177 tools + 25 apps)
4. The script then applies macOS settings and copies configuration files
5. When it's done, your Mac has exactly the same tools and settings as the original machine

---

## Other Repos You Might Want

- [**keeper**](https://github.com/irfancode/keeper) — Keeps all your tools up to date (installed automatically)
- [**FastFox**](https://github.com/irfancode/FastFox) — Privacy-tuned Firefox configuration
- [**chroma-terminal**](https://github.com/irfancode/chroma-terminal) — 10 beautiful terminal themes (Monokai Pro inspired)

---

<p align="center">
  <sub>Built from a MacBook Air M4 · macOS 27.0 · July 2026</sub>
</p>
