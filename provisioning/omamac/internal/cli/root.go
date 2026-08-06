package cli

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/spf13/cobra"
)

// Execute runs the CLI and returns a process exit code.
func Execute() int {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	root := newRootCmd(version)
	if err := root.ExecuteContext(ctx); err != nil {
		// Errors returned from commands are printed here exactly once;
		// commands keep logs on stderr via the logger.
		fmt.Fprintf(os.Stderr, "omamac: %s\n", err)
		return 1
	}
	return 0
}

type rootCmd struct {
	*cobra.Command
	version string
	opts    *globalOptions
}

func newRootCmd(version string) *rootCmd {
	opts := &globalOptions{}
	r := &rootCmd{version: version, opts: opts}

	cmd := &cobra.Command{
		Use:           "omamac",
		Short:         "Opinionated macOS developer workstation bootstrapper",
		Long:          "omamac transforms a fresh macOS install into a fully configured\n" + `developer workstation. Inspired by Omakub, built for Apple Silicon.`,
		SilenceUsage:  true,
		SilenceErrors: true,
		RunE: func(cmd *cobra.Command, _ []string) error {
			return cmd.Help()
		},
	}
	r.Command = cmd

	pf := cmd.PersistentFlags()
	pf.BoolVarP(&opts.Verbose, "verbose", "v", false, "verbose output")
	pf.BoolVar(&opts.Debug, "debug", false, "debug output")
	pf.BoolVar(&opts.JSON, "json", false, "machine-readable JSON output")
	pf.BoolVar(&opts.DryRun, "dry-run", false, "print actions without executing")
	pf.BoolVarP(&opts.Yes, "yes", "y", false, "assume yes for prompts")
	pf.StringVar(&opts.ConfigPath, "config", "", "path to an additional config file")
	pf.StringVar(&opts.Color, "color", "auto", "color output: auto|always|never")
	pf.StringArrayVar(&opts.Modules, "module", nil, "only run this module (repeatable)")
	pf.StringArrayVar(&opts.Exclude, "exclude", nil, "skip this module (repeatable)")
	pf.StringVar(&opts.LogFile, "log-file", "", "append a copy of all logs to this file")

	cmd.AddCommand(
		newInstallCmd(r),
		newUpdateCmd(r),
		newDoctorCmd(r),
		newVerifyCmd(r),
		newBackupCmd(r),
		newRestoreCmd(r),
		newConfigCmd(r),
		newPluginsCmd(r),
		newUninstallCmd(r),
		newModuleCmd(r),
		newListCmd(r),
		newVersionCmd(r),
	)
	return r
}

// getApp builds the runtime App for the invocation. It is cached on the root
// command so subcommands share one instance.
func (r *rootCmd) getApp() (*App, error) {
	return buildApp(r.opts, r.version)
}

// emitJSON writes structured results when --json is active, else logs a
// human summary. Fields is a map/struct; order is preserved for maps.
func (r *rootCmd) emitJSON(v any) {
	if !r.opts.JSON {
		return
	}
	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")
	_ = enc.Encode(v)
}
