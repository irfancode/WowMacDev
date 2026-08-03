// Package rustmodule provisions Rust via rustup.
package rustmodule

import (
	"fmt"

	"github.com/irfancode/omamac/internal/config"
	"github.com/irfancode/omamac/internal/fsutil"
	"github.com/irfancode/omamac/internal/homebrew"
	"github.com/irfancode/omamac/internal/lang"
	"github.com/irfancode/omamac/internal/module"
	"github.com/irfancode/omamac/internal/state"
	shellmodule "github.com/irfancode/omamac/modules/shell"
)

// Module installs Rust.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "rust" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Rust via rustup" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 53 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool { return lang.Enabled(cfg, "rust") }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.InstallFormulae(ctx, "rustup-init"); err != nil {
		return err
	}

	snippet := `# omamac rust
export RUSTUP_HOME="$HOME/.rustup"
export CARGO_HOME="$HOME/.cargo"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
`
	if err := fsutil.WriteFile(shellmodule.SnippetPath(ctx, "13", "rust"), snippet, 0o644, ctx.DryRun); err != nil {
		return err
	}

	if !ctx.DryRun && ctx.Runner.Exists("rustup-init") && !ctx.Runner.Exists("cargo") {
		ctx.Log.Info("installing the Rust toolchain via rustup")
		if err := ctx.Runner.Run("rustup-init", "-y", "--no-modify-path"); err != nil {
			return fmt.Errorf("rustup-init: %w", err)
		}
	}

	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusOK})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	if !ctx.DryRun && ctx.Runner.Exists("rustup") {
		_ = ctx.Runner.Run("rustup", "update")
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusOK})
}

// Remove implements module.Module.
func (m *Module) Remove(ctx *module.Context) error {
	_ = fsutil.WriteFile(shellmodule.SnippetPath(ctx, "13", "rust"), "", 0o644, ctx.DryRun)
	if !ctx.DryRun && ctx.Runner.Exists("rustup") {
		_ = ctx.Runner.Run("rustup", "self", "uninstall", "-y")
	}
	brew := homebrew.New(ctx.Runner, ctx.Log)
	_ = brew.Uninstall(ctx, []string{"rustup-init"}, nil)
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	if !ctx.Runner.Exists("cargo") || !ctx.Runner.Exists("rustup") {
		return fmt.Errorf("rust toolchain not installed")
	}
	return nil
}
