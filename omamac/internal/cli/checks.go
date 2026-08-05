package cli

import (
	"net"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/irfancode/omamac/internal/config"
	"github.com/irfancode/omamac/internal/util"
)

func platformCheck() checkResult {
	if util.IsDarwin() {
		return checkResult{Name: "platform", Status: "ok", Detail: "macOS " + util.DarwinVersion() + " (" + archName() + ")"}
	}
	return checkResult{Name: "platform", Status: "fail", Detail: "omamac requires macOS"}
}

func archName() string {
	if util.AppleSilicon() {
		return "arm64"
	}
	return "x86_64"
}

func cltCheck() checkResult {
	if util.XcodeCLTInstalled() {
		return checkResult{Name: "xcode-clt", Status: "ok", Detail: "command line tools present"}
	}
	return checkResult{Name: "xcode-clt", Status: "warn", Detail: "missing; run `xcode-select --install` or the omamac bootstrap"}
}

func brewCheck(app *App) checkResult {
	if app.Options.DryRun {
		return checkResult{Name: "homebrew", Status: "ok", Detail: "skipped (dry-run)"}
	}
	if util.CommandExists("brew") {
		return checkResult{Name: "homebrew", Status: "ok", Detail: util.HomebrewBin()}
	}
	return checkResult{Name: "homebrew", Status: "fail", Detail: "not installed; bootstrap will install it"}
}

func pathCheck() checkResult {
	path := os.Getenv("PATH")
	for _, dir := range []string{util.HomebrewBinDir(), "/usr/local/bin"} {
		for _, p := range strings.Split(path, ":") {
			if strings.EqualFold(p, dir) {
				return checkResult{Name: "path", Status: "ok", Detail: dir + " on PATH"}
			}
		}
	}
	return checkResult{Name: "path", Status: "warn", Detail: "Homebrew bin not on PATH"}
}

func permsCheck() checkResult {
	dirs := []string{config.ConfigDir(), config.DataDir()}
	for _, d := range dirs {
		if err := os.MkdirAll(d, 0o755); err != nil {
			return checkResult{Name: "permissions", Status: "fail", Detail: d + ": " + err.Error()}
		}
		if !isWritable(d) {
			return checkResult{Name: "permissions", Status: "fail", Detail: d + " not writable"}
		}
	}
	return checkResult{Name: "permissions", Status: "ok", Detail: "config and data dirs writable"}
}

func isWritable(dir string) bool {
	f := filepath.Join(dir, ".omamac-write-test")
	_ = os.WriteFile(f, []byte("x"), 0o600)
	if err := os.Remove(f); err != nil {
		return false
	}
	return true
}

func networkCheck(app *App) checkResult {
	if app.Options.DryRun {
		return checkResult{Name: "network", Status: "ok", Detail: "skipped (dry-run)"}
	}
	conn, err := net.DialTimeout("tcp", "github.com:443", 3*time.Second)
	if err != nil {
		return checkResult{Name: "network", Status: "warn", Detail: "cannot reach github.com"}
	}
	_ = conn.Close()
	return checkResult{Name: "network", Status: "ok", Detail: "github.com reachable"}
}
