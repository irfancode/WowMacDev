package config

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func writeTemp(t *testing.T, name, content string) string {
	t.Helper()
	dir := t.TempDir()
	p := filepath.Join(dir, name)
	if err := os.WriteFile(p, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
	return p
}

func TestDefaultsLoad(t *testing.T) {
	cfg, err := Load()
	if err != nil {
		t.Fatalf("Load defaults: %v", err)
	}
	if cfg.App != AppName {
		t.Errorf("app = %q", cfg.App)
	}
	if cfg.Homebrew.Update != true {
		t.Error("default homebrew.update should be true")
	}
	if len(cfg.Homebrew.Formulae) == 0 {
		t.Error("default formulae should be non-empty")
	}
	if !cfg.MacOS.Enable {
		t.Error("macos should be enabled by default")
	}
}

func TestUserOverride(t *testing.T) {
	user := writeTemp(t, "user.yaml", "homebrew:\n  update: false\n  formulae:\n    - htop\n")
	cfg, err := Load(user)
	if err != nil {
		t.Fatal(err)
	}
	if cfg.Homebrew.Update {
		t.Error("user override for update should win")
	}
	if len(cfg.Homebrew.Formulae) != 1 || cfg.Homebrew.Formulae[0] != "htop" {
		t.Errorf("formulae should be replaced: %v", cfg.Homebrew.Formulae)
	}
	if !cfg.MacOS.Enable {
		t.Error("untouched sections should keep defaults")
	}
}

func TestDeepMerge(t *testing.T) {
	user := writeTemp(t, "user.yaml", "macos:\n  dock:\n    icon_size: 48\n")
	cfg, err := Load(user)
	if err != nil {
		t.Fatal(err)
	}
	if cfg.MacOS.Dock["icon_size"] != 48 {
		t.Errorf("icon_size = %v", cfg.MacOS.Dock["icon_size"])
	}
	if cfg.MacOS.Dock["autohide"] != true {
		t.Errorf("autohide should survive merge: %v", cfg.MacOS.Dock["autohide"])
	}
}

func TestUnknownFieldRejected(t *testing.T) {
	bad := writeTemp(t, "bad.yaml", "hombrew:\n  update: true\n")
	if _, err := Load(bad); err == nil {
		t.Fatal("expected error for unknown field 'hombrew'")
	}
}

func TestLayeringOrder(t *testing.T) {
	a := writeTemp(t, "a.yaml", "shell:\n  prompt: zsh\n")
	b := writeTemp(t, "b.yaml", "shell:\n  prompt: starship\n")
	cfg, err := Load(a, b)
	if err != nil {
		t.Fatal(err)
	}
	if cfg.Shell.Prompt != "starship" {
		t.Errorf("prompt = %q, want starship (later layer wins)", cfg.Shell.Prompt)
	}
}

func TestMissingLayerIgnored(t *testing.T) {
	cfg, err := Load("/nonexistent/omamac/config.yaml")
	if err != nil {
		t.Fatalf("missing file should be ignored: %v", err)
	}
	if cfg.App != AppName {
		t.Error("defaults should still apply")
	}
}

func TestAppsAll(t *testing.T) {
	a := AppsConfig{Browser: []string{"Arc"}, Development: []string{"Zed"}, Utilities: []string{"Raycast"}}
	all := a.All()
	if len(all) != 3 || !contains(all, "Arc") || !contains(all, "Zed") || !contains(all, "Raycast") {
		t.Errorf("All() = %v", all)
	}
}

func TestVersionMismatch(t *testing.T) {
	bad := writeTemp(t, "v.yaml", "version: 99\n")
	if _, err := Load(bad); err == nil || !strings.Contains(err.Error(), "unsupported config version") {
		t.Fatalf("expected version error, got %v", err)
	}
}

func contains(xs []string, s string) bool {
	for _, x := range xs {
		if x == s {
			return true
		}
	}
	return false
}
