// Package toolsmodule installs the cloud/ops CLI tools declared in config
// (awscli, azure-cli, google-cloud-sdk, kubectl, helm, terraform, ansible...).
package toolsmodule

import (
	"fmt"
	"strings"

	"github.com/irfancode/omamac/internal/config"
	"github.com/irfancode/omamac/internal/homebrew"
	"github.com/irfancode/omamac/internal/module"
	"github.com/irfancode/omamac/internal/state"
)

// Module installs toolchain CLIs.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "tools" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Cloud and ops CLIs from config.tools" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 40 }

// Enabled implements module.Module.
func (m *Module) Enabled(*config.Config) bool { return true }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	tools := ctx.Config.Tools
	if len(tools) == 0 {
		return nil
	}
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.InstallFormulae(ctx, tools...); err != nil {
		return err
	}
	return ctx.State.Append(state.Entry{
		Module: m.Name(),
		Action: state.ActionInstall,
		Status: state.StatusOK,
		Detail: strings.Join(tools, ", "),
	})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusOK})
}

// Remove implements module.Module.
func (m *Module) Remove(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.Uninstall(ctx, ctx.Config.Tools, nil); err != nil {
		return err
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if missing := brew.MissingFormulae(ctx.Config.Tools); len(missing) > 0 {
		return fmt.Errorf("missing tools: %s", strings.Join(missing, ", "))
	}
	return nil
}
