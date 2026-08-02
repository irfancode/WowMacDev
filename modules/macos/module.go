// Package macosmodule applies opinionated macOS preferences via `defaults`,
// snapshotting prior values so changes can be rolled back by `omamac
// uninstall`. Every section in config.macos maps to `defaults write` rules.
package macosmodule

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/omamac/omamac/internal/config"
	"github.com/omamac/omamac/internal/macos"
	"github.com/omamac/omamac/internal/module"
	"github.com/omamac/omamac/internal/state"
)

// Module applies macOS preferences.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "macos" }

// Summary implements module.Module.
func (m *Module) Summary() string {
	return "macOS preferences: Finder, Dock, Trackpad, Keyboard, Mission Control, Screenshots, Energy"
}

// Priority implements module.Module.
func (m *Module) Priority() int { return 60 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool { return cfg.MacOS.Enable }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	mo := ctx.Config.MacOS
	applied := 0

	for _, r := range buildRules(mo) {
		prev, err := macos.Apply(ctx, r)
		if err != nil {
			ctx.Log.Warnf("defaults write %s.%s: %v", r.Domain, r.Key, err)
			continue
		}
		applied++
		_ = ctx.State.Append(state.Entry{
			Module: m.Name(),
			Action: state.ActionApply,
			Status: state.StatusOK,
			Detail: r.Domain + " " + r.Key,
			Before: map[string]any{r.Key: prev},
			After:  map[string]any{r.Key: fmt.Sprintf("%v", r.Value)},
		})
	}

	if applied > 0 {
		macos.RestartFrequent(ctx, "Dock", "Finder")
	}
	return ctx.State.Append(state.Entry{
		Module: m.Name(),
		Action: state.ActionInstall,
		Status: state.StatusOK,
		Detail: fmt.Sprintf("%d preferences applied", applied),
	})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error { return m.Install(ctx) }

// Remove implements module.Module. It reverts every preference recorded in the
// journal for this module, restoring the previous value.
func (m *Module) Remove(ctx *module.Context) error {
	reverted := 0
	for _, e := range ctx.State.ForModule(m.Name()) {
		if e.Action != state.ActionApply {
			continue
		}
		domain := e.Detail
		if i := strings.LastIndex(domain, " "); i >= 0 {
			domain = domain[:i]
		}
		for key, prev := range e.Before {
			prevStr, _ := prev.(string)
			if prevStr == "" {
				continue
			}
			if err := ctx.Runner.Run("defaults", "write", domain, key, "-string", prevStr); err != nil {
				ctx.Log.Warnf("revert %s.%s: %v", domain, key, err)
				continue
			}
			reverted++
		}
	}
	macos.RestartFrequent(ctx, "Dock", "Finder")
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK, Detail: fmt.Sprintf("%d preferences reverted", reverted)})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	if !m.Enabled(ctx.Config) {
		return nil
	}
	if macos.Read(ctx, macos.FinderDomain, "AppleShowAllFiles") == "0" && boolOf(ctx.Config.MacOS.Finder, "show_hidden", true) {
		return fmt.Errorf("Finder show_hidden preference not applied")
	}
	return nil
}

// buildRules translates the config.macos section maps into defaults rules.
func buildRules(mo config.MacOSConfig) []macos.Rule {
	var rules []macos.Rule
	rule := func(domain, key string, value any) {
		rules = append(rules, macos.Rule{Domain: domain, Key: key, Value: value})
	}

	for k, v := range mo.Finder {
		switch k {
		case "show_hidden":
			rule(macos.FinderDomain, "AppleShowAllFiles", v)
		case "show_path_bar":
			rule(macos.FinderDomain, "ShowPathbar", v)
		case "show_status_bar":
			rule(macos.FinderDomain, "ShowStatusBar", v)
		case "show_all_extensions":
			rule(macos.FinderDomain, "AppleShowAllExtensions", v)
		}
	}
	for k, v := range mo.Dock {
		switch k {
		case "autohide":
			rule(macos.DockDomain, "autohide", v)
		case "autohide_delay":
			rule(macos.DockDomain, "autohide-delay", toFloat(v))
		case "remove_animation_delay":
			if b, ok := v.(bool); ok && b {
				rule(macos.DockDomain, "autohide-delay", 0.0)
			}
		case "magnification":
			rule(macos.DockDomain, "magnification", v)
		case "icon_size":
			rule(macos.DockDomain, "tilesize", toInt(v))
		case "show_recents":
			rule(macos.DockDomain, "show-recents", v)
		case "minimize_effect":
			rule(macos.DockDomain, "mineffect", toStr(v))
		}
	}
	for k, v := range mo.Trackpad {
		if k == "tap_to_click" {
			rule(macos.TrackpadDomain, "Clicking", v)
			rule(macos.BluetoothTP, "Clicking", v)
		}
	}
	for k, v := range mo.Keyboard {
		switch k {
		case "key_repeat":
			rule(macos.NSGlobalDomain, "KeyRepeat", toInt(v))
		case "initial_repeat":
			rule(macos.NSGlobalDomain, "InitialKeyRepeat", toInt(v))
		}
	}
	for k, v := range mo.MissionControl {
		if k == "workspaces_per_display" {
			rule(macos.DockDomain, "mru-spaces", v)
		}
	}
	for k, v := range mo.Screenshots {
		switch k {
		case "location":
			rule(macos.ScreenDomain, "location", expandHome(toStr(v)))
		case "disable_shadow":
			rule(macos.ScreenDomain, "disable-shadow", v)
		case "type":
			rule(macos.ScreenDomain, "type", toStr(v))
		}
	}
	for k, v := range mo.Desktop {
		if k == "show_hard_disks" {
			rule(macos.FinderDomain, "ShowHardDrivesOnDesktop", v)
		}
	}
	for k, v := range mo.Login {
		if k == "show_boot_message" {
			if msg := toStr(v); msg != "" && msg != "false" {
				rule(macos.LoginDomain, "LoginwindowText", msg)
			}
		}
	}
	for k, v := range mo.Update {
		if k == "auto_update" {
			rule("com.apple.SoftwareUpdate", "AutomaticCheckEnabled", v)
		}
	}
	for k, v := range mo.Privacy {
		if k == "analytics" {
			rule("com.apple.SubmitDiagInfo", "AutoSubmit", v)
		}
	}
	return rules
}

func boolOf(m map[string]any, key string, def bool) bool {
	if v, ok := m[key].(bool); ok {
		return v
	}
	return def
}

func toFloat(v any) float64 {
	switch t := v.(type) {
	case float64:
		return t
	case int:
		return float64(t)
	case bool:
		if t {
			return 1
		}
		return 0
	}
	return 0
}

func toInt(v any) int {
	switch t := v.(type) {
	case int:
		return t
	case float64:
		return int(t)
	case bool:
		if t {
			return 1
		}
		return 0
	}
	return 0
}

func toStr(v any) string {
	if s, ok := v.(string); ok {
		return s
	}
	return fmt.Sprintf("%v", v)
}

func expandHome(p string) string {
	if p == "~" || strings.HasPrefix(p, "~/") {
		if home, err := os.UserHomeDir(); err == nil {
			return filepath.Join(home, strings.TrimPrefix(p, "~/"))
		}
	}
	return p
}
