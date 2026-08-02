// Package pythonmodule provisions Python via uv (fast package/env manager) and
// pyenv for version management.
package pythonmodule

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

// Module installs Python tooling.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "python" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Python via uv and pyenv" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 51 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool { return lang.Enabled(cfg, "python") }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.InstallFormulae(ctx, "uv", "pyenv"); err != nil {
		return err
	}

	snippet := `# omamac python
if command -v uv >/dev/null 2>&1; then
  export UV_PYTHON_PREFERENCE=managed
fi
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
`
	if err := fsutil.WriteFile(shellmodule.SnippetPath(ctx, "11", "python"), snippet, 0o644, ctx.DryRun); err != nil {
		return err
	}

	if !ctx.DryRun && ctx.Runner.Exists("uv") {
		ctx.Log.Info("installing latest Python via uv")
		if err := ctx.Runner.Run("uv", "python", "install"); err != nil {
			ctx.Log.Warnf("uv python install: %v", err)
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
	_ = fsutil.WriteFile(shellmodule.SnippetPath(ctx, "11", "python"), "", 0o644, ctx.DryRun)
	brew := homebrew.New(ctx.Runner, ctx.Log)
	_ = brew.Uninstall(ctx, []string{"uv", "pyenv"}, nil)
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	if !ctx.Runner.Exists("uv") || !ctx.Runner.Exists("pyenv") {
		return fmt.Errorf("uv/pyenv not installed")
	}
	return nil
}
