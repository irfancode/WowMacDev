// Package macos wraps `defaults write/read` with type inference and value
// snapshotting so preference changes are reversible.
package macos

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/omamac/omamac/internal/module"
)

// Rule describes one `defaults` write.
type Rule struct {
	Domain string
	Key    string
	Value  any // bool | int | float64 | string
}

// Apply writes a rule to the defaults system. It returns the previous value
// (if readable) for rollback purposes.
func Apply(ctx *module.Context, r Rule) (prev string, err error) {
	prev, _ = ctx.Runner.Output("defaults", "read", r.Domain, r.Key)

	args := []string{"write", r.Domain, r.Key}
	switch v := r.Value.(type) {
	case bool:
		args = append(args, "-bool", strconv.FormatBool(v))
	case int:
		args = append(args, "-int", strconv.Itoa(v))
	case float64:
		args = append(args, "-float", strconv.FormatFloat(v, 'f', -1, 64))
	case string:
		args = append(args, "-string", v)
	default:
		return prev, fmt.Errorf("unsupported defaults value type %T for %s.%s", r.Value, r.Domain, r.Key)
	}
	if err := ctx.Runner.Run("defaults", args...); err != nil {
		return prev, err
	}
	return prev, nil
}

// Read returns the current value for a key, or "" if unset/unreadable.
func Read(ctx *module.Context, domain, key string) string {
	out, _ := ctx.Runner.Output("defaults", "read", domain, key)
	return strings.TrimSpace(out)
}

// RestartFrequent changes need the affected apps restarted; best-effort.
func RestartFrequent(ctx *module.Context, apps ...string) {
	for _, app := range apps {
		if err := ctx.Runner.Run("killall", app); err != nil {
			ctx.Log.Debugf("could not restart %s: %v", app, err)
		}
	}
}

// Domain helpers for the commonly configured preference domains.
const (
	NSGlobalDomain = "NSGlobalDomain"
	FinderDomain   = "com.apple.finder"
	DockDomain     = "com.apple.dock"
	TrackpadDomain = "com.apple.AppleMultitouchTrackpad"
	BluetoothTP    = "com.apple.driver.AppleBluetoothMultitouch.trackpad"
	ScreenDomain   = "com.apple.screencapture"
	LoginDomain    = "com.apple.loginwindow"
	SpacesDomain   = "com.apple.spaces"
	MenuBarDomain  = "com.apple.menuextra"
)
