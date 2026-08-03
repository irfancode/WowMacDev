// Package productivitymodule installs utility apps from config.productivity:
// Raycast, Rectangle, Hidden Bar and Stats.
package productivitymodule

import (
	"fmt"

	"github.com/irfancode/omamac/internal/config"
	"github.com/irfancode/omamac/internal/homebrew"
	"github.com/irfancode/omamac/internal/module"
	"github.com/irfancode/omamac/internal/state"
)

// Module installs productivity apps.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "productivity" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Utility apps: Raycast, Rectangle, Hidden Bar, Stats" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 22 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool {
	return len(selected(cfg)) > 0
}

func enabled(m map[string]any) bool {
	if v, ok := m["enable"].(bool); ok {
		return v
	}
	return false
}

// selected returns the Homebrew cask ids for every enabled productivity app.
func selected(cfg *config.Config) []string {
	p := cfg.Productivity
	var out []string
	if enabled(p.Raycast) {
		out = append(out, "raycast")
	}
	if enabled(p.Rectangle) {
		out = append(out, "rectangle")
	}
	if enabled(p.HiddenBar) {
		out = append(out, "hiddenbar")
	}
	if enabled(p.Stats) {
		out = append(out, "stats")
	}
	return out
}

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	want := selected(ctx.Config)
	if len(want) == 0 {
		return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusSkipped, Detail: "no productivity apps enabled"})
	}
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.InstallCasks(ctx, want...); err != nil {
		return err
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusOK})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusOK})
}

// Remove implements module.Module.
func (m *Module) Remove(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	_ = brew.Uninstall(ctx, nil, selected(ctx.Config))
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if missing := brew.MissingCasks(selected(ctx.Config)); len(missing) > 0 {
		return fmt.Errorf("missing productivity apps: %v", missing)
	}
	return nil
}
