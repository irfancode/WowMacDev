# Contributing

Thanks for contributing to omamac. This project is intentionally small and
heavily testable — please keep it that way.

## Setup

```sh
git clone https://github.com/irfancode/omamac.git
cd omamac
make check     # fmt, vet, lint, shellcheck, test
```

`make check` is the full local gate. It runs:

- `gofmt -l -w .`
- `go vet ./...`
- `golangci-lint run ./...`
- `shellcheck install.sh scripts/*.sh plugins/examples/*/*.sh`
- `go test ./...`

CI runs these plus a dry-run smoke test on both macOS architectures.

## Project layout

```
cmd/omamac        main
internal/         shared packages (config, module, state, homebrew, util, ...)
modules/          built-in modules, one package each
plugins/examples/ example shell plugins
docs/             documentation
```

## Adding a built-in module

1. Create `modules/<name>/module.go` implementing `module.Module`.
2. Follow the module invariants (see `docs/architecture.md`):
   - honor `ctx.DryRun` (route side effects through `ctx.Runner`,
     `fsutil`, `macos.Apply`)
   - journal via `ctx.State.Append`
   - be idempotent
3. Add an `Enabled` gate. Language modules should use `lang.Enabled(cfg, ...)`
   so they only run when listed in `config.languages`.
4. Register in `internal/cli/modules.go` — add the import and a
   `&xxxmodule.Module{}` in `RegisterAll`, ordered by priority.
5. Add the config fields to `internal/config/config.go` and
   `internal/config/defaults.yaml` (config fields are strict — add what you
   reference).
6. Add tests for any pure logic (rule mapping, selection, dedup, etc.).
7. Run `make check` and confirm `omamac list` shows your module.

## Adding a plugin (no Go needed)

Plugins are pure shell. See `docs/plugins.md`. Example plugins live in
`plugins/examples/`.

## Code style

- **Logging:** use the printf-style API. When the format string is dynamic or
  has arguments, use the `*f` variants (`Log.Infof`, `Log.Warnf`, ...). Plain
  methods (`Log.Info`) take a single literal string. `go vet` enforces this.
- **No comments unless they earn their place.** Doc comments on exported
  identifiers are required; inline comments should explain *why*.
- **Errors:** wrap with `%w` and context: `fmt.Errorf("brew install: %w", err)`.
- **Never commit secrets**; the repo must pass `git secret scan` / manual
  review before PRs.

## Testing

```sh
make test          # all packages
make test-race     # race detector
make unit          # internal packages only
```

Tests use the stub `fakeBrew` in `internal/homebrew` and dry-run runners in
`internal/util`; avoid tests that require real Homebrew or a real macOS setup.

## Releasing

Releases are cut with goreleaser from the `v*` tag (see
`.goreleaser.yaml` and `.github/workflows/release.yml`). The tap formula lives
at `homebrew/Formula/omamac.rb` — update the `sha256` when cutting a release.

## Docs

Keep `docs/` in sync with behavior. When you add a module, update the module
table in `README.md`.
