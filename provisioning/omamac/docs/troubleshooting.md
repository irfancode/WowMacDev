# Troubleshooting

Common problems and how to diagnose them.

## Safe first step: dry-run and verify

```
omamac install --dry-run --json | jq .    # what would happen, machine-readable
omamac doctor                              # platform + module health checks
omamac verify                              # only module verification
```

`doctor` exits non-zero and lists failing checks with details. `--json` keeps
stdout clean for scripting; human logs go to stderr.

## "brew: command not found" after install

The Homebrew binary path differs by architecture. omamac uses
`/opt/homebrew/bin` (Apple Silicon) or `/usr/local/bin` (Intel) via
`util.HomebrewBin`. If you installed Homebrew elsewhere, add it to your PATH:

```sh
eval "$(/path/to/homebrew/bin/brew shellenv)"
```

## Command appears to hang during `brew install`

Homebrew downloads can be slow the first time, and `brew update` may run
automatically. Set these to speed up repeat runs:

```sh
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
```

Then re-run `omamac install`.

## Language modules never run

Language modules (`node`, `python`, `go`, `rust`, `java`, `docker`) run only
when their name is in `config.languages`:

```yaml
languages: [node, python, go]
```

Confirm the effective config:

```sh
omamac config show | grep -A5 languages
omamac list --json | jq -r '.modules[] | "\(.name)\t\(.enabled)"'
```

## `defaults` changes don't take effect

Most changes require the owning app to restart. omamac restarts `Dock` and
`Finder` after applying preferences. If a setting still looks stale, restart
the app manually or log out/in. Some settings (e.g. macOS 14+ locking down
`defaults`) may need a reboot.

## `verify` fails for a module that is installed

Verification is intentionally strict. Common causes:

- The tool is installed but not on `PATH` (e.g. `go` binaries land in
  `~/go/bin` — re-source your shell so the omamac snippet runs).
- A configured formula/cask is not in the `brew list --formula`/`--cask` cache — the
  cache refreshes on the next install/remove.
- The shell module checks that `~/.zshrc` contains the omamac source block;
  if you removed it, re-run `omamac install --module shell`.

## Shell snippets not active

omamac writes numbered snippets to `~/.config/omamac/shell/*.sh` and sources
them from a block in `~/.zshrc`. To reload in your current shell:

```sh
source ~/.zshrc
```

If you use a shell other than zsh, the snippet mechanism won't apply — set
`shell.shell` and re-run (only zsh is supported).

## macOS preferences not applied / "unsupported defaults value type"

The `macos` module maps `config.macos.*` keys to specific `defaults` keys.
Unknown keys are silently ignored by design (typos in that section are
non-fatal). Check the applied rules with the journal:

```sh
grep '"module":"macos"' ~/.local/state/omamac/state.jsonl
```

## Uninstall didn't remove everything

`omamac uninstall` rolls back what omamac itself changed — journaled
`defaults` writes and its own files. It will not delete apps or packages you
installed separately, nor files you created after installation. To remove a
specific managed thing, use `omamac module remove <name>` first.

## Plugin not listed / plugin errors

- Plugins are scanned from `<base>/<group>/<name>`; a `.disabled` file
  disables them. Check with `omamac plugins list`.
- A plugin that fails manifest validation is skipped with an error. Fix
  `plugin.yaml` and re-run `omamac plugins list`.
- Plugin scripts must honor `OMAMAC_DRY_RUN`; during dry-run they are logged
  but not executed. Use `--verbose` to see plugin stdout:
  `omamac install --module acme --verbose`.

## Logs

Everything is logged (stderr). To capture a full run:

```sh
omamac install --log-file /tmp/omamac.log --verbose
```

Include the log file and `omamac doctor --json` output when reporting an
issue.
