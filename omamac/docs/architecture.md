# Architecture

omamac is a small Go CLI with a plugin-friendly module architecture. This
document describes the moving parts and the invariants that keep the project
safe to run on real machines.

## Overview

```
cmd/omamac          main() -> cli.Execute()
internal/cli        cobra commands, App runtime, module execution
internal/config     layered YAML config with embedded defaults
internal/module     Module contract, Registry, Plugin loader/adapter
internal/state      append-only mutation journal (JSONL)
internal/homebrew   idempotent brew wrapper
internal/fsutil     safe file helpers (managed blocks, symlinks)
internal/macos      `defaults` wrapper with value type inference
internal/util       dry-run-aware command Runner, platform helpers
internal/lang       shared "is this language enabled?" check
internal/logging    slog-based logger with printf-style API
internal/tui        progress rendering
modules/*           built-in modules (compiled in)
plugins/examples    example shell plugins
```

## The module contract

Every capability is a `module.Module`:

```go
type Module interface {
    Name() string
    Summary() string
    Priority() int        // lower runs first; homebrew is 0
    Enabled(cfg *config.Config) bool
    Install(ctx *Context) error
    Update(ctx *Context) error
    Remove(ctx *Context) error
    Verify(ctx *Context) error
}
```

`Context` carries everything a module may need:

```go
type Context struct {
    Log       *logging.Logger
    Config    *config.Config
    State     *state.Store
    Runner    *util.Runner      // dry-run-aware command execution
    Progress  ProgressAPI       // optional TUI progress
    DryRun, Verbose, JSON bool
    ConfigDir, DataDir, StateDir, HomeDir string
}
```

Modules are compiled in via the registry in `internal/cli/modules.go`. New
built-ins register there. Third-party capabilities never need compilation:
they are shell scripts loaded as plugins (below).

### Module invariants

Modules must:

- **Honor `ctx.DryRun`** — never mutate when dry-run is set. The `Runner`,
  `fsutil` helpers and `macos.Apply` handle this centrally, so modules should
  route all side effects through them.
- **Journal every mutation** via `ctx.State.Append(...)` — this is what makes
  uninstall and `doctor` trustworthy.
- **Be idempotent** — running `install` twice must be a no-op the second time.
  `internal/homebrew` dedupes against `brew list --formula`/`--cask`; `fsutil`
  write-if-changed helpers keep file mtimes stable.
- **Return an error** from `Install` only on hard failures; prefer
  `ctx.Log.Warnf` for advisory issues.

## Configuration

Config is loaded by `internal/config` as layered YAML:

1. Embedded `defaults.yaml` (via `go:embed`)
2. `~/.config/omamac/config.yaml`
3. `$OMAMAC_CONFIG`
4. `--config FILE`

Layers are deep-merged (`mergeMaps`), then decoded with strict field checking
(`KnownFields(true)`) so typos fail loudly instead of silently no-oping.
`MacOSConfig` and `ProductivityConfig` use free-form `map[string]any` values
interpreted by their modules.

## State journal

`~/.local/state/omamac/state.jsonl` is an append-only JSONL log of every
mutation:

```json
{"id":"...","ts":"...","action":"apply","module":"macos","status":"ok",
 "detail":"com.apple.finder AppleShowAllFiles",
 "before":{"AppleShowAllFiles":"0"},"after":{"AppleShowAllFiles":"1"}}
```

Actions: `install`, `update`, `remove`, `verify`, `apply`. The journal powers:

- **Uninstall rollback** — `macos` module reverts every `apply` entry it
  recorded, restoring previous values.
- **Verification** — `state.Installed(module)` reports whether the most recent
  install succeeded.
- **Idempotency and diagnostics** — `omamac doctor` can correlate current
  system state with recorded history.

Corrupt or partial lines are ignored rather than fatal; the journal is
advisory.

## Plugins

A plugin is a directory under a plugin base (e.g.
`~/.config/omamac/plugins/`) shaped as `<base>/<group>/<name>` containing
`plugin.yaml` and shell scripts. The `Plugin.Adapter()` wraps it as a
`module.Module` with priority 100.

The adapter executes scripts with an env contract:

```
OMAMAC_ACTION, OMAMAC_PLUGIN_NAME, OMAMAC_PLUGIN_DIR,
OMAMAC_CONFIG_DIR, OMAMAC_DATA_DIR, OMAMAC_STATE_DIR, OMAMAC_HOME,
OMAMAC_DRY_RUN, OMAMAC_JSON, OMAMAC_VERBOSE, OMAMAC_PLUGIN_CONFIG
```

Under `--dry-run` the adapter logs the script invocation and runs nothing.
A `.disabled` file in a plugin directory disables it. See
[plugins.md](plugins.md) and `scripts/omamac-lib.sh` for the shared helpers.

## Homebrew wrapper

`internal/homebrew` caches `brew list --formula`/`--cask` and only installs missing
items, so repeated runs are cheap and quiet. Install/remove/update operations
refresh the cache.

## Filesystem safety

`internal/fsutil` provides:

- `WriteFile` / `WriteFileIfChanged` — parent dir creation, stable mtimes
- `AppendBlock` / `ReplaceBlock` — marker-delimited managed blocks so user
  content around the block is preserved
- `AppendLine` — line-level idempotent append
- `Symlink` — never clobbers real files
- `RemoveAll` — dry-run-aware removal

## CLI and output

Commands are cobra commands registered in `internal/cli/root.go`. Human
output goes to **stderr** via the logger; `--json` emits structured results to
**stdout** so `omamac install --json | jq .` works in scripts.

## Testing and CI

- `internal/config`, `internal/homebrew`, `internal/logging`,
  `internal/module`, `internal/state` and selected modules have unit tests.
- CI (`.github/workflows/ci.yml`) runs on `macos-latest` for `arm64` and
  `x86_64`: vet, unit tests, and a dry-run smoke test (`list`, `doctor`,
  `install --dry-run`). Linting and shellcheck run on `ubuntu-latest`.
- `make check` runs the full local gate.
