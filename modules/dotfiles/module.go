// Package dotfilesmodule manages a dotfiles repository: it clones (or reuses a
// local checkout), then symlinks the listed files into $HOME.
package dotfilesmodule

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/irfancode/omamac/internal/config"
	"github.com/irfancode/omamac/internal/fsutil"
	"github.com/irfancode/omamac/internal/module"
	"github.com/irfancode/omamac/internal/state"
)

// Module manages dotfiles.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "dotfiles" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "Clone and symlink a dotfiles repository" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 40 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool {
	d := cfg.Dotfiles
	return d.Repo != "" || d.Local != ""
}

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	d := ctx.Config.Dotfiles
	dir, err := m.checkout(ctx, d)
	if err != nil {
		return err
	}

	links := d.Links
	if len(links) == 0 {
		links = []string{".zshrc", ".gitconfig", ".gitignore_global"}
	}
	linked := 0
	for _, name := range links {
		src := filepath.Join(dir, name)
		if _, err := os.Stat(src); err != nil {
			ctx.Log.Warnf("dotfiles: %s not found in repo", name)
			continue
		}
		dst := filepath.Join(ctx.HomeDir, name)
		ok, err := fsutil.Symlink(src, dst, ctx.DryRun)
		if err != nil {
			ctx.Log.Warnf("dotfiles symlink %s: %v", name, err)
			continue
		}
		if ok {
			linked++
		}
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusOK, Detail: fmt.Sprintf("%d links", linked)})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	d := ctx.Config.Dotfiles
	dir := d.Local
	if dir == "" {
		return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusSkipped, Detail: "no local dotfiles checkout"})
	}
	if !ctx.DryRun {
		if err := ctx.Runner.Run("git", "-C", dir, "pull", "--ff-only"); err != nil {
			ctx.Log.Warnf("dotfiles pull: %v", err)
		}
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusOK})
}

// Remove implements module.Module. Only symlinks that point into the managed
// dotfiles directory are removed; real files are left untouched.
func (m *Module) Remove(ctx *module.Context) error {
	d := ctx.Config.Dotfiles
	dir := d.Local
	if dir == "" && d.Repo != "" {
		dir = filepath.Join(config.DataDir(), "dotfiles", m.slug(d.Repo))
	}
	if dir == "" {
		return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusSkipped})
	}
	for _, name := range d.Links {
		dst := filepath.Join(ctx.HomeDir, name)
		if info, err := os.Lstat(dst); err == nil && info.Mode()&os.ModeSymlink != 0 {
			if target, err := os.Readlink(dst); err == nil && strings.HasPrefix(target, dir) {
				if ctx.DryRun {
					continue
				}
				_ = os.Remove(dst)
			}
		}
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(_ *module.Context) error {
	return nil
}

func (m *Module) checkout(ctx *module.Context, d config.DotfilesConfig) (string, error) {
	if d.Local != "" {
		if _, err := os.Stat(d.Local); err != nil {
			return "", fmt.Errorf("dotfiles local path %s: %w", d.Local, err)
		}
		return d.Local, nil
	}
	dir := filepath.Join(config.DataDir(), "dotfiles", m.slug(d.Repo))
	if _, err := os.Stat(filepath.Join(dir, ".git")); err != nil {
		if ctx.DryRun {
			ctx.Log.Stepf("[dry-run] git clone %s %s", d.Repo, dir)
			return dir, nil
		}
		if err := ctx.Runner.Run("git", "clone", d.Repo, dir); err != nil {
			return "", fmt.Errorf("dotfiles clone: %w", err)
		}
	}
	return dir, nil
}

func (m *Module) slug(repo string) string {
	s := strings.TrimSuffix(repo, ".git")
	s = strings.TrimPrefix(s, "git@github.com:")
	s = strings.TrimPrefix(s, "https://")
	s = strings.ReplaceAll(s, ":", "_")
	return strings.ReplaceAll(s, "/", "_")
}
