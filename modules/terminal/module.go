// Package terminalmodule installs terminal emulators from config.terminal and
// writes their theme configuration.
package terminalmodule

import (
	"fmt"

	"github.com/omamac/omamac/internal/config"
	"github.com/omamac/omamac/internal/fsutil"
	"github.com/omamac/omamac/internal/homebrew"
	"github.com/omamac/omamac/internal/module"
	"github.com/omamac/omamac/internal/state"
)

// Module installs terminals.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "terminal" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Terminal emulators and theme configuration" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 25 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool {
	t := cfg.Terminal
	return t.Ghostty || t.Warp || t.ITerm2 || t.TerminalApp
}

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	term := ctx.Config.Terminal
	brew := homebrew.New(ctx.Runner, ctx.Log)

	var casks []string
	if term.Ghostty {
		casks = append(casks, "ghostty")
	}
	if term.Warp {
		casks = append(casks, "warp")
	}
	if term.ITerm2 {
		casks = append(casks, "iterm2")
	}
	if len(casks) > 0 {
		if err := brew.InstallCasks(ctx, casks...); err != nil {
			return err
		}
	}

	if term.Ghostty {
		if err := m.writeGhostty(ctx); err != nil {
			return err
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
	term := ctx.Config.Terminal
	var casks []string
	if term.Ghostty {
		casks = append(casks, "ghostty")
	}
	if term.Warp {
		casks = append(casks, "warp")
	}
	if term.ITerm2 {
		casks = append(casks, "iterm2")
	}
	brew := homebrew.New(ctx.Runner, ctx.Log)
	_ = brew.Uninstall(ctx, nil, casks)
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	term := ctx.Config.Terminal
	if term.Ghostty && !ctx.Runner.Exists("ghostty") {
		return fmt.Errorf("ghostty not installed")
	}
	return nil
}

// writeGhostty writes a minimal Ghostty config wired to the configured theme
// and the omamac shell snippets.
func (m *Module) writeGhostty(ctx *module.Context) error {
	dir := ctx.ConfigDir
	if dir == "" {
		return nil
	}
	path := dir + "/ghostty/config"
	cfg := "font-family = JetBrainsMono Nerd Font\nfont-size = 13\n"
	if ctx.Config.Terminal.Theme != "" {
		cfg += fmt.Sprintf("theme = %s\n", ctx.Config.Terminal.Theme)
	}
	cfg += "confirm-close-surface = false\n"
	changed, err := fsutil.WriteFileIfChanged(path, cfg, 0o644)
	if err != nil {
		return err
	}
	if changed || ctx.DryRun {
		ctx.Log.Successf("wrote %s", path)
	}
	return nil
}
