// Package cleanmodule runs safe post-install cleanup: Homebrew stale package
// removal, cache pruning and macOS temp cleanup. It never touches user data.
package cleanmodule

import (
	"github.com/omamac/omamac/internal/config"
	"github.com/omamac/omamac/internal/fsutil"
	"github.com/omamac/omamac/internal/module"
	"github.com/omamac/omamac/internal/state"
)

// Module performs post-install cleanup.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "cleanup" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Post-install cleanup: stale formulae, caches, temp files" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 90 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool { return cfg.Cleanup.Enable }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	if ctx.Config.Cleanup.Homebrew {
		_ = ctx.Runner.Run("brew", "autoremove")
		_ = ctx.Runner.Run("brew", "cleanup", "--prune=all")
		ctx.Log.Success("Homebrew cleaned")
	}
	if ctx.Config.Cleanup.Cache {
		_ = fsutil.RemoveAll(config.DataDir()+"/tmp", ctx.DryRun)
	}
	if ctx.Config.Cleanup.Trash && !ctx.DryRun {
		_ = ctx.Runner.Run("rm", "-rf", "$TMPDIR/omamac-*")
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusOK})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error { return m.Install(ctx) }

// Remove implements module.Module.
func (m *Module) Remove(ctx *module.Context) error {
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(_ *module.Context) error { return nil }
