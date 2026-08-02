// Package javamodule provisions a JDK (Temurin LTS) and Maven/Gradle.
package javamodule

import (
	"fmt"

	"github.com/omamac/omamac/internal/config"
	"github.com/omamac/omamac/internal/fsutil"
	"github.com/omamac/omamac/internal/homebrew"
	"github.com/omamac/omamac/internal/lang"
	"github.com/omamac/omamac/internal/module"
	"github.com/omamac/omamac/internal/state"
	shellmodule "github.com/omamac/omamac/modules/shell"
)

// Module installs Java.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "java" }

// Summary implements module.Module.
func (m *Module) Summary() string { return "JDK (Temurin), Maven and Gradle" }

// Priority implements module.Module.
func (m *Module) Priority() int { return 54 }

// Enabled implements module.Module.
func (m *Module) Enabled(cfg *config.Config) bool { return lang.Enabled(cfg, "java") }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	brew := homebrew.New(ctx.Runner, ctx.Log)
	if err := brew.InstallCasks(ctx, "temurin"); err != nil {
		return err
	}
	if err := brew.InstallFormulae(ctx, "maven", "gradle"); err != nil {
		return err
	}

	snippet := `# omamac java
export JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null || echo /Library/Java/JavaVirtualMachines/*.jdk/Contents/Home)"
export PATH="$JAVA_HOME/bin:$PATH"
`
	if err := fsutil.WriteFile(shellmodule.SnippetPath(ctx, "14", "java"), snippet, 0o644, ctx.DryRun); err != nil {
		return err
	}

	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusOK})
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusOK})
}

// Remove implements module.Module.
func (m *Module) Remove(ctx *module.Context) error {
	_ = fsutil.WriteFile(shellmodule.SnippetPath(ctx, "14", "java"), "", 0o644, ctx.DryRun)
	brew := homebrew.New(ctx.Runner, ctx.Log)
	_ = brew.Uninstall(ctx, []string{"maven", "gradle"}, []string{"temurin"})
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	if !ctx.Runner.Exists("java") {
		return fmt.Errorf("java not installed")
	}
	return nil
}
