# Getting started

omamac transforms a fresh macOS install into a fully configured developer
workstation. This guide walks through installation, configuration and the
core workflows.

## Requirements

- macOS 14 or later (Apple Silicon recommended)
- An internet connection
- A sudo-capable admin user (Homebrew and some macOS settings require it)

omamac is a single static Go binary with no runtime dependencies. Homebrew,
Xcode Command Line Tools and the rest of the stack are installed by omamac
itself.

## 1. Install omamac

### Bootstrap script (recommended)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/omamac/omamac/main/install.sh)"
```

The script checks for Xcode Command Line Tools, installs Homebrew if missing,
then installs the latest omamac release and prints next steps.

### From source

```sh
git clone https://github.com/omamac/omamac.git
cd omamac
make build
./bin/omamac install --yes
```

### Homebrew tap

```sh
brew tap omamac/tap
brew install omamac
```

## 2. Preview before you run

Never trust a bootstrapper blindly — look first:

```sh
omamac install --dry-run
```

This prints every command omamac would run and every file it would write,
without changing anything.

## 3. Configure

The default configuration is sensible for most developers. Customize by
creating `~/.config/omamac/config.yaml`:

```sh
omamac config init     # write the defaults to ~/.config/omamac/config.yaml
omamac config show     # print the fully merged configuration
omamac config path     # print the config file location
```

The config is YAML. Any field you omit inherits the embedded default. A few
examples:

```yaml
# Enable language toolchains
languages:
  - node
  - python
  - go

# Install applications
apps:
  browser: [google-chrome, firefox]
  development: [docker, postman]
  communication: [slack, discord]

# VS Code
vscode:
  enable: true
  extensions:
    - golang.go
    - rust-lang.rust-analyzer
    - bierner.markdown-mermaid
  theme: Nord

# AI developer tools
ai:
  claude: true
  opencode: true
  ollama: true
  models: [llama3.2]

# macOS preferences (all optional)
macos:
  enable: true
  finder:
    show_hidden: true
    show_all_extensions: true
  dock:
    autohide: true
    icon_size: 36
  screenshots:
    location: ~/Pictures/Screenshots

# Dotfiles repo to clone and symlink
dotfiles:
  repo: git@github.com:you/dotfiles.git
  links: [.zshrc, .gitconfig]
```

Configuration layering (later wins):

1. Embedded defaults (`internal/config/defaults.yaml`)
2. `~/.config/omamac/config.yaml`
3. File at `$OMAMAC_CONFIG`
4. File at `--config /path/to/file.yaml`

## 4. Install

```sh
omamac install --yes
```

`--yes` skips confirmation prompts. Without it, omamac asks before running.

Select modules to run (or exclude) for a single run:

```sh
omamac install --module homebrew --module shell
omamac install --exclude macos
```

## 5. Verify and health-check

```sh
omamac verify    # run every module's Verify hook
omamac doctor    # platform checks + module verification
```

Both exit non-zero when problems are found — useful in scripts and CI.

## 6. Update and maintain

```sh
omamac update    # brew update/upgrade + each module's Update hook
```

## 7. Back up and restore

```sh
omamac backup                # snapshot to ~/.local/share/omamac/backups/
omamac backup monthly        # named snapshot
omamac restore <backup-dir>  # replay a snapshot
```

A backup contains a `Brewfile`, exported `defaults` plists, VS Code settings,
the omamac config and a generated `restore.sh`.

## 8. Uninstall

```sh
omamac uninstall
```

omamac rolls back the macOS preferences it changed (restoring previous
values from its journal), removes installed packages it manages, and deletes
its state. It will not delete files you created after installation.

## What omamac touches

- `~/.config/omamac` — configuration and plugins
- `~/.local/share/omamac` — data (backups)
- `~/.local/state/omamac` — the mutation journal
- `~/.config/omamac/shell` and the `~/.zshrc` source block — shell snippets
- `~/.gitconfig`, `~/.gitignore_global` — git defaults
- Homebrew — packages listed in `config.homebrew`
- `defaults` — preferences in `config.macos`

Everything is reversible; see [Architecture](architecture.md).
