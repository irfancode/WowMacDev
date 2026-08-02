// Package golangmodule provisions the Go toolchain and common dev tools.
package golangmodule

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

// Module installs Go.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "go" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Go toolchain with gopls and delve" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 52 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool { return lang.Enabled(cfg, "go") }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.InstallFormulae(ctx, "go"); err != nil {
		return err
	}

	snippet := `# omamac go
export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin"
export PATH="$GOBIN:$PATH"
`
	if err := fsutil.WriteFile(shellmodule.SnippetPath(ctx, "12", "golang"), snippet, 0o644, ctx.DryRun); err != nil {
		return err
	}

	if !ctx.DryRun && ctx.Runner.Exists("go") {
		for _, tool := range []string{
			"golang.org/x/tools/gopls@latest",
			"github.com/go-delve/delve/cmd/dlv@latest",
		} {
			ctx.Log.Infof("go install %s", tool)
			if err := ctx.Runner.Run("go", "install", tool); err != nil {
				ctx.Log.Warnf("go install %s: %v", tool, err)
			}
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
	_ = fsutil.WriteFile(shellmodule.SnippetPath(ctx, "12", "golang"), "", 0o644, ctx.DryRun)
	brew := homebrew.New(ctx.Runner, ctx.Log)
	_ = brew.Uninstall(ctx, []string{"go"}, nil)
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	if !ctx.Runner.Exists("go") {
		return fmt.Errorf("go not installed")
	}
	return nil
}
