// Package appsmodule installs applications (Homebrew casks) grouped by
// category in config.apps.
package appsmodule

import (
	"fmt"
	"strings"

	"github.com/irfancode/omamac/internal/config"
	"github.com/irfancode/omamac/internal/homebrew"
	"github.com/irfancode/omamac/internal/module"
	"github.com/irfancode/omamac/internal/state"
)

// Module installs applications.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "apps" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Applications from config.apps (Homebrew casks)" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 20 }

// Enabled implements module.Module. Apps are on unless every category is empty.
func (m *Module) Enabled(cfg *config.Config) bool { return len(cfg.Apps.All()) > 0 }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	apps := ctx.Config.Apps.All()
	if len(apps) == 0 {
		return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusSkipped, Detail: "no apps configured"})
	}
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.InstallCasks(ctx, apps...); err != nil {
		return err
	}
	return ctx.State.Append(state.Entry{
		Module:  m.Name(),
		Action:  state.ActionInstall,
		Status:  state.StatusOK,
		Detail:  strings.Join(apps, ", "),
		Command: brew.Path(),
	})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusOK})
}

// Remove implements module.Module.
func (m *Module) Remove(ctx *module.Context) error {
	apps := ctx.Config.Apps.All()
	if len(apps) == 0 {
		return nil
	}
	brew := homebrew.New(ctx.Runner, ctx.Log)
	_ = brew.Uninstall(ctx, nil, apps)
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	apps := ctx.Config.Apps.All()
	if len(apps) == 0 {
		return nil
	}
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if missing := brew.MissingCasks(apps); len(missing) > 0 {
		return fmt.Errorf("missing apps: %s", strings.Join(missing, ", "))
	}
	return nil
}
