// Package util provides command execution, platform detection and small
// shared helpers used across omamac.
package util

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"sync"

	"github.com/irfancode/omamac/internal/logging"
)

// Runner executes external commands. It is dry-run aware: in dry-run mode no
// command is executed, only logged, which makes every operation safe to
// preview.
type Runner struct {
	DryRun bool
	Log    *logging.Logger
	Env    []string
}

// Run executes a command and streams output through the logger. It returns an
// error if the process exits non-zero, including combined output for context.
func (r *Runner) Run(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	return r.exec(cmd, "", "")
}

// RunIn executes a command in a working directory.
func (r *Runner) RunIn(dir, name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	return r.exec(cmd, "", "")
}

// RunWithStdin executes a command feeding stdin from a string.
func (r *Runner) RunWithStdin(name string, args []string, stdin string) error {
	cmd := exec.Command(name, args...)
	return r.exec(cmd, stdin, "")
}

// Script executes a bash snippet via `bash -c`.
func (r *Runner) Script(code string) error {
	return r.Run("/bin/bash", "-c", code)
}

// ScriptOut executes a bash snippet and returns captured combined output.
func (r *Runner) ScriptOut(code string) (string, error) {
	return r.Output("/bin/bash", "-c", code)
}

// Output runs a command and returns its trimmed combined output.
func (r *Runner) Output(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	cmd.Env = r.env()
	var buf strings.Builder
	cmd.Stdout = &buf
	cmd.Stderr = &buf
	if r.DryRun {
		r.Log.Stepf("[dry-run] %s %s", name, strings.Join(args, " "))
		return "", nil
	}
	err := cmd.Run()
	return strings.TrimSpace(buf.String()), err
}

func (r *Runner) exec(cmd *exec.Cmd, stdin, _ string) error {
	cmd.Env = r.env()
	if r.DryRun {
		r.Log.Stepf("[dry-run] %s %s", cmd.Path, strings.Join(cmd.Args[1:], " "))
		return nil
	}
	var buf strings.Builder
	cmd.Stdout = &buf
	cmd.Stderr = &buf
	if stdin != "" {
		cmd.Stdin = strings.NewReader(stdin)
	}
	err := cmd.Run()
	if err != nil {
		out := strings.TrimSpace(buf.String())
		if out != "" {
			return fmt.Errorf("%w; output: %s", err, firstLines(out, 8))
		}
		return err
	}
	if r.Log != nil {
		if out := strings.TrimSpace(buf.String()); out != "" {
			r.Log.Debugf("command output: %s -> %s", strings.Join(cmd.Args, " "), firstLines(out, 4))
		}
	}
	return nil
}

func (r *Runner) env() []string {
	if len(r.Env) == 0 {
		return os.Environ()
	}
	return append(os.Environ(), r.Env...)
}

// Exists reports whether a program is on PATH.
func (r *Runner) Exists(name string) bool {
	_, err := exec.LookPath(name)
	return err == nil
}

// LookPath wraps exec.LookPath.
func LookPath(name string) (string, error) { return exec.LookPath(name) }

// CommandExists reports whether a program is on PATH.
func CommandExists(name string) bool {
	_, err := exec.LookPath(name)
	return err == nil
}

func firstLines(s string, n int) string {
	lines := strings.Split(s, "\n")
	if len(lines) > n {
		lines = lines[:n]
	}
	return strings.Join(lines, "\n")
}

// ---- Platform helpers -------------------------------------------------------

var (
	darwinVersionOnce sync.Once
	darwinVersion     string
)

// IsDarwin reports whether we are running on macOS.
func IsDarwin() bool { return runtime.GOOS == "darwin" }

// AppleSilicon reports whether the CPU is arm64.
func AppleSilicon() bool { return runtime.GOARCH == "arm64" }

// DarwinVersion returns the macOS product version (e.g. "27.0").
func DarwinVersion() string {
	if !IsDarwin() {
		return ""
	}
	darwinVersionOnce.Do(func() {
		out, err := exec.Command("/usr/bin/sw_vers", "-productVersion").Output()
		if err != nil {
			darwinVersion = "unknown"
			return
		}
		darwinVersion = strings.TrimSpace(string(out))
	})
	return darwinVersion
}

// HomebrewPrefix returns the Homebrew install prefix for this machine,
// honouring an explicit HOMEBREW_PREFIX override.
func HomebrewPrefix() string {
	if v := os.Getenv("HOMEBREW_PREFIX"); v != "" {
		return v
	}
	if AppleSilicon() {
		return "/opt/homebrew"
	}
	return "/usr/local"
}

// HomebrewBin returns the path to the brew binary.
func HomebrewBin() string { return HomebrewPrefix() + "/bin/brew" }

// HomebrewBinDir returns the directory containing the brew binary.
func HomebrewBinDir() string { return HomebrewPrefix() + "/bin" }

// XcodeCLTInstalled reports whether the Xcode command line tools are present.
func XcodeCLTInstalled() bool {
	_, err := exec.LookPath("clang")
	return err == nil
}

// SudoAvailable reports whether sudo is usable without an interactive prompt.
func SudoAvailable() bool {
	cmd := exec.Command("/usr/bin/sudo", "-n", "true")
	return cmd.Run() == nil
}
