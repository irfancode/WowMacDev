package module

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/omamac/omamac/internal/config"
)

func writePlugin(t *testing.T, base, group, name string, manifest string, scripts map[string]string) string {
	t.Helper()
	dir := filepath.Join(base, group, name)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(dir, "plugin.yaml"), []byte(manifest), 0o644); err != nil {
		t.Fatal(err)
	}
	for fn, body := range scripts {
		if err := os.WriteFile(filepath.Join(dir, fn), []byte(body), 0o755); err != nil {
			t.Fatal(err)
		}
	}
	return dir
}

const goodManifest = `name: acme
title: ACME Tooling
description: Internal tools
depends_on: [homebrew]
commands:
  install: ./install.sh
  verify: ./verify.sh
config:
  region: us-east-1
`

func TestLoadPlugins(t *testing.T) {
	base := t.TempDir()
	writePlugin(t, base, "company", "acme", goodManifest,
		map[string]string{"install.sh": "#!/bin/bash\necho hi\n", "verify.sh": "#!/bin/bash\n"})

	plugins, err := LoadPlugins(base)
	if err != nil {
		t.Fatal(err)
	}
	if len(plugins) != 1 {
		t.Fatalf("plugins = %d, want 1", len(plugins))
	}
	p := plugins[0]
	if p.Name != "acme" || len(p.DependsOn) != 1 || p.DependsOn[0] != "homebrew" {
		t.Errorf("plugin fields wrong: %+v", p)
	}
	if p.Config["region"] != "us-east-1" {
		t.Errorf("plugin config not loaded: %+v", p.Config)
	}
}

func TestPluginAdapter(t *testing.T) {
	base := t.TempDir()
	writePlugin(t, base, "company", "acme", goodManifest,
		map[string]string{"install.sh": "#!/bin/bash\necho done\n", "verify.sh": "#!/bin/bash\n"})
	plugins, _ := LoadPlugins(base)
	m := plugins[0].Adapter()

	if m.Name() != "acme" || !m.Enabled(&config.Config{}) {
		t.Error("adapter metadata wrong")
	}
	if m.Priority() != 100 {
		t.Errorf("priority = %d", m.Priority())
	}
}

func TestInvalidPluginRejected(t *testing.T) {
	base := t.TempDir()
	// name with uppercase is invalid
	writePlugin(t, base, "group", "Bad_Name", `name: Bad_Name
commands:
  install: ./install.sh
`, map[string]string{"install.sh": "#!/bin/bash\n"})

	if _, err := LoadPlugins(base); err == nil {
		t.Fatal("expected validation error")
	}
}

func TestMissingCommandFileRejected(t *testing.T) {
	base := t.TempDir()
	writePlugin(t, base, "g", "x", `name: x
commands:
  install: ./nope.sh
`, nil)
	if _, err := LoadPlugins(base); err == nil {
		t.Fatal("expected error for missing script")
	}
}

func TestMissingPluginDirOK(t *testing.T) {
	plugins, err := LoadPlugins("/nonexistent/plugins")
	if err != nil {
		t.Fatal(err)
	}
	if len(plugins) != 0 {
		t.Errorf("plugins = %d, want 0", len(plugins))
	}
}

func TestRegistryFilter(t *testing.T) {
	r := New()
	r.Register(&fakeModule{name: "one", priority: 1, enabled: true})
	r.Register(&fakeModule{name: "two", priority: 0, enabled: false})

	// ordering by priority, disabled skipped
	ms, err := r.Filter(&config.Config{}, nil, nil)
	if err != nil {
		t.Fatal(err)
	}
	if len(ms) != 1 || ms[0].Name() != "one" {
		t.Errorf("filter = %v", ms)
	}

	// whitelist of a disabled module yields nothing
	ms, err = r.Filter(&config.Config{Modules: []string{"two"}}, nil, nil)
	if err != nil {
		t.Fatal(err)
	}
	if len(ms) != 0 {
		t.Errorf("whitelist of disabled module = %v, want []", ms)
	}

	// whitelist of an enabled module
	ms, err = r.Filter(&config.Config{Modules: []string{"one"}}, nil, nil)
	if err != nil {
		t.Fatal(err)
	}
	if len(ms) != 1 || ms[0].Name() != "one" {
		t.Errorf("whitelist filter = %v", ms)
	}

	// unknown module errors
	if _, err := r.Filter(&config.Config{Modules: []string{"nope"}}, nil, nil); err == nil {
		t.Error("expected unknown module error")
	}
}

type fakeModule struct {
	name     string
	summary  string
	priority int
	enabled  bool
}

func (f *fakeModule) Name() string                { return f.name }
func (f *fakeModule) Summary() string             { return strings.ToUpper(f.name) }
func (f *fakeModule) Priority() int               { return f.priority }
func (f *fakeModule) Enabled(*config.Config) bool { return f.enabled }
func (f *fakeModule) Install(*Context) error      { return nil }
func (f *fakeModule) Update(*Context) error       { return nil }
func (f *fakeModule) Remove(*Context) error       { return nil }
func (f *fakeModule) Verify(*Context) error       { return nil }
