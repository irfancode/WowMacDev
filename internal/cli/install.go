package cli

import (
	"errors"

	"github.com/omamac/omamac/internal/module"
	"github.com/spf13/cobra"
)

func newInstallCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "install",
		Short: "Install and configure the full development environment",
		Long: `Runs every enabled module in dependency order: Homebrew first, then the
configured tools, applications and preferences. Idempotent: already-provisioned
steps are skipped. Use --dry-run to preview, --module to target a subset and
--json for machine-readable output.`,
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			if app.Config.Version > 0 {
				app.Log.Section("omamac install")
			}
			results := app.runModules(module.ActionInstall, true)

			summary := summarize(results)
			r.emitJSON(map[string]any{
				"command": "install",
				"dry_run": r.opts.DryRun,
				"modules": results,
				"summary": summary,
			})

			if summary.Failed > 0 {
				if !r.opts.Yes {
					return errors.New("install completed with failures (see log above)")
				}
				return errors.New("install completed with failures")
			}
			if !r.opts.JSON && summary.Total > 0 {
				app.Log.Successf("all %d modules finished", summary.Total)
			}
			return nil
		},
	}
}

func newUpdateCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "update",
		Short: "Update packages, applications and module configuration",
		Long: `Updates Homebrew, upgrades formulae and casks, refreshes dotfiles and runs
each module's Update hook. Use --dry-run to preview what would change.`,
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			results := app.runModules(module.ActionUpdate, true)
			summary := summarize(results)
			r.emitJSON(map[string]any{"command": "update", "dry_run": r.opts.DryRun, "modules": results, "summary": summary})
			if summary.Failed > 0 {
				return errors.New("update completed with failures")
			}
			if !r.opts.JSON {
				app.Log.Success("update finished")
			}
			return nil
		},
	}
}

// summarize tallies module results.
type summary struct {
	Total  int `json:"total"`
	OK     int `json:"ok"`
	Failed int `json:"failed"`
	DryRun int `json:"dry_run"`
}

func summarize(results []moduleResult) summary {
	s := summary{}
	for _, res := range results {
		s.Total++
		switch res.Status {
		case "ok":
			s.OK++
		case "failed":
			s.Failed++
		case "dry-run":
			s.DryRun++
		}
	}
	return s
}
