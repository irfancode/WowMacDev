// Package gitmodule configures git: identity, defaults, LFS, aliases, a
// global gitignore, SSH keys and optional GitHub authentication.
package gitmodule

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/omamac/omamac/internal/config"
	"github.com/omamac/omamac/internal/fsutil"
	"github.com/omamac/omamac/internal/module"
	"github.com/omamac/omamac/internal/state"
)

// Module configures git.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "git" }

// Summary implements module.Module.
func (m *Module) Summary() string {
	return "Git identity, defaults, LFS, aliases, SSH keys and GitHub authentication"
}

// Priority implements module.Module.
func (m *Module) Priority() int { return 20 }

// Enabled implements module.Module.
func (m *Module) Enabled(*config.Config) bool { return true }

const globalGitignore = `# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Editors
*.swp
.idea/
.vscode/
*.sublime-*

# Logs & temp
*.log
*.tmp

# Build artifacts
node_modules/
dist/
build/
target/
__pycache__/
*.pyc
.venv/
venv/
env/
.coverage
coverage.xml

# OS / misc
Thumbs.db
.DS_Store
`

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	if !ctx.Runner.Exists("git") {
		return fmt.Errorf("git not installed (the homebrew module installs it)")
	}
	g := ctx.Config.Git
	home, _ := os.UserHomeDir()

	if err := m.writeGitconfig(ctx, home); err != nil {
		return err
	}
	if err := m.writeGlobalGitignore(ctx, home); err != nil {
		return err
	}
	if g.LFS && ctx.Runner.Exists("git-lfs") {
		ctx.Log.Info("initializing git-lfs")
		if err := ctx.Runner.Run("git", "lfs", "install", "--skip-repo"); err != nil {
			return fmt.Errorf("git lfs install: %w", err)
		}
	}
	if g.SSH {
		if err := m.ensureSSHKey(ctx, home); err != nil {
			return err
		}
	}
	if g.GitHubAuth && ctx.Runner.Exists("gh") {
		if err := m.ensureGitHubAuth(ctx); err != nil {
			return err
		}
	}
	if g.GPG {
		ctx.Log.Warn("GPG signing requires your key; set commit.gpgsign via `git config --global`")
	}

	return ctx.State.Append(state.Entry{
		Module: m.Name(),
		Action: state.ActionInstall,
		Status: state.StatusOK,
		Detail: fmt.Sprintf("user=%s email=%s branch=%s", g.UserName, g.UserEmail, g.DefaultBranch),
	})
}

func (m *Module) writeGitconfig(ctx *module.Context, home string) error {
	g := ctx.Config.Git
	if g.DefaultBranch == "" {
		g.DefaultBranch = "main"
	}
	if g.Editor == "" {
		g.Editor = "code --wait"
	}

	var b strings.Builder
	b.WriteString("[core]\n")
	b.WriteString("\teditor = " + g.Editor + "\n")
	b.WriteString("\texcludesfile = ~/.gitignore_global\n")
	b.WriteString("\tignorecase = false\n\n")

	b.WriteString("[init]\n\tdefaultBranch = " + g.DefaultBranch + "\n\n")

	b.WriteString("[pull]\n\trebase = false\n\n")
	b.WriteString("[push]\n\tdefault = simple\n\tautoSetupRemote = true\n\n")
	b.WriteString("[color]\n\tui = auto\n\n")
	b.WriteString("[credential]\n\thelper = osxkeychain\n\n")
	b.WriteString("[diff]\n\tcolorMoved = zebra\n\n")
	b.WriteString("[merge]\n\tconflictstyle = zdiff3\n\n")

	if g.UserName != "" {
		b.WriteString("[user]\n\tname = " + g.UserName + "\n")
	}
	if g.UserEmail != "" {
		b.WriteString("\temail = " + g.UserEmail + "\n")
	}
	if g.GPG {
		b.WriteString("\tsigningKey = ssh\n")
		b.WriteString("[commit]\n\tgpgsign = true\n")
	}
	if len(g.Aliases) > 0 {
		b.WriteString("\n[alias]\n")
		for _, a := range g.Aliases {
			parts := strings.SplitN(a, "=", 2)
			if len(parts) == 2 {
				b.WriteString("\t" + strings.TrimSpace(parts[0]) + " = " + strings.TrimSpace(parts[1]) + "\n")
			}
		}
	}

	path := filepath.Join(home, ".gitconfig")
	changed, err := fsutil.WriteFileIfChanged(path, b.String(), 0o644)
	if err != nil {
		return err
	}
	if changed || ctx.DryRun {
		ctx.Log.Successf("wrote %s", path)
	}
	return nil
}

func (m *Module) writeGlobalGitignore(ctx *module.Context, home string) error {
	path := filepath.Join(home, ".gitignore_global")
	changed, err := fsutil.WriteFileIfChanged(path, globalGitignore, 0o644)
	if err != nil {
		return err
	}
	if changed || ctx.DryRun {
		ctx.Log.Successf("wrote %s", path)
	}
	return nil
}

func (m *Module) ensureSSHKey(ctx *module.Context, home string) error {
	key := filepath.Join(home, ".ssh", "id_ed25519")
	if _, err := os.Stat(key); err == nil {
		ctx.Log.Infof("SSH key already present: %s", key)
		return nil
	}
	ctx.Log.Info("generating ed25519 SSH key")
	if err := ctx.Runner.Run("ssh-keygen", "-t", "ed25519", "-C", ctx.Config.Git.UserEmail, "-f", key, "-N", ""); err != nil {
		return fmt.Errorf("ssh-keygen: %w", err)
	}
	// Ensure the agent picks it up and print the public key for registration.
	ctx.Runner.Run("ssh-add", key)
	pub, err := os.ReadFile(key + ".pub")
	if err != nil {
		return err
	}
	ctx.Log.Info("add this public key to your accounts (GitHub, GitLab...):")
	ctx.Log.Raw("%s", strings.TrimSpace(string(pub)))
	return nil
}

func (m *Module) ensureGitHubAuth(ctx *module.Context) error {
	out, err := ctx.Runner.Output("gh", "auth", "status")
	if err == nil && strings.Contains(out, "Logged in") {
		ctx.Log.Info("GitHub CLI already authenticated")
		return nil
	}
	if ctx.DryRun {
		ctx.Log.Step("[dry-run] gh auth login")
		return nil
	}
	ctx.Log.Warn("running `gh auth login` — follow the interactive prompt")
	return ctx.Runner.Run("gh", "auth", "login")
}

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	home, _ := os.UserHomeDir()
	if err := m.writeGitconfig(ctx, home); err != nil {
		return err
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionUpdate, Status: state.StatusOK})
}

// Remove implements module.Module. It removes the omamac-managed gitignore and
// disables LFS hooks, leaving identity in place.
func (m *Module) Remove(ctx *module.Context) error {
	if !ctx.DryRun {
		home, _ := os.UserHomeDir()
		ignore := filepath.Join(home, ".gitignore_global")
		if _, err := os.Stat(ignore); err == nil {
			if err := os.Remove(ignore); err != nil {
				return err
			}
		}
	}
	if ctx.Runner.Exists("git-lfs") {
		ctx.Runner.Run("git", "lfs", "uninstall")
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	if !ctx.Runner.Exists("git") {
		return fmt.Errorf("git not installed")
	}
	if err := ctx.Runner.Run("git", "--version"); err != nil {
		return fmt.Errorf("git broken: %w", err)
	}
	if ctx.Config.Git.LFS && !ctx.Runner.Exists("git-lfs") {
		return fmt.Errorf("git-lfs not installed")
	}
	return nil
}
