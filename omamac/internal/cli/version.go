package cli

import (
	"fmt"
	"os"
	"runtime"

	"github.com/spf13/cobra"
)

type buildInfo struct {
	Version   string `json:"version"`
	GoOS      string `json:"goos"`
	GoArch    string `json:"goarch"`
	GoVersion string `json:"go_version"`
	Built     string `json:"built,omitempty"`
}

func newVersionCmd(r *rootCmd) *cobra.Command {
	return &cobra.Command{
		Use:   "version",
		Short: "Print version and build information",
		Args:  cobra.NoArgs,
		RunE: func(cmd *cobra.Command, args []string) error {
			info := buildInfo{
				Version:   version,
				GoOS:      runtime.GOOS,
				GoArch:    runtime.GOARCH,
				GoVersion: runtime.Version(),
			}
			if r.opts.JSON {
				r.emitJSON(info)
				return nil
			}
			fmt.Fprintf(os.Stdout, "omamac %s (%s/%s, %s)\n", info.Version, info.GoOS, info.GoArch, info.GoVersion)
			return nil
		},
	}
}
