package cli

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/irfancode/omamac/internal/config"
	"github.com/spf13/cobra"
)

func newConfigCmd(r *rootCmd) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "config",
		Short: "Inspect and initialize omamac configuration",
	}
	cmd.AddCommand(
		configShowCmd(r),
		configPathCmd(r),
		configInitCmd(r),
	)
	return cmd
}

func configShowCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "show",
		Short: "Print the resolved configuration",
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()
			if r.opts.JSON {
				r.emitJSON(app.Config)
				return nil
			}
			out, err := app.Config.Dump()
			if err != nil {
				return err
			}
			fmt.Fprint(os.Stdout, string(out))
			return nil
		},
	}
}

func configPathCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "path",
		Short: "Print omamac runtime paths",
		RunE: func(cmd *cobra.Command, args []string) error {
			paths := map[string]string{
				"config_dir":  config.ConfigDir(),
				"config_file": config.DefaultConfigPath(),
				"data_dir":    config.DataDir(),
				"state_dir":   config.StateDir(),
			}
			if r.opts.JSON {
				r.emitJSON(paths)
				return nil
			}
			for k, v := range paths {
				fmt.Fprintf(os.Stdout, "%-14s %s\n", k+":", v)
			}
			return nil
		},
	}
}

func configInitCmd(r *rootCmd) *cobra.Command {
	var force bool
	cmd := &cobra.Command{
		Use:   "init",
		Short: "Write the default configuration to disk",
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			path := config.DefaultConfigPath()
			if _, err := os.Stat(path); err == nil && !force {
				return fmt.Errorf("%s already exists (use --force to overwrite)", path)
			}
			if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
				return err
			}
			// Write pristine defaults, not the merged config: `init` should
			// regenerate a clean starting point even when a stale config file
			// already exists.
			fresh, err := config.Load()
			if err != nil {
				return err
			}
			out, err := fresh.Dump()
			if err != nil {
				return err
			}
			if r.opts.DryRun {
				app.Log.Stepf("[dry-run] would write %s", path)
				return nil
			}
			if err := os.WriteFile(path, out, 0o644); err != nil {
				return err
			}
			app.Log.Successf("wrote %s", path)
			return nil
		},
	}
	cmd.Flags().BoolVar(&force, "force", false, "overwrite an existing config")
	return cmd
}
