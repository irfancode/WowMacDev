// Package aimodule installs AI developer tools (Claude Code, opencode, Gemini
// CLI, OpenAI Codex, GitHub Copilot CLI) and Ollama with configured models.
package aimodule

import (
	"fmt"
	"strings"

	"github.com/omamac/omamac/internal/config"
	"github.com/omamac/omamac/internal/homebrew"
	"github.com/omamac/omamac/internal/module"
	"github.com/omamac/omamac/internal/state"
)

// Module installs AI tools.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "ai" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "AI developer tools and Ollama models" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 35 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool {
	ai := cfg.AI
	return ai.Claude || ai.OpenCode || ai.Gemini || ai.OpenAI || ai.Copilot || ai.Ollama
}

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	ai := ctx.Config.AI

	npmPkgs := []string{}
	if ai.Claude {
		npmPkgs = append(npmPkgs, "@anthropic-ai/claude-code")
	}
	if ai.OpenCode {
		npmPkgs = append(npmPkgs, "opencode-ai")
	}
	if ai.Gemini {
		npmPkgs = append(npmPkgs, "@google/gemini-cli")
	}
	if ai.OpenAI {
		npmPkgs = append(npmPkgs, "@openai/codex")
	}
	if ai.Copilot {
		npmPkgs = append(npmPkgs, "@github/copilot")
	}
	if len(npmPkgs) > 0 {
		ctx.Log.Stepf("installing AI CLIs: %s", strings.Join(npmPkgs, ", "))
		args := append([]string{"install", "-g"}, npmPkgs...)
		if err := ctx.Runner.Run("npm", args...); err != nil {
			return fmt.Errorf("npm install -g: %w", err)
		}
	}

	if ai.Ollama {
		brew := homebrew.New(ctx.Runner, ctx.Log)
		if err := brew.InstallFormulae(ctx, "ollama"); err != nil {
			return err
		}
		if !ctx.DryRun && ctx.Runner.Exists("ollama") {
			for _, model := range ai.Models {
				ctx.Log.Stepf("pulling ollama model %s", model)
				if err := ctx.Runner.Run("ollama", "pull", model); err != nil {
					ctx.Log.Warnf("ollama pull %s: %v", model, err)
				}
			}
		}
	}

	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusOK, Detail: strings.Join(npmPkgs, ", ")})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusOK})
}

// Remove implements module.Module. CLI packages are uninstalled; Ollama is left
// installed (removing it would delete user models).
func (m *Module) Remove(ctx *module.Context) error {
	ai := ctx.Config.AI
	var pkgs []string
	if ai.Claude {
		pkgs = append(pkgs, "@anthropic-ai/claude-code")
	}
	if ai.OpenCode {
		pkgs = append(pkgs, "opencode-ai")
	}
	if ai.Gemini {
		pkgs = append(pkgs, "@google/gemini-cli")
	}
	if ai.OpenAI {
		pkgs = append(pkgs, "@openai/codex")
	}
	if ai.Copilot {
		pkgs = append(pkgs, "@github/copilot")
	}
	if len(pkgs) > 0 {
		args := append([]string{"uninstall", "-g"}, pkgs...)
		_ = ctx.Runner.Run("npm", args...)
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	return nil
}
