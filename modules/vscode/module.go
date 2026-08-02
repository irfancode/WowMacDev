// Package vscodemodule provisions Visual Studio Code (Homebrew cask) and
// installs configured extensions, theme and editor font.
package vscodemodule

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/omamac/omamac/internal/config"
	"github.com/omamac/omamac/internal/fsutil"
	"github.com/omamac/omamac/internal/homebrew"
	"github.com/omamac/omamac/internal/module"
	"github.com/omamac/omamac/internal/state"
	"github.com/omamac/omamac/internal/util"
)

// Module installs VS Code.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "vscode" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Visual Studio Code with extensions, theme and font" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 30 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool { return cfg.VSCode.Enable }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.InstallCasks(ctx, "visual-studio-code"); err != nil {
		return err
	}
	vc := ctx.Config.VSCode

	code, err := util.LookPath("code")
	if err != nil {
		code = "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
	}

	if len(vc.Extensions) > 0 {
		args := append([]string{"--install-extension"}, vc.Extensions...)
		args = append(args, "--force")
		if err := ctx.Runner.Run(code, args...); err != nil {
			return fmt.Errorf("code --install-extension: %w", err)
		}
	}

	if vc.Theme != "" || vc.Font != "" {
		settings := map[string]string{}
		if vc.Theme != "" {
			settings["workbench.colorTheme"] = vc.Theme
		}
		if vc.Font != "" {
			settings["editor.fontFamily"] = vc.Font
		}
		if err := m.writeSettings(ctx, settings); err != nil {
			return err
		}
	}

	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusOK, Detail: strings.Join(vc.Extensions, ", ")})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	return m.Install(ctx)
}

// Remove implements module.Module. Extensions and settings files are left in
// place; only the cask is removed.
func (m *Module) Remove(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	_ = brew.Uninstall(ctx, nil, []string{"visual-studio-code"})
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	if !ctx.Runner.Exists("code") {
		return fmt.Errorf("code CLI not found (is VS Code installed?)")
	}
	return nil
}

// writeSettings merges the given key/values into VS Code user settings without
// clobbering existing user preferences.
func (m *Module) writeSettings(ctx *module.Context, kv map[string]string) error {
	path := filepath.Join(ctx.HomeDir, "Library", "Application Support", "Code", "User", "settings.json")

	merged := map[string]any{}
	if data, err := os.ReadFile(path); err == nil {
		_ = json.Unmarshal(data, &merged)
	}
	for k, v := range kv {
		merged[k] = v
	}
	out, err := json.MarshalIndent(merged, "", "  ")
	if err != nil {
		return err
	}
	if err := fsutil.WriteFile(path, string(out)+"\n", 0o644, ctx.DryRun); err != nil {
		return err
	}
	if ctx.DryRun {
		ctx.Log.Stepf("[dry-run] merged VS Code settings at %s", path)
	} else {
		ctx.Log.Successf("merged VS Code settings at %s", path)
	}
	return nil
}
