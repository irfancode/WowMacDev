// Package config loads, validates and merges omamac configuration. Layering
// is: embedded defaults < ~/.config/omamac/config.yaml < OMAMAC_CONFIG file
// < --config file. Later layers deep-merge over earlier ones.
package config

import (
	_ "embed"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"gopkg.in/yaml.v3"
)

// AppName is the canonical product name.
const AppName = "omamac"

// CurrentVersion is the supported schema version.
const CurrentVersion = 1

// DefaultConfigPath returns the default user config path for the platform.
func DefaultConfigPath() string {
	return filepath.Join(ConfigDir(), "config.yaml")
}

// ConfigDir returns the per-user configuration directory. omamac deliberately
// uses the XDG convention (~/.config/omamac) rather than Apple's
// ~/Library/Application Support so configs are easy to find, dotfile-manage
// and commit.
func ConfigDir() string {
	if v := os.Getenv("OMAMAC_CONFIG_DIR"); v != "" {
		return v
	}
	if v := os.Getenv("XDG_CONFIG_HOME"); v != "" {
		return filepath.Join(v, AppName)
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return filepath.Join(".config", AppName)
	}
	return filepath.Join(home, ".config", AppName)
}

// DataDir returns the per-user data directory (plugins, backups, cache).
func DataDir() string {
	if v := os.Getenv("OMAMAC_DATA_DIR"); v != "" {
		return v
	}
	base, err := os.UserHomeDir()
	if err != nil {
		return filepath.Join(".local", "share", AppName)
	}
	return filepath.Join(base, ".local", "share", AppName)
}

// StateDir returns the per-user state directory (journal).
func StateDir() string {
	if v := os.Getenv("OMAMAC_STATE_DIR"); v != "" {
		return v
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return filepath.Join(".local", "state", AppName)
	}
	return filepath.Join(home, ".local", "state", AppName)
}

//go:embed defaults.yaml
var defaultsYAML []byte

// Config is the fully resolved omamac configuration.
type Config struct {
	App     string   `yaml:"app"`
	Version int      `yaml:"version"`
	Modules []string `yaml:"modules"` // optional whitelist
	Disable []string `yaml:"disable"` // force-disable these modules

	Homebrew     HomebrewConfig     `yaml:"homebrew"`
	Apps         AppsConfig         `yaml:"apps"`
	Languages    []string           `yaml:"languages"`
	Tools        []string           `yaml:"tools"`
	Shell        ShellConfig        `yaml:"shell"`
	Git          GitConfig          `yaml:"git"`
	VSCode       VSCodeConfig       `yaml:"vscode"`
	AI           AIConfig           `yaml:"ai"`
	Terminal     TerminalConfig     `yaml:"terminal"`
	Fonts        []string           `yaml:"fonts"`
	MacOS        MacOSConfig        `yaml:"macos"`
	Security     SecurityConfig     `yaml:"security"`
	Productivity ProductivityConfig `yaml:"productivity"`
	Dotfiles     DotfilesConfig     `yaml:"dotfiles"`
	Cleanup      CleanupConfig      `yaml:"cleanup"`
}

// HomebrewConfig declares taps, formulae and casks to manage declaratively.
type HomebrewConfig struct {
	Taps     []string `yaml:"taps"`
	Formulae []string `yaml:"formulae"`
	Casks    []string `yaml:"casks"`
	Update   bool     `yaml:"update"`
	Upgrade  bool     `yaml:"upgrade"`
	Cleanup  bool     `yaml:"cleanup"`
}

// AppsConfig groups applications by category. Each entry is a canonical app
// id resolved by the apps module.
type AppsConfig struct {
	Browser       []string `yaml:"browser"`
	Development   []string `yaml:"development"`
	Communication []string `yaml:"communication"`
	Utilities     []string `yaml:"utilities"`
	Creative      []string `yaml:"creative"`
	Extra         []string `yaml:"extra"`
}

// All returns every configured app id.
func (a AppsConfig) All() []string {
	var out []string
	out = append(out, a.Browser...)
	out = append(out, a.Development...)
	out = append(out, a.Communication...)
	out = append(out, a.Utilities...)
	out = append(out, a.Creative...)
	out = append(out, a.Extra...)
	return out
}

// ShellConfig controls shell enhancements.
type ShellConfig struct {
	Shell   string   `yaml:"shell"`
	Prompt  string   `yaml:"prompt"`
	Aliases []string `yaml:"aliases"`
	Env     []string `yaml:"env"`
}

// GitConfig controls git identity and tooling.
type GitConfig struct {
	DefaultBranch string   `yaml:"default_branch"`
	UserName      string   `yaml:"user_name"`
	UserEmail     string   `yaml:"user_email"`
	Editor        string   `yaml:"editor"`
	LFS           bool     `yaml:"lfs"`
	SSH           bool     `yaml:"ssh"`
	GPG           bool     `yaml:"gpg"`
	GitHubAuth    bool     `yaml:"github_auth"`
	Aliases       []string `yaml:"aliases"`
}

// VSCodeConfig controls VS Code provisioning.
type VSCodeConfig struct {
	Enable     bool     `yaml:"enable"`
	Extensions []string `yaml:"extensions"`
	Theme      string   `yaml:"theme"`
	Font       string   `yaml:"font"`
}

// AIConfig toggles AI developer tools.
type AIConfig struct {
	Claude   bool     `yaml:"claude"`
	OpenCode bool     `yaml:"opencode"`
	Gemini   bool     `yaml:"gemini"`
	OpenAI   bool     `yaml:"openai"`
	Copilot  bool     `yaml:"copilot"`
	Ollama   bool     `yaml:"ollama"`
	Models   []string `yaml:"models"`
}

