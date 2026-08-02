// Package nodemodule provisions Node.js via fnm (fast, no sudo, shims).
package nodemodule

import (
	"fmt"

	"github.com/omamac/omamac/internal/config"
	"github.com/omamac/omamac/internal/fsutil"
	"github.com/omamac/omamac/internal/homebrew"
	"github.com/omamac/omamac/internal/lang"
	"github.com/omamac/omamac/internal/module"
	"github.com/omamac/omamac/internal/state"
	shellmodule "github.com/omamac/omamac/modules/shell"
)

// Module installs Node via fnm.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "node" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Node.js via fnm (with pnpm)" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 50 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool { return lang.Enabled(cfg, "node") }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.InstallFormulae(ctx, "fnm", "pnpm"); err != nil {
		return err
	}

	snippet := `# omamac node
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi
if command -v pnpm >/dev/null 2>&1; then
  export PNPM_HOME="$HOME/Library/pnpm"
  export PATH="$PNPM_HOME:$PATH"
fi
`
	if err := fsutil.WriteFile(shellmodule.SnippetPath(ctx, "10", "node"), snippet, 0o644, ctx.DryRun); err != nil {
		return err
	}

	if !ctx.DryRun && ctx.Runner.Exists("fnm") {
		ctx.Log.Info("installing Node LTS via fnm")
		if err := ctx.Runner.Run("fnm", "install", "--lts"); err != nil {
			return fmt.Errorf("fnm install --lts: %w", err)
		}
		if err := ctx.Runner.Run("fnm", "alias", "lts-latest", "default"); err != nil {
			ctx.Log.Warnf("fnm alias default: %v", err)
		}
	}

	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusOK})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusOK})
}

// Remove implements module.Module.
func (m *Module) Remove(ctx *module.Context) error {
	_ = fsutil.WriteFile(shellmodule.SnippetPath(ctx, "10", "node"), "", 0o644, ctx.DryRun)
	brew := homebrew.New(ctx.Runner, ctx.Log)
	_ = brew.Uninstall(ctx, []string{"fnm", "pnpm"}, nil)
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	if !ctx.Runner.Exists("fnm") {
		return fmt.Errorf("fnm not installed")
	}
	return nil
}
