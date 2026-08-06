// Package cli implements the omamac command-line interface.
package cli

import (
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"time"

	"github.com/irfancode/omamac/internal/config"
	"github.com/irfancode/omamac/internal/logging"
	"github.com/irfancode/omamac/internal/module"
	"github.com/irfancode/omamac/internal/state"
	"github.com/irfancode/omamac/internal/tui"
	"github.com/irfancode/omamac/internal/util"
)

// version is stamped at build time via -ldflags.
var version = "dev"

// globalOptions holds flag values shared across subcommands.
type globalOptions struct {
	Verbose    bool
	Debug      bool
	JSON       bool
	DryRun     bool
	Yes        bool
	ConfigPath string
	Color      string
	Modules    []string
	Exclude    []string
	LogFile    string
}

// App is the assembled runtime for a command invocation.
type App struct {
	Version   string
	Log       *logging.Logger
	Config    *config.Config
	State     *state.Store
	Registry  *module.Registry
	Options   *globalOptions
	ConfigDir string
	DataDir   string
	StateDir  string
	HomeDir   string
}

// buildApp constructs the App: logger, layered config, journal and module
// registry (including discovered plugins).
func buildApp(opts *globalOptions, version string) (*App, error) {
	level := slog.LevelInfo
	if opts.Debug {
		level = slog.LevelDebug
	}

	logOut := os.Stderr
	log, err := logging.New(logging.Options{
		Level:  level,
		JSON:   opts.JSON,
		Color:  opts.Color,
		Output: logOut,
		File:   opts.LogFile,
	})
	if err != nil {
		return nil, err
	}

	cfgDir := config.ConfigDir()
	dataDir := config.DataDir()
	stateDir := config.StateDir()
	home, _ := os.UserHomeDir()

	paths := []string{config.DefaultConfigPath()}
	if env := os.Getenv("OMAMAC_CONFIG"); env != "" {
		paths = append(paths, env)
	}
	if opts.ConfigPath != "" {
		paths = append(paths, opts.ConfigPath)
	}
	cfg, err := config.Load(paths...)
	if err != nil {
		log.Errorf("configuration problem: %v", err)
		return nil, err
	}

	store, err := state.Open(filepath.Join(stateDir, "state.jsonl"))
	if err != nil {
		log.Errorf("state store: %v", err)
		return nil, err
	}
	store.DryRun = opts.DryRun

	reg := module.New()
	registerModules(reg)
	plugins, perr := module.LoadPlugins(
		filepath.Join(cfgDir, "plugins"),
		filepath.Join(dataDir, "plugins"),
	)
	if perr != nil {
		log.Warnf("plugin load skipped: %v", perr)
	}
	for _, p := range plugins {
		reg.Register(p.Adapter())
		log.Debugf("loaded plugin: %s (%s)", p.Name, filepath.Base(filepath.Dir(p.Dir)))
	}

	return &App{
		Version:   version,
		Log:       log,
		Config:    cfg,
		State:     store,
		Registry:  reg,
		Options:   opts,
		ConfigDir: cfgDir,
		DataDir:   dataDir,
		StateDir:  stateDir,
		HomeDir:   home,
	}, nil
}

// close releases resources (log file handles).
func (a *App) close() { _ = a.Log.Close() }

// ctx assembles a module.Context for a command invocation.
func (a *App) ctx() *module.Context {
	opts := a.Options
	runner := &util.Runner{DryRun: opts.DryRun, Log: a.Log}
	var prog module.ProgressAPI
	if !opts.JSON && !opts.DryRun {
		prog = tui.New(os.Stderr)
	}
	return &module.Context{
		Log:       a.Log,
		Config:    a.Config,
		State:     a.State,
		Runner:    runner,
		Progress:  prog,
		DryRun:    opts.DryRun,
		Verbose:   opts.Verbose,
		JSON:      opts.JSON,
		ConfigDir: a.ConfigDir,
		DataDir:   a.DataDir,
		StateDir:  a.StateDir,
		HomeDir:   a.HomeDir,
	}
}

// runModules executes an action across the enabled module set, in priority
// order, collecting results. It stops at the first failure unless stopOnError
// is false (used by verify).
func (a *App) runModules(action module.Action, stopOnError bool) []moduleResult {
	ctx := a.ctx()
	mods, err := a.Registry.Filter(a.Config, a.Options.Modules, a.Options.Exclude)
	if err != nil {
		a.Log.Errorf("filtering modules: %v", err)
		return []moduleResult{{Module: "*", Action: string(action), Status: "failed", Error: err.Error()}}
	}

	var results []moduleResult
	for _, m := range mods {
		res := a.execModule(ctx, m, action)
		results = append(results, res)
		if res.Status == "failed" && stopOnError {
			break
		}
	}
	if len(mods) == 0 {
		a.Log.Warnf("no modules selected (include=%v exclude=%v)", a.Options.Modules, a.Options.Exclude)
	}
	return results
}

type moduleResult struct {
	Module     string `json:"module"`
	Summary    string `json:"summary"`
	Action     string `json:"action"`
	Status     string `json:"status"`
	Error      string `json:"error,omitempty"`
	DurationMs int64  `json:"duration_ms"`
}

func (a *App) execModule(ctx *module.Context, m module.Module, action module.Action) moduleResult {
	start := time.Now()
	label := fmt.Sprintf("%s %s", action, m.Name())
	res := moduleResult{Module: m.Name(), Summary: m.Summary(), Action: string(action)}

	var fn func(*module.Context) error
	switch action {
	case module.ActionInstall:
		fn = m.Install
	case module.ActionUpdate:
		fn = m.Update
	case module.ActionRemove:
		fn = m.Remove
	case module.ActionVerify:
		fn = m.Verify
	default:
		res.Status = "failed"
		res.Error = "unsupported action"
		return res
	}

	run := func() error { return fn(ctx) }
	err := run()
	res.DurationMs = time.Since(start).Milliseconds()

	journalStatus := state.StatusOK
	switch {
	case err != nil:
		res.Status = "failed"
		res.Error = err.Error()
		journalStatus = state.StatusFailed
	case ctx.DryRun:
		res.Status = "dry-run"
		journalStatus = state.StatusDryRun
	default:
		res.Status = "ok"
	}

	_ = a.State.Append(state.Entry{
		Action: state.Action(action),
		Module: m.Name(),
		Status: journalStatus,
		Detail: errorOrEmpty(err),
	})

	if err != nil {
		a.Log.Failf("%s: %s", label, err)
	} else if !ctx.DryRun {
		a.Log.Success(label)
	} else {
		a.Log.Stepf("[dry-run] %s", label)
	}
	return res
}

func errorOrEmpty(err error) string {
	if err == nil {
		return ""
	}
	return err.Error()
}
