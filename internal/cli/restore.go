package cli

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/omamac/omamac/internal/util"
	"github.com/spf13/cobra"
)

func newRestoreCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "restore <backup-dir>",
		Short: "Restore a previously created backup",
		Long: `Restores a backup directory created by ` + "`omamac backup`" + `. If the backup
contains a generated restore.sh it is executed; otherwise brew bundle and
defaults are restored directly from the backup contents.`,
		Args: cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			dir, err := filepath.Abs(args[0])
			if err != nil {
				return err
			}
			info, err := os.Stat(dir)
			if err != nil {
				return fmt.Errorf("backup %q: %w", dir, err)
			}
			if !info.IsDir() {
				return fmt.Errorf("backup %q is not a directory", dir)
			}

			ctx := app.ctx()
			restoreScript := filepath.Join(dir, "restore.sh")
			if _, err := os.Stat(restoreScript); err == nil && !r.opts.DryRun {
				if !util.CommandExists("bash") {
					return fmt.Errorf("bash not found")
				}
				app.Log.Infof("running restore.sh from %s", dir)
				if err := ctx.Runner.RunIn(dir, "/bin/bash", "restore.sh"); err != nil {
					return fmt.Errorf("restore.sh failed: %w", err)
				}
				r.emitJSON(map[string]any{"command": "restore", "path": dir, "method": "restore.sh"})
				if !r.opts.JSON {
					app.Log.Successf("restored from %s", dir)
				}
				return nil
			}

			// Fallback: restore pieces directly.
			steps := []struct {
				label string
				fn    func() error
			}{
				{"brew bundle install", func() error {
					bf := filepath.Join(dir, "Brewfile")
					if _, err := os.Stat(bf); err != nil {
						return nil
					}
					return ctx.Runner.Run("brew", "bundle", "install", "--file="+bf)
				}},
				{"restore defaults", func() error {
					entries, _ := os.ReadDir(filepath.Join(dir, "defaults"))
					for _, e := range entries {
						if strings.HasSuffix(e.Name(), ".plist") {
							domain := strings.TrimSuffix(e.Name(), ".plist")
							if err := ctx.Runner.Run("defaults", "import", domain, filepath.Join(dir, "defaults", e.Name())); err != nil {
								return err
							}
						}
					}
					return nil
				}},
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
			r.emitJSON(map[string]any{"command": "restore", "path": dir, "method": "direct", "dry_run": r.opts.DryRun})
			if !r.opts.JSON {
				app.Log.Successf("restored from %s", dir)
			}
			return nil
		},
	}
}
