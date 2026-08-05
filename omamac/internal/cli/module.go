package cli

import (
	"fmt"

	"github.com/irfancode/omamac/internal/module"
	"github.com/spf13/cobra"
)

func newModuleCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "module <name> <action>",
		Short: "Run a single module action",
		Long:  "Run a single module action. Actions: install, update, remove, verify.",
		Args:  cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) error {
			name, action := args[0], args[1]
			var act module.Action
			switch action {
			case "install", "update", "remove", "verify":
				act = module.Action(action)
			default:
				return fmt.Errorf("unknown action %q (use install, update, remove or verify)", action)
			}

			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			m, err := app.Registry.Get(name)
			if err != nil {
				return err
			}
			if !m.Enabled(app.Config) {
				app.Log.Warnf("module %q is disabled in config", name)
			}

			ctx := app.ctx()
			res := app.execModule(ctx, m, act)
			if !r.opts.JSON {
				app.Log.Raw("%s", fmtStatusLine(res))
			}
			r.emitJSON(res)
			if res.Status == "failed" {
				return fmt.Errorf("%s %s failed: %s", name, action, res.Error)
			}
			return nil
		},
	}
}

func fmtStatusLine(res moduleResult) string {
	switch res.Status {
	case "ok":
		return fmt.Sprintf("%-8s %s", "✓", res.Module+" "+res.Action)
	case "dry-run":
		return fmt.Sprintf("%-8s %s", "preview", res.Module+" "+res.Action)
	default:
		return fmt.Sprintf("%-8s %s: %s", "✗", res.Module+" "+res.Action, res.Error)
	}
}