// TerminalConfig toggles terminal emulators and a theme.
type TerminalConfig struct {
	Ghostty     bool   `yaml:"ghostty"`
	Warp        bool   `yaml:"warp"`
	ITerm2      bool   `yaml:"iterm2"`
	TerminalApp bool   `yaml:"terminal_app"`
	Theme       string `yaml:"theme"`
}

// MacOSConfig groups macOS `defaults` settings by preference pane. Values are
// free-form (bool/int/string) and interpreted by the macos module.
type MacOSConfig struct {
	Enable         bool           `yaml:"enable"`
	Finder         map[string]any `yaml:"finder"`
	Dock           map[string]any `yaml:"dock"`
	Trackpad       map[string]any `yaml:"trackpad"`
	Keyboard       map[string]any `yaml:"keyboard"`
	MissionControl map[string]any `yaml:"mission_control"`
	Screenshots    map[string]any `yaml:"screenshots"`
	Desktop        map[string]any `yaml:"desktop"`
	Login          map[string]any `yaml:"login"`
	Energy         map[string]any `yaml:"energy"`
	Update         map[string]any `yaml:"update"`
	Privacy        map[string]any `yaml:"privacy"`
}

// SecurityConfig toggles system hardening checks.
type SecurityConfig struct {
	Enable     bool `yaml:"enable"`
	Firewall   bool `yaml:"firewall"`
	FileVault  bool `yaml:"filevault"`
	Gatekeeper bool `yaml:"gatekeeper"`
	SSH        bool `yaml:"ssh"`
}

// ProductivityConfig toggles utility apps and their settings.
type ProductivityConfig struct {
	Raycast   map[string]any `yaml:"raycast"`
	Rectangle map[string]any `yaml:"rectangle"`
	HiddenBar map[string]any `yaml:"hidden_bar"`
	Stats     map[string]any `yaml:"stats"`
}

// DotfilesConfig points at a dotfiles repository to manage.
type DotfilesConfig struct {
	Repo   string   `yaml:"repo"`
	Branch string   `yaml:"branch"`
	Local  string   `yaml:"local"`
	Links  []string `yaml:"links"`
}

// CleanupConfig toggles post-install cleanup jobs.
type CleanupConfig struct {
	Enable   bool `yaml:"enable"`
	Cache    bool `yaml:"cache"`
	Trash    bool `yaml:"trash"`
	Homebrew bool `yaml:"homebrew"`
}

// Load resolves configuration from the given ordered file paths (later wins).
// An empty list still yields the embedded defaults.
func Load(paths ...string) (*Config, error) {
	merged, err := loadLayers(paths)
	if err != nil {
		return nil, err
	}

	cfg := &Config{}
	if err := decodeStrict(merged, cfg); err != nil {
		return nil, err
	}
	if err := cfg.validate(); err != nil {
		return nil, err
	}
	return cfg, nil
}

// LoadFile reads and validates a single config file in isolation.
func LoadFile(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	cfg := &Config{}
	if err := decodeStrict(data, cfg); err != nil {
		return nil, fmt.Errorf("config %s: %w", path, err)
	}
	if err := cfg.validate(); err != nil {
		return nil, fmt.Errorf("config %s: %w", path, err)
	}
	return cfg, nil
}

// Dump renders the config as YAML bytes.
func (c *Config) Dump() ([]byte, error) {
	return yaml.Marshal(c)
}

func (c *Config) validate() error {
	if c.App != "" && c.App != AppName {
		return fmt.Errorf("unsupported app name %q (expected %q)", c.App, AppName)
	}
	if c.Version != 0 && c.Version != CurrentVersion {
		return fmt.Errorf("unsupported config version %d (supported: %d)", c.Version, CurrentVersion)
	}
	for _, m := range append(append([]string{}, c.Modules...), c.Disable...) {
		if m != strings.TrimSpace(m) || m == "" {
			return fmt.Errorf("invalid module reference %q", m)
		}
	}
	return nil
}

// loadLayers merges defaults with each existing file, deep-merging maps and
// replacing slices/scalars.
func loadLayers(paths []string) ([]byte, error) {
	merged := map[string]any{}
	if err := yaml.Unmarshal(defaultsYAML, &merged); err != nil {
		return nil, fmt.Errorf("parse embedded defaults: %w", err)
	}
	for _, p := range paths {
		if p == "" {
			continue
		}
		data, err := os.ReadFile(p)
		if err != nil {
			if os.IsNotExist(err) {
				continue
			}
			return nil, fmt.Errorf("read config %s: %w", p, err)
		}
		layer := map[string]any{}
		if err := yaml.Unmarshal(data, &layer); err != nil {
			return nil, fmt.Errorf("parse config %s: %w", p, err)
		}
		mergeMaps(merged, layer)
	}
	return yaml.Marshal(merged)
}

// mergeMaps recursively merges src into dst. Maps merge key-by-key; all other
// values (including slices and nil) overwrite dst.
func mergeMaps(dst, src map[string]any) {
	for k, sv := range src {
		dv, ok := dst[k]
		if !ok {
			dst[k] = sv
			continue
		}
		dm, dok := dv.(map[string]any)
		sm, sok := sv.(map[string]any)
		if dok && sok {
			mergeMaps(dm, sm)
			continue
		}
		dst[k] = sv
	}
}

// decodeStrict decodes YAML into v, rejecting unknown fields to catch typos.
func decodeStrict(data []byte, v any) error {
	dec := yaml.NewDecoder(strings.NewReader(string(data)))
	dec.KnownFields(true)
	if err := dec.Decode(v); err != nil {
		return fmt.Errorf("decode config: %w", err)
	}
	return nil
}
