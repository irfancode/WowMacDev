package cli

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/irfancode/omamac/internal/module"
	"github.com/irfancode/omamac/internal/util"
	"github.com/spf13/cobra"
)

// backupDomains are preference domains snapshotted for reversible restore.
var backupDomains = []string{
	"NSGlobalDomain",
	"com.apple.finder",
	"com.apple.dock",
	"com.apple.Terminal",
	"com.apple.screensaver",
	"com.apple.controlcenter",
}

func newBackupCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "backup [name]",
		Short: "Export the current environment to a restorable backup",
		Long: `Exports the installed brew formulae/casks (Brewfile), configured
preferences (defaults plists), VS Code settings and the omamac config into a
dated directory, along with a generated restore.sh.`,
		Args: cobra.MaximumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			name := time.Now().Format("2006-01-02T150405")
			if len(args) == 1 {
				name = args[0]
			}
			backupDir := filepath.Join(app.DataDir, "backups", name)

			ctx := app.ctx()
			steps := []struct {
				label string
				fn    func() error
			}{
				{"brew bundle dump", func() error { return app.brewBundleDump(ctx, backupDir) }},
				{"copy omamac config", func() error {
					return copyIfExists(filepath.Join(app.ConfigDir, "config.yaml"), filepath.Join(backupDir, "config.yaml"))
				}},
				{"export defaults", func() error { return exportDefaults(ctx, backupDir) }},
				{"copy vscode settings", func() error { return copyVSCODE(backupDir) }},
				{"write restore script", func() error { return writeRestoreScript(backupDir) }},
				{"write summary", func() error { return writeBackupSummary(backupDir, name, app.Version) }},
			}
			if r.opts.DryRun {
				for _, s := range steps {
					app.Log.Stepf("[dry-run] %s", s.label)
				}
				r.emitJSON(map[string]any{"command": "backup", "path": backupDir, "dry_run": true})
				if !r.opts.JSON {
					app.Log.Successf("backup would be written to %s", backupDir)
				}
				return nil
			}

			if err := os.MkdirAll(filepath.Join(backupDir, "defaults"), 0o755); err != nil {
				return err
			}
			if err := os.MkdirAll(filepath.Join(backupDir, "vscode"), 0o755); err != nil {
				return err
			}

			if ctx.Progress != nil {
				ctx.Progress.Start(len(steps))
			}
			for _, s := range steps {
				if ctx.Progress != nil {
					ctx.Progress.Step(s.label)
				} else {
					app.Log.Step(s.label)
				}
				if err := s.fn(); err != nil {
					return err
				}
			}
			if ctx.Progress != nil {
				ctx.Progress.Finish("backup", true)
			}
			r.emitJSON(map[string]any{"command": "backup", "path": backupDir, "dry_run": r.opts.DryRun})
			if !r.opts.JSON {
				app.Log.Successf("backup written to %s", backupDir)
			}
			return nil
		},
	}
}

func (a *App) brewBundleDump(ctx *module.Context, dir string) error {
	if !util.CommandExists("brew") {
		a.Log.Warn("brew not installed; skipping Brewfile export")
		return nil
	}
	return ctx.Runner.Run("brew", "bundle", "dump", "--file="+filepath.Join(dir, "Brewfile"), "--force")
}

// exportDefaults snapshots each preference domain as a plist. Domains that do
// not exist are skipped.
func exportDefaults(ctx *module.Context, dir string) error {
	for _, domain := range backupDomains {
		target := filepath.Join(dir, "defaults", domain+".plist")
		err := ctx.Runner.Run("defaults", "export", domain, target)
		if err != nil {
			if strings.Contains(err.Error(), "does not exist") || strings.Contains(err.Error(), "No such") {
				ctx.Log.Debugf("skipping missing domain: %s", domain)
				continue
			}
			return err
		}
	}
	return nil
}

// copyVSCODE snapshots VS Code user settings and keybindings.
func copyVSCODE(backupDir string) error {
	home, _ := os.UserHomeDir()
	userDir := filepath.Join(home, "Library", "Application Support", "Code", "User")
	for _, f := range []string{"settings.json", "keybindings.json"} {
		if err := copyIfExists(filepath.Join(userDir, f), filepath.Join(backupDir, "vscode", f)); err != nil {
			return err
		}
	}
	return nil
}

func copyIfExists(src, dst string) error {
	if _, err := os.Stat(src); err != nil {
		return nil
	}
	data, err := os.ReadFile(src)
	if err != nil {
		return err
	}
	return os.WriteFile(dst, data, 0o644)
}

// writeRestoreScript generates a shell script that replays the backup.
func writeRestoreScript(dir string) error {
	script := `#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
if command -v brew >/dev/null 2>&1 && [ -f Brewfile ]; then
  echo "Restoring brew packages..."
  brew bundle install --file=Brewfile
fi
if [ -d defaults ]; then
  for f in defaults/*.plist; do
    domain=$(basename "$f" .plist)
    echo "Restoring $domain..."
    defaults import "$domain" "$f"
  done
fi
if [ -f config.yaml ]; then
  mkdir -p "${OMAMAC_CONFIG_DIR:-$HOME/.config/omamac}"
  cp config.yaml "${OMAMAC_CONFIG_DIR:-$HOME/.config/omamac}/config.yaml"
fi
if [ -f vscode/settings.json ]; then
  VSUSER="$HOME/Library/Application Support/Code/User"
  mkdir -p "$VSUSER"
  cp vscode/settings.json "$VSUSER/settings.json"
  [ -f vscode/keybindings.json ] && cp vscode/keybindings.json "$VSUSER/keybindings.json"
fi
echo "Restore complete."
`
	return os.WriteFile(filepath.Join(dir, "restore.sh"), []byte(script), 0o755)
}

func writeBackupSummary(dir, name, version string) error {
	summary := map[string]any{
		"name":      name,
		"omamac":    version,
		"created":   time.Now().Format(time.RFC3339),
		"platform":  "darwin",
		"contained": []string{"Brewfile", "config.yaml", "defaults/", "vscode/", "restore.sh"},
	}
	data, err := json.MarshalIndent(summary, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(filepath.Join(dir, "summary.json"), data, 0o644)
}
