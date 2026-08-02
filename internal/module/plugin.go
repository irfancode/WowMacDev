package module

import (
	"bufio"
	"encoding/json"
	"fmt"
	"log/slog"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"github.com/omamac/omamac/internal/config"
	"gopkg.in/yaml.v3"
)

// Plugin is a third-party capability packaged as a directory with a
// plugin.yaml manifest and shell scripts implementing the module contract.
type Plugin struct {
	Name        string            `yaml:"name"`
	Title       string            `yaml:"title"`
	Description string            `yaml:"description"`
	DependsOn   []string          `yaml:"depends_on"`
	Commands    map[string]string `yaml:"commands"`
	Config      map[string]any    `yaml:"config"`

	// Dir is the absolute path to the plugin directory.
	Dir string `yaml:"-"`
}

var pluginNameRe = regexp.MustCompile(`^[a-z0-9][a-z0-9._-]*$`)

// LoadPluginDir loads and validates a single plugin directory (a directory
// containing plugin.yaml). It is used for targeted loads such as `omamac
// plugins add`, which must not scan unrelated directories.
func LoadPluginDir(dir string) (*Plugin, error) {
	manifest := filepath.Join(dir, "plugin.yaml")
	data, err := os.ReadFile(manifest)
	if err != nil {
		return nil, fmt.Errorf("plugin %s: %w", dir, err)
	}
	p := &Plugin{}
	if err := yaml.Unmarshal(data, p); err != nil {
		return nil, fmt.Errorf("plugin %s: %w", dir, err)
	}
	p.Dir = dir
	if err := validatePlugin(p); err != nil {
		return nil, fmt.Errorf("plugin %s: %w", dir, err)
	}
	return p, nil
}

// LoadPlugins scans base directories of the form <base>/<group>/<name> for
// plugin.yaml manifests and returns valid plugins. A plugin that fails
// validation is skipped and returned with an error for reporting.
func LoadPlugins(bases ...string) ([]*Plugin, error) {
	var out []*Plugin
	for _, base := range bases {
		groups, err := os.ReadDir(base)
		if os.IsNotExist(err) {
			continue
		}
		if err != nil {
			return nil, fmt.Errorf("read plugins dir %s: %w", base, err)
		}
		for _, g := range groups {
			if !g.IsDir() {
				continue
			}
			groupDir := filepath.Join(base, g.Name())
			entries, err := os.ReadDir(groupDir)
			if err != nil {
				continue
			}
			for _, e := range entries {
				if !e.IsDir() {
					continue
				}
				pdir := filepath.Join(groupDir, e.Name())
				if _, err := os.Stat(filepath.Join(pdir, ".disabled")); err == nil {
					continue // plugin explicitly disabled
				}
				p, err := LoadPluginDir(pdir)
				if err != nil {
					return nil, err
				}
				out = append(out, p)
			}
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Name < out[j].Name })
	return out, nil
}

func validatePlugin(p *Plugin) error {
	if p.Name == "" || !pluginNameRe.MatchString(p.Name) {
		return fmt.Errorf("invalid name %q", p.Name)
	}
	for action, rel := range p.Commands {
		switch action {
		case "install", "update", "remove", "verify":
		default:
			return fmt.Errorf("unknown command %q", action)
		}
		if filepath.IsAbs(rel) || strings.Contains(rel, "..") {
			return fmt.Errorf("command %q path %q must be relative", action, rel)
		}
		full := filepath.Join(p.Dir, rel)
		info, err := os.Stat(full)
		if err != nil {
			return fmt.Errorf("command %q file missing: %w", action, err)
		}
		if info.IsDir() {
			return fmt.Errorf("command %q path %q is a directory", action, rel)
		}
	}
	return nil
}

// Dependencies returns the declared plugin dependencies.
func (p *Plugin) Dependencies() []string { return p.DependsOn }

// Adapter turns a Plugin into a Module.
type adapter struct {
	plugin *Plugin
}

// Adapter wraps a Plugin as a Module.
func (p *Plugin) Adapter() Module { return &adapter{plugin: p} }

func (a *adapter) Name() string { return a.plugin.Name }
func (a *adapter) Summary() string {
	if a.plugin.Title != "" {
		return a.plugin.Title + ": " + a.plugin.Description
	}
	return a.plugin.Description
}
func (a *adapter) Priority() int { return 100 }

func (a *adapter) Enabled(cfg *config.Config) bool {
	// Plugins are enabled unless disabled via config or CLI filters.
	return true
}

func (a *adapter) Install(ctx *Context) error { return a.run(ctx, "install") }
func (a *adapter) Update(ctx *Context) error  { return a.run(ctx, "update") }
func (a *adapter) Remove(ctx *Context) error  { return a.run(ctx, "remove") }
func (a *adapter) Verify(ctx *Context) error  { return a.run(ctx, "verify") }

func (a *adapter) run(ctx *Context, action string) error {
	rel, ok := a.plugin.Commands[action]
	if !ok || rel == "" {
		ctx.Log.Debugf("plugin has no %s command", action)
		return nil
	}
	script := filepath.Join(a.plugin.Dir, rel)
	env := append(os.Environ(),
		"OMAMAC_ACTION="+action,
		"OMAMAC_PLUGIN_NAME="+a.plugin.Name,
		"OMAMAC_PLUGIN_DIR="+a.plugin.Dir,
		"OMAMAC_CONFIG_DIR="+ctx.ConfigDir,
		"OMAMAC_DATA_DIR="+ctx.DataDir,
		"OMAMAC_STATE_DIR="+ctx.StateDir,
		"OMAMAC_HOME="+ctx.HomeDir,
		"OMAMAC_DRY_RUN="+boolStr(ctx.DryRun),
		"OMAMAC_JSON="+boolStr(ctx.JSON),
		"OMAMAC_VERBOSE="+boolStr(ctx.Verbose),
	)
	if cfg, err := json.Marshal(a.plugin.Config); err == nil {
		env = append(env, "OMAMAC_PLUGIN_CONFIG="+string(cfg))
	}

	if ctx.DryRun {
		ctx.Log.Stepf("[dry-run] %s %s", script, action)
		return nil
	}

	cmd := exec.Command("/bin/bash", script)
	cmd.Env = env
	cmd.Dir = a.plugin.Dir
	ctx.Log.Stepf("%s %s", a.plugin.Name, action)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return err
	}
	cmd.Stderr = ctx.Log.Writer(slog.LevelInfo)
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("plugin %s %s: %w", a.plugin.Name, action, err)
	}
	if ctx.Verbose {
		sc := bufio.NewScanner(stdout)
		for sc.Scan() {
			ctx.Log.Infof("[%s] %s", a.plugin.Name, sc.Text())
		}
	}
	if err := cmd.Wait(); err != nil {
		return fmt.Errorf("plugin %s %s failed: %w", a.plugin.Name, action, err)
	}
	return nil
}

func boolStr(b bool) string {
	if b {
		return "1"
	}
	return "0"
}
