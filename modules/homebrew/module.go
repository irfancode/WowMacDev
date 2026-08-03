// Package homebrewmodule is the module that provisions Homebrew and installs
// declaratively configured taps, formulae and casks.
package homebrewmodule

import (
	"fmt"
	"strings"

	"github.com/irfancode/omamac/internal/config"
	"github.com/irfancode/omamac/internal/homebrew"
	"github.com/irfancode/omamac/internal/module"
	"github.com/irfancode/omamac/internal/state"
)

// Module provisions Homebrew.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "homebrew" }

// Summary implements module.Module.
func (m *Module) Summary() string {
	return "Homebrew package manager and declaratively configured taps, formulae and casks"
}

// Priority implements module.Module. Homebrew must run first.
func (m *Module) Priority() int { return 0 }

// Enabled implements module.Module.
func (m *Module) Enabled(*config.Config) bool { return true }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.EnsureInstalled(ctx); err != nil {
		return err
	}

	hb := ctx.Config.Homebrew

	if hb.Update && !ctx.DryRun {
		if err := brew.Update(ctx); err != nil {
			return err
		}
	}

	steps := 0
	steps += len(hb.Taps)
	steps += len(hb.Formulae)
	steps += len(hb.Casks)
	if hb.Cleanup {
		steps++
	}
	if ctx.Progress != nil {
		ctx.Progress.Start(max(steps, 1))
	}

	if err := brew.Tap(ctx, hb.Taps...); err != nil {
		return err
	}
	if err := brew.InstallFormulae(ctx, hb.Formulae...); err != nil {
		return err
	}
	if err := brew.InstallCasks(ctx, hb.Casks...); err != nil {
		return err
	}
	if hb.Cleanup {
		if err := brew.Cleanup(ctx); err != nil {
			return err
		}
	}

	if ctx.Progress != nil {
		ctx.Progress.Finish("homebrew", true)
	}

	detail := strings.Join(hb.Formulae, ", ")
	if len(hb.Casks) > 0 {
		detail += " | casks: " + strings.Join(hb.Casks, ", ")
	}
	return ctx.State.Append(state.Entry{
		Module:  m.Name(),
		Action:  state.ActionInstall,
		Status:  state.StatusOK,
		Detail:  detail,
		Command: brew.Path(),
	})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.Update(ctx); err != nil {
		return err
	}
	if err := brew.Upgrade(ctx); err != nil {
		return err
	}
	if ctx.Config.Homebrew.Upgrade {
		if err := brew.UpgradeCasks(ctx); err != nil {
			return err
		}
	}
	if ctx.Config.Homebrew.Cleanup {
		if err := brew.Cleanup(ctx); err != nil {
			return err
		}
	}
	return ctx.State.Append(state.Entry{
		Module: m.Name(),
		Action: state.ActionUpdate,
		Status: state.StatusOK,
	})
}

// Remove implements module.Module. It uninstalls the declaratively configured
// formulae and casks.
func (m *Module) Remove(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if !brew.Installed() {
		return nil
	}
	hb := ctx.Config.Homebrew
	if err := brew.Uninstall(ctx, hb.Formulae, hb.Casks); err != nil {
		return err
	}
	if len(hb.Taps) > 0 {
		if err := brew.Untap(ctx, hb.Taps...); err != nil {
			return err
		}
	}
	return ctx.State.Append(state.Entry{
		Module: m.Name(),
		Action: state.ActionRemove,
		Status: state.StatusOK,
	})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if !brew.Installed() {
		return fmt.Errorf("homebrew is not installed")
	}
	if missing := brew.MissingFormulae(ctx.Config.Homebrew.Formulae); len(missing) > 0 {
		return fmt.Errorf("missing formulae: %s", strings.Join(missing, ", "))
	}
	if missing := brew.MissingCasks(ctx.Config.Homebrew.Casks); len(missing) > 0 {
		return fmt.Errorf("missing casks: %s", strings.Join(missing, ", "))
	}
	// brew doctor warnings are advisory and should not fail verification.
	if err := brew.Runner.Run(brew.Path(), "doctor"); err != nil {
		ctx.Log.Warnf("brew doctor reported advisory warnings: %v", err)
	}
	return nil
}
