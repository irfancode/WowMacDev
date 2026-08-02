# Writing plugins

Plugins extend omamac without recompiling anything. A plugin is a directory
with a `plugin.yaml` manifest and shell scripts that implement the module
contract. Everything a built-in module can do, a plugin can do too.

## Layout

Plugins live in plugin bases, scanned as `<base>/<group>/<name>`:

- `~/.config/omamac/plugins/` (user plugins — the default base)
- the repo's `plugins/` directory (shipped examples, useful during
  development)

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

## The manifest

```yaml
name: acme
title: Acme Toolkit
description: Installs the Acme CLI and shell integration
depends_on:
  - homebrew
commands:
  install: install.sh
  update: update.sh
  remove: remove.sh
  verify: verify.sh
```

- `name` — `[a-z0-9._-]`, used in config, CLI and the journal.
- `title` + `description` — shown by `omamac list`.
- `depends_on` — advisory ordering hints (not yet enforced by the scheduler).
- `commands` — which script implements each contract hook. Any hook may be
  omitted; the plugin then reports "no command" for that action and skips.
- Command paths must be relative to the plugin directory.

The same layout is available in config as any other module: list plugins via
`omamac plugins list`, and filter them with `--module` / `--exclude` like
built-ins.

## Environment contract

The plugin adapter exports these variables to every script:

| Variable | Meaning |
| --- | --- |
| `OMAMAC_ACTION` | `install`, `update`, `remove`, or `verify` |
| `OMAMAC_PLUGIN_NAME` | the plugin name |
| `OMAMAC_PLUGIN_DIR` | absolute path to the plugin directory |
| `OMAMAC_CONFIG_DIR` | omamac config dir |
| `OMAMAC_DATA_DIR` | omamac data dir |
| `OMAMAC_STATE_DIR` | omamac state dir |
| `OMAMAC_HOME` | the user's home directory |
| `OMAMAC_DRY_RUN` | `1` during `--dry-run`, else `0` |
| `OMAMAC_JSON` | `1` when `--json` is active |
| `OMAMAC_VERBOSE` | `1` when `--verbose` is active |
| `OMAMAC_PLUGIN_CONFIG` | JSON of the plugin's `config` map |

## Rules

1. **Honor `OMAMAC_DRY_RUN`.** If it is `1`, log your intended commands and
   exit successfully. Do not mutate anything.
2. **Be idempotent.** Running install twice must not error or duplicate.
3. **Exit non-zero on hard failure** only; use stderr warnings for advisory
   issues. A `verify` script should exit non-zero when the plugin is not
   correctly installed.
4. **Keep it dependency-free.** Plugins may assume `/bin/bash`, Homebrew, and
   macOS defaults. Anything else, install it yourself.

## Shared helpers

`scripts/omamac-lib.sh` provides small, dry-run-aware helpers. Copy it into
your plugin, or source it from a stable path:

```bash
#!/bin/bash
# shellcheck source=/dev/null
source "$(dirname "$0")/omamac-lib.sh"

install() {
  run brew install acme-cli
  run ln -sfn "$OMAMAC_PLUGIN_DIR/acme.zsh" "$HOME/.config/omamac/shell/91-acme.zsh"
  ok "acme installed"
}

case "$OMAMAC_ACTION" in
  install) install ;;
  update)  run brew upgrade acme-cli ;;
  remove)  run brew uninstall acme-cli ;;
  verify)  command -v acme >/dev/null || die "acme not on PATH" ;;
esac
```

Available helpers: `log`, `ok`, `warn`, `die`, `is_dry_run`, `run`,
`brew_install`, `append_if_missing`, `link_dotfile`.

## Managing plugins

```sh
omamac plugins list                      # show all loaded plugins
omamac plugins add ~/src/my-plugin       # register from a local dir
omamac plugins remove acme               # unregister
omamac plugins enable acme               # remove the .disabled marker
omamac plugins disable acme              # add a .disabled marker
```

## Example plugins

Two shipped examples show the pattern:

- `plugins/examples/company/acme` — a company-internal toolchain
- `plugins/examples/security/firewall` — system hardening checks

Copy one as a starting point for your own plugin.
