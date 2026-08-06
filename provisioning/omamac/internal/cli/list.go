package cli

import (
	"fmt"
	"os"
	"text/tabwriter"

	"github.com/spf13/cobra"
)

func newListCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:     "list",
		Aliases: []string{"ls", "modules"},
		Short:   "List available modules and their enabled state",
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			mods, err := app.Registry.Filter(app.Config, nil, nil)
			if err != nil {
				return err
			}
			enabled := map[string]bool{}
			for _, m := range mods {
				enabled[m.Name()] = true
			}

			type row struct {
				Name    string `json:"name"`
				Summary string `json:"summary"`
				Enabled bool   `json:"enabled"`
			}
			var rows []row
			for _, m := range app.Registry.All() {
				rows = append(rows, row{m.Name(), m.Summary(), enabled[m.Name()]})
			}

			if r.opts.JSON {
				r.emitJSON(map[string]any{
					"modules": rows,
					"config":  map[string]bool{"loaded": app.Config != nil},
				})
				return nil
			}

			w := tabwriter.NewWriter(os.Stdout, 0, 4, 2, ' ', 0)
			fmt.Fprintln(w, "NAME\tENABLED\tSUMMARY")
			for _, row := range rows {
				mark := "no "
				if row.Enabled {
					mark = "yes"
				}
				fmt.Fprintf(w, "%s\t%s\t%s\n", row.Name, mark, row.Summary)
			}
			w.Flush()
			return nil
		},
	}
}
