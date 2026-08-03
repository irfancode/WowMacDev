# omamac

Opinionated macOS developer workstation bootstrapper. Inspired by
[Omakub](https://omakub.org), built for Apple Silicon. A fresh macOS install
becomes a fully configured developer environment in one command.

- **Go CLI** — one static binary, no runtime dependencies.
- **Module system** — every capability (Homebrew, git, shell, languages,
  applications, AI tooling, macOS preferences, dotfiles, cleanup) is a module
  with `install/update/remove/verify` hooks.
- **Shell plugins** — third-party capabilities are plain shell scripts that
  implement the same contract; no recompiling.
- **Declarative YAML config** — XDG-style (`~/.config/omamac/config.yaml`),
  layered over embedded defaults.
- **Reversible** — an append-only journal records every mutation so
  `omamac uninstall` rolls back safely, and `omamac backup`/`restore` capture
  the whole environment.
- **Production-shaped** — tests, linting, CI on macOS arm64 + x86_64,
  goreleaser builds and a Homebrew tap formula.

```
$ omamac install --dry-run   # preview
$ omamac install             # do it
$ omamac doctor              # health check
$ omamac backup              # snapshot the environment
```

## Quick start

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/omamac/omamac/main/install.sh)"
omamac install --yes
```

Or build from source:

```sh
make build
./bin/omamac install --yes
```

See [Getting started](docs/getting-started.md) for full instructions.

## Modules

| Module | What it does | Enabled by default |
| --- | --- | --- |
| `homebrew` | Install Homebrew; manage taps/formulae/casks | yes |
| `fonts` | Install Nerd Fonts from `config.fonts` | yes |
| `apps` | Install applications from `config.apps` | no |
| `productivity` | Raycast, Rectangle, Hidden Bar, Stats | yes |
| `terminal` | Ghostty / Warp / iTerm2 + theme | yes |
| `git` | Identity, defaults, LFS, SSH keys, GitHub auth | yes |
| `shell` | zsh, Starship, zoxide, fzf, aliases, env, functions | yes |
| `tools` | Cloud/ops CLIs from `config.tools` | yes |
| `vscode` | VS Code + extensions, theme, font | no |
| `ai` | Claude Code, opencode, Gemini, Codex, Copilot, Ollama | no |
| `node` | Node.js via fnm | no |
| `python` | Python via uv + pyenv | no |
| `go` | Go toolchain + gopls/dlv | no |
| `rust` | Rust via rustup | no |
| `java` | JDK (Temurin) + Maven/Gradle | no |
| `docker` | Docker CLI + Colima VM | no |
| `dotfiles` | Clone and symlink a dotfiles repo | no |
| `macos` | `defaults` preferences (reversible) | yes |
| `cleanup` | Stale formulae, caches, temp files | yes |

Language modules (`node`, `python`, `go`, `rust`, `java`, `docker`) run only
when listed in `config.languages`.

## Configuration

`~/.config/omamac/config.yaml` is layered over embedded defaults, then over any
extra files from `OMAMAC_CONFIG` or `--config`. See the full schema in
`internal/config/defaults.yaml` and [docs/getting-started.md](docs/getting-started.md).

```yaml
languages: [node, python]
apps:
  browser: [google-chrome]
  development: [docker]
vscode:
  enable: true
  extensions: [golang.go]
  theme: Nord
ai:
  claude: true
  opencode: true
macos:
  dock:
    autohide: true
```

## Plugins

Plugins extend omamac without changing the binary. A plugin is a directory
with a `plugin.yaml` manifest and shell scripts:

```
~/.config/omamac/plugins/
  company/
    acme/
      plugin.yaml
      install.sh
      update.sh
      remove.sh
      verify.sh
```

```yaml
# plugin.yaml
name: acme
title: Acme Toolkit
description: Installs the Acme CLI and shell integration
depends_on: [homebrew]
commands:
  install: install.sh
  update: update.sh
  remove: remove.sh
  verify: verify.sh
```

Manage them with `omamac plugins add|list|remove|enable|disable`. Plugins live
under `~/.config/omamac/plugins/`. See [docs/plugins.md](docs/plugins.md).

## CLI reference

```
install   Install all enabled modules
update    Update all enabled modules
doctor    System health checks + module verification
verify    Run each module's Verify hook
backup    Export the environment to a restorable backup
restore   Restore a previous backup
config    show | path | init
plugins   add | list | remove | enable | disable
module    <name> install | update | remove | verify
list      List modules and their enabled state
uninstall Roll back everything and remove omamac state
version   Print version
```

Global flags: `--dry-run`, `--yes`, `--json`, `--verbose`, `--debug`,
`--config FILE`, `--module NAME` (repeatable), `--exclude NAME` (repeatable),
`--color auto|always|never`, `--log-file FILE`.

## Documentation

- [The last time you'll set up a Mac by hand](docs/blog-post.md) — read this first
- [Getting started](docs/getting-started.md)
- [Architecture](docs/architecture.md)
- [Writing plugins](docs/plugins.md)
- [Contributing](docs/contributing.md)
- [Troubleshooting](docs/troubleshooting.md)

## Development

```sh
make check     # fmt, vet, lint, shellcheck, test
make dryrun    # preview an install with the local binary
make snapshot  # goreleaser snapshot build
```

## License

MIT. See [LICENSE](LICENSE).
