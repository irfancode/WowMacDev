// Package homebrew wraps the Homebrew CLI. Operations are idempotent: brew is
// only invoked for missing formulae/casks, and the installed set is cached
// from `brew list --json=v2`.
package homebrew

import (
	"fmt"
	"sort"
	"strings"

	"github.com/irfancode/omamac/internal/logging"
	"github.com/irfancode/omamac/internal/module"
	"github.com/irfancode/omamac/internal/util"
)

// Brew talks to Homebrew via the util.Runner (respecting dry-run).
type Brew struct {
	Runner *util.Runner
	Log    *logging.Logger
	cache  *installed
}

type installed struct {
	formulae map[string]bool
	casks    map[string]bool
}

// New returns a Brew wrapper.
func New(runner *util.Runner, log *logging.Logger) *Brew {
	return &Brew{Runner: runner, Log: log}
}

// Installed reports whether the brew binary is available.
func (b *Brew) Installed() bool { return b.Runner.Exists("brew") }

// Path returns the brew binary path.
func (b *Brew) Path() string {
	if p, err := util.LookPath("brew"); err == nil {
		return p
	}
	return util.HomebrewBin()
}

// EnsureInstalled installs Homebrew via the official script if missing.
func (b *Brew) EnsureInstalled(ctx *module.Context) error {
	if b.Installed() {
		return nil
	}
	ctx.Log.Warn("Homebrew is not installed; running the official installer (may prompt for your password)")
	script := `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
	return b.Runner.Script(script)
}

// Update runs `brew update`.
func (b *Brew) Update(ctx *module.Context) error {
	return b.Runner.Run(b.Path(), "update", "--quiet")
}

// Upgrade upgrades all formulae.
func (b *Brew) Upgrade(ctx *module.Context) error {
	return b.Runner.Run(b.Path(), "upgrade")
}

// UpgradeCasks upgrades all casks.
func (b *Brew) UpgradeCasks(ctx *module.Context) error {
	return b.Runner.Run(b.Path(), "upgrade", "--cask")
}

// Cleanup removes stale versions and caches.
func (b *Brew) Cleanup(ctx *module.Context) error {
	return b.Runner.Run(b.Path(), "cleanup", "--prune=all")
}

// Autoupdate toggles `HOMEBREW_NO_AUTO_UPDATE` for the given runner calls.
// Kept as a helper for callers that manage their own runner.

// Tap adds taps.
func (b *Brew) Tap(ctx *module.Context, taps ...string) error {
	if len(taps) == 0 {
		return nil
	}
	ctx.Log.Infof("adding taps: %s", strings.Join(taps, ", "))
	return b.Runner.Run(b.Path(), append([]string{"tap"}, taps...)...)
}

// Untap removes taps.
func (b *Brew) Untap(ctx *module.Context, taps ...string) error {
	if len(taps) == 0 {
		return nil
	}
	return b.Runner.Run(b.Path(), append([]string{"untap"}, taps...)...)
}

// InstallFormulae installs the given formulae that are not already installed.
func (b *Brew) InstallFormulae(ctx *module.Context, names ...string) error {
	inst, err := b.installedSet()
	if err != nil {
		return err
	}
	var missing []string
	for _, n := range names {
		if !inst.formulae[n] {
			missing = append(missing, n)
		}
	}
	if len(missing) == 0 {
		return nil
	}
	ctx.Log.Infof("installing formulae: %s", strings.Join(missing, ", "))
	args := append([]string{"install"}, missing...)
	if err := b.Runner.Run(b.Path(), args...); err != nil {
		return fmt.Errorf("brew install formulae: %w", err)
	}
	b.refresh()
	return nil
}

// InstallCasks installs the given casks that are not already installed.
func (b *Brew) InstallCasks(ctx *module.Context, names ...string) error {
	inst, err := b.installedSet()
	if err != nil {
		return err
	}
	var missing []string
	for _, n := range names {
		if !inst.casks[n] {
			missing = append(missing, n)
		}
	}
	if len(missing) == 0 {
		return nil
	}
	ctx.Log.Infof("installing casks: %s", strings.Join(missing, ", "))
	args := append([]string{"install", "--cask"}, missing...)
	if err := b.Runner.Run(b.Path(), args...); err != nil {
		return fmt.Errorf("brew install casks: %w", err)
	}
	b.refresh()
	return nil
}

// Uninstall removes formulae/casks. It reports which were actually removed.
func (b *Brew) Uninstall(ctx *module.Context, formulae, casks []string) error {
	inst, err := b.installedSet()
	if err != nil {
		return err
	}
	var f, c []string
	for _, n := range formulae {
		if inst.formulae[n] {
			f = append(f, n)
		}
	}
	for _, n := range casks {
		if inst.casks[n] {
			c = append(c, n)
		}
	}
	if len(f) > 0 {
		if err := b.Runner.Run(b.Path(), append([]string{"uninstall"}, f...)...); err != nil {
			return err
		}
	}
	if len(c) > 0 {
		if err := b.Runner.Run(b.Path(), append([]string{"uninstall", "--cask"}, c...)...); err != nil {
			return err
		}
	}
	b.refresh()
	return nil
}

// HasFormula reports whether a formula is installed.
func (b *Brew) HasFormula(name string) bool {
	inst, err := b.installedSet()
	return err == nil && inst.formulae[name]
}

// HasCask reports whether a cask is installed.
func (b *Brew) HasCask(name string) bool {
	inst, err := b.installedSet()
	return err == nil && inst.casks[name]
}

// MissingFormulae returns configured formulae that are not installed.
func (b *Brew) MissingFormulae(names []string) []string {
	inst, err := b.installedSet()
	if err != nil {
		return names
	}
	var out []string
	for _, n := range names {
		if !inst.formulae[n] {
			out = append(out, n)
		}
	}
	return out
}

// MissingCasks returns configured casks that are not installed.
func (b *Brew) MissingCasks(names []string) []string {
	inst, err := b.installedSet()
	if err != nil {
		return names
	}
	var out []string
	for _, n := range names {
		if !inst.casks[n] {
			out = append(out, n)
		}
	}
	return out
}

// BundleDump writes a Brewfile for the current installation to the given
// directory and returns its path.
func (b *Brew) BundleDump(ctx *module.Context, dir string) (string, error) {
	path := strings.TrimSuffix(dir, "/") + "/Brewfile"
	if ctx.DryRun {
		ctx.Log.Stepf("[dry-run] brew bundle dump --file=%s", path)
		return path, nil
	}
	if err := b.Runner.Run(b.Path(), "bundle", "dump", "--file="+path, "--force"); err != nil {
		return "", err
	}
	return path, nil
}

// BundleInstall restores a Brewfile.
func (b *Brew) BundleInstall(ctx *module.Context, file string) error {
	return b.Runner.Run(b.Path(), "bundle", "install", "--file="+file)
}

func (b *Brew) installedSet() (*installed, error) {
	if b.cache != nil {
		return b.cache, nil
	}
	inst := &installed{formulae: map[string]bool{}, casks: map[string]bool{}}

	// `brew list --json` changed shape across Homebrew versions and requires
	// jq; plain `--formula`/`--cask` output (one name per line) is stable and
	// dependency-free, so we parse that instead.
	out, err := b.Runner.Output(b.Path(), "list", "--formula")
	if err != nil {
		return nil, fmt.Errorf("brew list --formula: %w", err)
	}
	for _, name := range strings.Fields(out) {
		inst.formulae[name] = true
	}
	if out, err := b.Runner.Output(b.Path(), "list", "--cask"); err == nil {
		for _, name := range strings.Fields(out) {
			inst.casks[name] = true
		}
	}
	b.cache = inst
	return inst, nil
}

func (b *Brew) refresh() { b.cache = nil }

// Formulae returns the sorted installed formulae names.
func (b *Brew) Formulae() []string {
	inst, err := b.installedSet()
	if err != nil {
		return nil
	}
	out := make([]string, 0, len(inst.formulae))
	for n := range inst.formulae {
		out = append(out, n)
	}
	sort.Strings(out)
	return out
}
