package cli

import (
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"text/tabwriter"

	"github.com/omamac/omamac/internal/module"
	"github.com/spf13/cobra"
)

const disabledMarker = ".disabled"

func newPluginsCmd(r *rootCmd) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "plugins",
		Short: "Manage third-party omamac plugins",
		Long: `Plugins extend omamac with additional install/update/remove/verify
capabilities. Each plugin lives in <config>/plugins/<group>/<name>/ with a
plugin.yaml manifest and shell scripts.`,
	}
	cmd.AddCommand(
		newPluginListCmd(r),
		newPluginAddCmd(r),
		newPluginRemoveCmd(r),
		newPluginEnableCmd(r, true),
		newPluginEnableCmd(r, false),
	)
	return cmd
}

func pluginRoot(app *App) string { return filepath.Join(app.ConfigDir, "plugins") }

func newPluginListCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "list",
		Short: "List installed plugins",
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			plugins, err := module.LoadPlugins(pluginRoot(app))
			if err != nil {
				return err
			}
			type row struct {
				Name    string   `json:"name"`
				Title   string   `json:"title"`
				Group   string   `json:"group"`
				Enabled bool     `json:"enabled"`
				Depends []string `json:"depends_on,omitempty"`
			}
			rows := []row{}
			_ = filepath.Walk(pluginRoot(app), func(path string, info os.FileInfo, err error) error {
				if err != nil || info == nil || !info.IsDir() {
					return nil
				}
				marker := filepath.Join(path, disabledMarker)
				if _, err := os.Stat(filepath.Join(path, "plugin.yaml")); err != nil {
					return nil
				}
				base := filepath.Base(path)
				group := filepath.Base(filepath.Dir(path))
				enabled := true
				if _, err := os.Stat(marker); err == nil {
					enabled = false
				}
				rows = append(rows, row{Name: base, Group: group, Enabled: enabled})
				return nil
			})

			if r.opts.JSON {
				r.emitJSON(map[string]any{"plugins": rows})
				return nil
			}
			w := tabwriter.NewWriter(os.Stdout, 0, 4, 2, ' ', 0)
			fmt.Fprintln(w, "NAME\tGROUP\tENABLED")
			for _, p := range rows {
				fmt.Fprintf(w, "%s\t%s\t%v\n", p.Name, p.Group, p.Enabled)
			}
			w.Flush()
			if len(plugins) == 0 && len(rows) == 0 {
				fmt.Fprintln(os.Stdout, "no plugins installed")
			}
			return nil
		},
	}
}

func newPluginAddCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "add <dir|git-url> [group]",
		Short: "Install a plugin from a local directory or git URL",
		Args:  cobra.RangeArgs(1, 2),
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()

			src := args[0]
			group := "community"
			if len(args) > 1 {
				group = args[1]
			}
			if !validGroup(group) {
				return fmt.Errorf("invalid group name %q", group)
			}

			root := pluginRoot(app)
			tmp := filepath.Join(os.TempDir(), "omamac-plugin-"+group)
			_ = os.RemoveAll(tmp)
			defer os.RemoveAll(tmp)

			if isGitURL(src) {
				app.Log.Infof("cloning plugin: %s", src)
				clone := exec.Command("git", "clone", "--depth=1", src, tmp)
				clone.Stdout = app.Log.Writer(1)
				clone.Stderr = app.Log.Writer(1)
				if r.opts.DryRun {
					app.Log.Stepf("[dry-run] git clone %s", src)
				} else {
					if err := clone.Run(); err != nil {
						return fmt.Errorf("clone failed: %w", err)
					}
				}
			} else {
				info, err := os.Stat(src)
				if err != nil {
					return fmt.Errorf("plugin source %q: %w", src, err)
				}
				if !info.IsDir() {
					return fmt.Errorf("plugin source %q is not a directory", src)
				}
				if err := copyDir(src, tmp); err != nil {
					return err
				}
			}

			// Locate the plugin directory inside the staging area: git clones
			// produce <tmp>/plugin.yaml, while copied directories produce
			// <tmp>/<name>/plugin.yaml.
			pluginDir := tmp
			if _, err := os.Stat(filepath.Join(tmp, "plugin.yaml")); err != nil {
				entries, rerr := os.ReadDir(tmp)
				if rerr != nil {
					return rerr
				}
				pluginDir = ""
				for _, e := range entries {
					if e.IsDir() {
						if _, serr := os.Stat(filepath.Join(tmp, e.Name(), "plugin.yaml")); serr == nil {
							pluginDir = filepath.Join(tmp, e.Name())
							break
						}
					}
				}
				if pluginDir == "" {
					return fmt.Errorf("no valid plugin.yaml found in %s", src)
				}
			}

			// Validate the plugin manifest without scanning unrelated dirs.
			p, err := module.LoadPluginDir(pluginDir)
			if err != nil {
				return err
			}
			name := p.Name
			dest := filepath.Join(root, group, name)
			if _, err := os.Stat(filepath.Join(dest, "plugin.yaml")); err == nil && !r.opts.Yes {
				return fmt.Errorf("%s already installed (use --yes to overwrite)", name)
			}
			if r.opts.DryRun {
				app.Log.Stepf("[dry-run] install plugin %s -> %s", name, dest)
				return nil
			}
			if err := copyDir(tmp, dest); err != nil {
				return err
			}
			app.Log.Successf("installed plugin %s", name)
			return nil
		},
	}
}

func newPluginRemoveCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "remove <name>",
		Short: "Remove an installed plugin",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()
			name := args[0]

			found := ""
			_ = filepath.Walk(pluginRoot(app), func(path string, info os.FileInfo, err error) error {
				if err != nil || info == nil || !info.IsDir() {
					return nil
				}
				if info.IsDir() && filepath.Base(path) == name {
					if _, err := os.Stat(filepath.Join(path, "plugin.yaml")); err == nil {
						found = path
					}
				}
				return nil
			})
			if found == "" {
				return fmt.Errorf("plugin %q not found", name)
			}
			if r.opts.DryRun {
				app.Log.Stepf("[dry-run] remove plugin %s", name)
				return nil
			}
			if err := os.RemoveAll(found); err != nil {
				return err
			}
			app.Log.Successf("removed plugin %s", name)
			return nil
		},
	}
}

func newPluginEnableCmd(r *rootCmd, enable bool) *cobra.Command {
	verb := "disable"
	short := "Disable a plugin (removed from the run set)"
	marker := disabledMarker
	create := true
	if enable {
		verb = "enable"
		short = "Enable a plugin"
		marker = disabledMarker
		create = false
	}
	cmd := &cobra.Command{
		Use:   verb + " <name>",
		Short: short,
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			app, err := r.getApp()
			if err != nil {
				return err
			}
			defer app.close()
			name := args[0]

			dir := ""
			_ = filepath.Walk(pluginRoot(app), func(path string, info os.FileInfo, err error) error {
				if err != nil || info == nil || !info.IsDir() {
					return nil
				}
				if info.IsDir() && filepath.Base(path) == name {
					if _, err := os.Stat(filepath.Join(path, "plugin.yaml")); err == nil {
						dir = path
					}
				}
				return nil
			})
			if dir == "" {
				return fmt.Errorf("plugin %q not found", name)
			}
			markerPath := filepath.Join(dir, marker)
			if r.opts.DryRun {
				app.Log.Stepf("[dry-run] %s plugin %s", verb, name)
				return nil
			}
			if create {
				if err := os.WriteFile(markerPath, []byte("disabled\n"), 0o644); err != nil {
					return err
				}
			} else if err := os.Remove(markerPath); err != nil && !os.IsNotExist(err) {
				return err
			}
			app.Log.Successf("%sd plugin %s", verb, name)
			return nil
		},
	}
	return cmd
}

func validGroup(s string) bool {
	if s == "" {
		return false
	}
	for _, r := range s {
		if !(r >= 'a' && r <= 'z' || r >= '0' && r <= '9' || r == '-' || r == '_') {
			return false
		}
	}
	return true
}

func isGitURL(s string) bool {
	return strings.HasPrefix(s, "https://") || strings.HasPrefix(s, "git@") || strings.HasSuffix(s, ".git")
}

func copyDir(src, dst string) error {
	info, err := os.Stat(src)
	if err != nil {
		return err
	}
	if err := os.MkdirAll(dst, info.Mode().Perm()); err != nil {
		return err
	}
	entries, err := os.ReadDir(src)
	if err != nil {
		return err
	}
	for _, e := range entries {
		s := filepath.Join(src, e.Name())
		d := filepath.Join(dst, e.Name())
		if e.IsDir() {
			if err := copyDir(s, d); err != nil {
				return err
			}
			continue
		}
		if err := copyFile(s, d); err != nil {
			return err
		}
	}
	return nil
}

func copyFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	if _, err := io.Copy(out, in); err != nil {
		out.Close()
		return err
	}
	return out.Close()
}
