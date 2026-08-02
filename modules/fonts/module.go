// Package fontsmodule installs Nerd Fonts for the configured font names.
package fontsmodule

import (
	"fmt"
	"strings"

	"github.com/omamac/omamac/internal/config"
	"github.com/omamac/omamac/internal/homebrew"
	"github.com/omamac/omamac/internal/module"
	"github.com/omamac/omamac/internal/state"
)

// Module installs fonts.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "fonts" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Nerd Fonts from config.fonts" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 15 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool { return len(cfg.Fonts) > 0 }

// caskFor maps a configured font name to its Homebrew cask id. Nerd Fonts
// changed cask naming over time; known names use their canonical cask, with a
// best-effort generic fallback.
func caskFor(name string) string {
	switch strings.ToLower(strings.TrimSpace(name)) {
	case "jetbrains mono":
		return "font-jetbrains-mono-nerd-font"
	case "fira code":
		return "font-fira-code-nerd-font"
	case "hack":
		return "font-hack-nerd-font"
	case "cascadia code", "cascadia":
		return "font-cascadia-code-nf"
	case "caskaydia cove":
		return "font-caskaydia-cove-nerd-font"
	case "monaspace":
		return "font-monaspace-nerd-font"
	case "geist mono":
		return "font-geist-mono-nerd-font"
	}
	return "font-" + strings.ToLower(strings.ReplaceAll(strings.TrimSpace(name), " ", "-")) + "-nerd-font"
}

// CasksFor maps configured font names to Homebrew cask ids, skipping any cask
// already managed by the homebrew module.
func CasksFor(cfg *config.Config) []string {
	managed := map[string]bool{}
	for _, c := range cfg.Homebrew.Casks {
		managed[c] = true
	}
	var out []string
	for _, name := range cfg.Fonts {
		cask := caskFor(name)
		if !managed[cask] {
			out = append(out, cask)
		}
	}
	return out
}

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	casks := CasksFor(ctx.Config)
	if len(casks) == 0 {
		return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusSkipped, Detail: "no additional fonts"})
	}
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.InstallCasks(ctx, casks...); err != nil {
		return err
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusOK, Detail: strings.Join(casks, ", ")})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusOK})
}

// Remove implements module.Module.
func (m *Module) Remove(ctx *module.Context) error {
	casks := CasksFor(ctx.Config)
	if len(casks) == 0 {
		return nil
	}
	brew := homebrew.New(ctx.Runner, ctx.Log)
	_ = brew.Uninstall(ctx, nil, casks)
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	casks := CasksFor(ctx.Config)
	if len(casks) == 0 {
		return nil
	}
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if missing := brew.MissingCasks(casks); len(missing) > 0 {
		return fmt.Errorf("missing fonts: %s", strings.Join(missing, ", "))
	}
	return nil
}
