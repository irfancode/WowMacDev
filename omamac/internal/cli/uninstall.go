package cli

import (
	"errors"
	"sort"

	"github.com/irfancode/omamac/internal/module"
	"github.com/irfancode/omamac/internal/state"
	"github.com/spf13/cobra"
)

func newUninstallCmd(r *rootCmd) *cobra.Command {
	var purge bool
	cmd := &cobra.Command{
		Use:   "uninstall",
		Short: "Roll back everything omamac installed",
		Long: `Walks the journal in reverse and invokes each module's Remove hook, so
applications, packages and settings that omamac installed can be selectively
undone. Use --purge to also clear omamac state and journals.

Requires --yes or an interactive confirmation.`,
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			if !r.opts.Yes {
				return errors.New("uninstall is destructive; re-run with --yes")
			}

			// Distinct modules that recorded a successful install.
			seen := map[string]bool{}
			var names []string
			for _, e := range app.State.All() {
				if e.Action == state.ActionInstall && e.Status == state.StatusOK && !seen[e.Module] {
					seen[e.Module] = true
					names = append(names, e.Module)
				}
			}
			sort.Strings(names)
			if len(names) == 0 {
				app.Log.Info("nothing to roll back")
			}

			var results []moduleResult
			for _, name := range names {
				m, err := app.Registry.Get(name)
				if err != nil {
					app.Log.Warnf("module %q no longer available; skipping", name)
					continue
				}
				res := app.execModule(app.ctx(), m, module.ActionRemove)
				results = append(results, res)
			}

			if purge && !r.opts.DryRun {
				if err := app.State.Reset(); err != nil {
					app.Log.Warnf("could not clear journal: %v", err)
				} else {
					app.Log.Info("journal cleared")
				}
			}

			summary := summarize(results)
			r.emitJSON(map[string]any{"command": "uninstall", "dry_run": r.opts.DryRun, "modules": results, "summary": summary})
			if summary.Failed > 0 {
				return errors.New("uninstall completed with failures")
			}
			if !r.opts.JSON {
				app.Log.Success("rollback finished")
			}
			return nil
		},
	}
	cmd.Flags().BoolVar(&purge, "purge", false, "clear omamac state and journals after rollback")
	return cmd
}
