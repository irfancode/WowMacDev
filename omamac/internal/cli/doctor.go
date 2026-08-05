package cli

import (
	"errors"

	"github.com/irfancode/omamac/internal/module"
	"github.com/spf13/cobra"
)

func newVerifyCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "verify",
		Short: "Verify each module is correctly installed",
		Long:  "Runs each enabled module's Verify hook and reports pass/fail. Never mutates anything.",
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			// Verify must not mutate state; force a non-dry-run safe runner.
			results := app.runModules(module.ActionVerify, false)
			summary := summarize(results)
			r.emitJSON(map[string]any{"command": "verify", "modules": results, "summary": summary})

			if summary.Failed > 0 {
				if !r.opts.JSON {
					app.Log.Failf("verify: %d/%d checks failed", summary.Failed, summary.Total)
				}
				return errors.New("verify found failures")
			}
			if !r.opts.JSON {
				app.Log.Successf("verify: all %d checks passed", summary.Total)
			}
			return nil
		},
	}
}

func newDoctorCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "doctor",
		Short: "Run system health checks for the omamac environment",
		Long: `Checks platform prerequisites, Xcode CLT, Homebrew, PATH, permissions and
network, then runs module verification. Exits non-zero when problems are found.`,
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			checks := runSystemChecks(app)
			results := app.runModules(module.ActionVerify, false)
			moduleFails := summarize(results).Failed

			r.emitJSON(map[string]any{
				"command":       "doctor",
				"system":        checks,
				"module_checks": results,
			})

			allPass := true
			for _, c := range checks {
				if c.Status != "ok" {
					allPass = false
				}
			}
			if !r.opts.JSON {
				app.Log.Section("doctor")
				for _, c := range checks {
					if c.Status == "ok" {
						app.Log.Successf("%s: %s", c.Name, c.Detail)
					} else {
						app.Log.Failf("%s: %s (%s)", c.Name, c.Detail, c.Status)
					}
				}
			}
			if !allPass || moduleFails > 0 {
				return errors.New("doctor found problems")
			}
			if !r.opts.JSON {
				app.Log.Success("doctor: all checks passed")
			}
			return nil
		},
	}
}

type checkResult struct {
	Name   string `json:"name"`
	Status string `json:"status"`
	Detail string `json:"detail,omitempty"`
}

// runSystemChecks performs platform-level health checks independent of modules.
func runSystemChecks(app *App) []checkResult {
	var out []checkResult

	out = append(out, platformCheck())
	out = append(out, cltCheck())
	out = append(out, brewCheck(app))
	out = append(out, pathCheck())
	out = append(out, permsCheck())
	out = append(out, networkCheck(app))
	return out
}
