// Package dockermodule provisions a lightweight container stack: Colima (the
// VM) plus the Docker CLI and compose/buildx plugins.
package dockermodule

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

// Module installs Docker + Colima.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "docker" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Docker CLI with the Colima VM runtime" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 55 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool { return lang.Enabled(cfg, "docker") }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.InstallFormulae(ctx, "colima", "docker", "docker-compose", "docker-buildx"); err != nil {
		return err
	}

	snippet := `# omamac docker
if command -v colima >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
  docker context use colima >/dev/null 2>&1 || true
fi
`
	if err := fsutil.WriteFile(shellmodule.SnippetPath(ctx, "15", "docker"), snippet, 0o644, ctx.DryRun); err != nil {
		return err
	}

	if !ctx.DryRun {
		ctx.Log.Warn("start the container VM when ready with: colima start (or `omamac module docker install` again)")
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusOK})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusOK})
}

// Remove implements module.Module.
func (m *Module) Remove(ctx *module.Context) error {
	if !ctx.DryRun && ctx.Runner.Exists("colima") {
		_ = ctx.Runner.Run("colima", "delete", "-f")
	}
	_ = fsutil.WriteFile(shellmodule.SnippetPath(ctx, "15", "docker"), "", 0o644, ctx.DryRun)
	brew := homebrew.New(ctx.Runner, ctx.Log)
	_ = brew.Uninstall(ctx, []string{"colima", "docker", "docker-compose", "docker-buildx"}, nil)
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	if !ctx.Runner.Exists("docker") || !ctx.Runner.Exists("colima") {
		return fmt.Errorf("docker/colima not installed")
	}
	return nil
}
