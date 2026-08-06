// Package module defines the module contract that powers omamac. Every
// capability — Homebrew, git, shell, macOS preferences, applications, AI
// tooling — is a Module exposing install/update/remove/verify. Third-party
// plugins implement the same contract via shell scripts.
package module

import (
	"github.com/irfancode/omamac/internal/config"
	"github.com/irfancode/omamac/internal/logging"
	"github.com/irfancode/omamac/internal/state"
	"github.com/irfancode/omamac/internal/util"
)

// Action names shared with the state journal.
type Action = state.Action

// Well-known action constants.
const (
	ActionInstall = state.ActionInstall
	ActionUpdate  = state.ActionUpdate
	ActionRemove  = state.ActionRemove
	ActionVerify  = state.ActionVerify
	ActionApply   = state.ActionApply
)

// Context carries everything a module needs to do its job.
type Context struct {
	Log       *logging.Logger
	Config    *config.Config
	State     *state.Store
	Runner    *util.Runner
	Progress  ProgressAPI
	DryRun    bool
	Verbose   bool
	JSON      bool
	ConfigDir string
	DataDir   string
	StateDir  string
	HomeDir   string
}

// ProgressAPI is the minimal progress surface modules rely on. It is optional:
// if nil, callers should fall back to Context.Log.
type ProgressAPI interface {
	Start(total int)
	Step(label string)
	Update(label string)
	Finish(label string, ok bool)
}

// Module is the contract every omamac capability implements.
type Module interface {
	// Name is the stable identifier used in config, CLI and the journal.
	Name() string
	// Summary is a short human description.
	Summary() string
	// Priority orders modules; lower runs first. The homebrew module is 0.
	Priority() int
	// Enabled reports whether the module should run under this config.
	Enabled(cfg *config.Config) bool

	Install(ctx *Context) error
	Update(ctx *Context) error
	Remove(ctx *Context) error
	Verify(ctx *Context) error
}
