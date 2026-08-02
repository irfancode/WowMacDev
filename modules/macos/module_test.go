package macosmodule

import (
	"testing"

	"github.com/omamac/omamac/internal/config"
)

func TestBuildRules(t *testing.T) {
	cfg := config.MacOSConfig{
		Finder:         map[string]any{"show_hidden": true, "show_path_bar": true},
		Dock:           map[string]any{"autohide": true, "icon_size": 36, "remove_animation_delay": true},
		Trackpad:       map[string]any{"tap_to_click": true},
		Keyboard:       map[string]any{"key_repeat": 2, "initial_repeat": 15},
		MissionControl: map[string]any{"workspaces_per_display": true},
		Screenshots:    map[string]any{"location": "~/Pictures/Screenshots", "disable_shadow": true},
		Desktop:        map[string]any{"show_hard_disks": false},
		Login:          map[string]any{"show_boot_message": false},
		Update:         map[string]any{"auto_update": false},
		Privacy:        map[string]any{"analytics": false},
	}
	rules := buildRules(cfg)

	byKey := map[string]any{}
	for _, r := range rules {
		byKey[r.Domain+"."+r.Key] = r.Value
	}

	checks := map[string]struct {
		key  string
		want any
	}{
		"finder hidden":      {"com.apple.finder.AppleShowAllFiles", true},
		"finder pathbar":     {"com.apple.finder.ShowPathbar", true},
		"dock autohide":      {"com.apple.dock.autohide", true},
		"dock tilesize":      {"com.apple.dock.tilesize", 36},
		"dock delay zero":    {"com.apple.dock.autohide-delay", 0.0},
		"trackpad tap":       {"com.apple.AppleMultitouchTrackpad.Clicking", true},
		"keyboard repeat":    {"NSGlobalDomain.KeyRepeat", 2},
		"screenshot shadow":  {"com.apple.screencapture.disable-shadow", true},
		"desktop hard disks": {"com.apple.finder.ShowHardDrivesOnDesktop", false},
		"update check":       {"com.apple.SoftwareUpdate.AutomaticCheckEnabled", false},
		"privacy analytics":  {"com.apple.SubmitDiagInfo.AutoSubmit", false},
	}
	for name, c := range checks {
		if _, ok := byKey[c.key]; !ok {
			t.Errorf("%s: rule %q not produced", name, c.key)
			continue
		}
		if got, want := byKey[c.key], c.want; got != want {
			t.Errorf("%s: %s = %v, want %v", name, c.key, got, want)
		}
	}

	if v, ok := byKey["com.apple.screencapture.location"].(string); !ok || len(v) < len("/Pictures/Screenshots") || v[len(v)-len("/Pictures/Screenshots"):] != "/Pictures/Screenshots" {
		t.Errorf("screenshot location not expanded from home dir: %v", byKey["com.apple.screencapture.location"])
	}

	for _, r := range rules {
		if r.Domain == "com.apple.loginwindow" {
			t.Errorf("show_boot_message=false must not produce a rule, got %+v", r)
		}
	}
}
