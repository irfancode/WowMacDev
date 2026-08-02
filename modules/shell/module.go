// Package shellmodule configures the interactive shell: zsh plugins, history,
// Starship prompt, zoxide, fzf, and per-user aliases/functions/env.
package shellmodule

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/omamac/omamac/internal/config"
	"github.com/omamac/omamac/internal/fsutil"
	"github.com/omamac/omamac/internal/module"
	"github.com/omamac/omamac/internal/state"
)

// Module configures the shell.
type Module struct{}

// Name implements module.Module.
func (m *Module) Name() string { return "shell" }

// Summary implements module.Module.
func (m *Module) Summary() string {
	return "Zsh enhancements: Starship prompt, zoxide, fzf, history, aliases and environment"
}

// Priority implements module.Module.
func (m *Module) Priority() int { return 30 }

// Enabled implements module.Module.
func (m *Module) Enabled(*config.Config) bool { return true }

// shellDir returns the directory holding omamac-managed shell snippets.
func shellDir(ctx *module.Context) string { return filepath.Join(ctx.ConfigDir, "shell") }

// Install implements module.Module.
func (m *Module) Install(ctx *module.Context) error {
	if err := m.ensureShell(ctx); err != nil {
		return err
	}
	if err := m.writeSnippets(ctx); err != nil {
		return err
	}
	if err := m.writeStarship(ctx); err != nil {
		return err
	}
	if err := m.hookShellRc(ctx); err != nil {
		return err
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionInstall, Status: state.StatusOK})
}

func (m *Module) ensureShell(ctx *module.Context) error {
	if ctx.Config.Shell.Shell != "" && ctx.Config.Shell.Shell != "zsh" {
		ctx.Log.Warnf("only zsh is supported; ignoring shell=%s", ctx.Config.Shell.Shell)
	}
	zsh, err := exec.LookPath("zsh")
	if err != nil {
		return fmt.Errorf("zsh not found: %w", err)
	}
	// Skip chsh when the user's login shell is already the target; chsh is
	// interactive and would prompt for a password unnecessarily.
	user := os.Getenv("USER")
	if user != "" {
		if out, err := ctx.Runner.Output("dscl", ".", "-read", "/Users/"+user, "UserShell"); err == nil {
			for _, line := range strings.Split(out, "\n") {
				fields := strings.Fields(line)
				if len(fields) == 2 && fields[0] == "UserShell:" && fields[1] == zsh {
					ctx.Log.Infof("login shell already %s; skipping chsh", zsh)
					return nil
				}
			}
		}
	}
	if err := ctx.Runner.Run("chsh", "-s", zsh); err != nil {
		ctx.Log.Warnf("could not set default shell to zsh: %v", err)
	}
	return nil
}

func (m *Module) writeSnippets(ctx *module.Context) error {
	dir := shellDir(ctx)

	aliases := strings.Join(append(defaultAliases(), ctx.Config.Shell.Aliases...), "\n")
	if err := fsutil.WriteFile(filepath.Join(dir, "10-aliases.sh"), "# omamac aliases\n"+aliases+"\n", 0o644, ctx.DryRun); err != nil {
		return err
	}

	env := strings.Join(append(defaultEnv(), ctx.Config.Shell.Env...), "\n")
	if err := fsutil.WriteFile(filepath.Join(dir, "00-env.sh"), "# omamac environment\n"+env+"\n", 0o644, ctx.DryRun); err != nil {
		return err
	}

	if err := fsutil.WriteFile(filepath.Join(dir, "20-functions.sh"), defaultFunctions, 0o644, ctx.DryRun); err != nil {
		return err
	}

	prompt := promptSnippet(ctx)
	if err := fsutil.WriteFile(filepath.Join(dir, "90-prompt.sh"), prompt, 0o644, ctx.DryRun); err != nil {
		return err
	}
	return nil
}

// SnippetPath returns the numbered snippet file used by language/tool modules
// to contribute shell environment hooks (see writeSnippets for numbering).
func SnippetPath(ctx *module.Context, prefix, name string) string {
	return filepath.Join(ctx.ConfigDir, "shell", prefix+"-"+name+".sh")
}

func (m *Module) writeStarship(ctx *module.Context) error {
	if ctx.Config.Shell.Prompt != "starship" {
		return nil
	}
	path := filepath.Join(ctx.HomeDir, ".config", "starship.toml")
	changed, err := fsutil.WriteFileIfChanged(path, starshipConfig, 0o644)
	if err != nil {
		return err
	}
	if changed || ctx.DryRun {
		ctx.Log.Successf("wrote %s", path)
	}
	return nil
}

// hookShellRc appends the omamac source block to ~/.zshrc and the Homebrew
// shellenv block to ~/.zprofile. The zshrc block sources every snippet in the
// omamac shell dir in lexical order (prefixes control order).
func (m *Module) hookShellRc(ctx *module.Context) error {
	rc := filepath.Join(ctx.HomeDir, ".zshrc")
	block := "# >>> omamac >>>\n" +
		"for f in $HOME/.config/omamac/shell/*.sh; do\n" +
		"  [ -f \"$f\" ] && source \"$f\"\n" +
		"done\n" +
		"# <<< omamac <<<\n"
	if err := fsutil.AppendBlock(rc, ">>> omamac >>>", block, ctx.DryRun); err != nil {
		return err
	}

	profile := filepath.Join(ctx.HomeDir, ".zprofile")
	prefix := "/usr/local"
	if ctx.Runner.Exists("/opt/homebrew/bin/brew") {
		prefix = "/opt/homebrew"
	}
	pblock := "# >>> omamac >>>\neval \"$(" + prefix + "/bin/brew shellenv)\"\n# <<< omamac <<<\n"
	return fsutil.AppendBlock(profile, ">>> omamac >>>", pblock, ctx.DryRun)
}

func defaultAliases() []string {
	return []string{
		"alias ls='eza --icons=auto'",
		"alias ll='eza -la --icons=auto'",
		"alias la='eza -la --icons=auto'",
		"alias lt='eza --tree --icons=auto'",
		"alias cat='bat'",
		"alias grep='rg'",
		"alias find='fd'",
		"alias ..='cd ..'",
		"alias ...='cd ../..'",
		"alias g='git'",
		"alias gs='git status'",
		"alias gl='git log --oneline --graph --decorate -20'",
		"alias v='nvim'",
		"alias ip='ipconfig getifaddr en0'",
	}
}

func defaultEnv() []string {
	return []string{
		"export EDITOR='nvim'",
		"export VISUAL='nvim'",
		"export LANG=en_US.UTF-8",
		"export CLICOLOR=1",
	}
}

const defaultFunctions = `# omamac shell functions
function take() { mkdir -p "$1" && cd "$1"; }
function h() { history | tail -"${1:-20}"; }
function tree() { command eza --tree --icons=auto "$@"; }
function port() { lsof -iTCP:"$1" -sTCP:LISTEN -P | awk 'NR>1{print $1, $2, $9}'; }
function pubkey() { cat "$HOME/.ssh/id_ed25519.pub"; }
`

func promptSnippet(ctx *module.Context) string {
	var b strings.Builder
	b.WriteString("# omamac prompt & shell enhancement init\n")
	if ctx.Config.Shell.Prompt == "starship" {
		b.WriteString("if command -v starship >/dev/null 2>&1; then\n  eval \"$(starship init zsh)\"\nfi\n")
	}
	b.WriteString("if command -v zoxide >/dev/null 2>&1; then\n  eval \"$(zoxide init zsh)\"\nfi\n")
	b.WriteString("if command -v fzf >/dev/null 2>&1; then\n  source <(fzf --zsh)\nfi\n")
	b.WriteString("if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then\n  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh\nfi\n")
	b.WriteString("if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then\n  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\nfi\n")
	b.WriteString("\n# History\nsetopt HIST_IGNORE_ALL_DUPS\nsetopt HIST_FIND_NO_DUPS\nsetopt SHARE_HISTORY\nsetopt APPEND_HISTORY\nHISTSIZE=100000\nSAVEHIST=100000\n")
	return b.String()
}

const starshipConfig = `# omamac Starship config
"$schema" = "https://starship.rs/config-schema.json"

format = "$directory$git_branch$git_status$python$rust$golang$nodejs$cmd_duration$line_break$character"

add_newline = true

[character]
success_symbol = "❯"
error_symbol = "❯"

[directory]
truncation_length = 3
truncate_to_repo = true

[git_branch]
symbol = ""

[git_status]
symbol = ""

[cmd_duration]
min_time = 2000
show_milliseconds = false
format = "took [$duration]($style) "

[python]
format = "[$symbol$version]($style) "
symbol = "🐍 "

[golang]
format = "[$symbol$version]($style) "
symbol = "🐹 "

[rust]
format = "[$symbol$version]($style) "
symbol = "🦀 "

[nodejs]
format = "[$symbol$version]($style) "
symbol = "⬢ "
`

// Update implements module.Module.
func (m *Module) Update(ctx *module.Context) error {
	return m.Install(ctx)
}

// Remove implements module.Module. It leaves ~/.zshrc untouched but clears the
// omamac shell snippets.
func (m *Module) Remove(ctx *module.Context) error {
	if !ctx.DryRun {
		dir := shellDir(ctx)
		entries, err := os.ReadDir(dir)
		if err == nil {
			for _, e := range entries {
				if !e.IsDir() {
					_ = os.Remove(filepath.Join(dir, e.Name()))
				}
			}
		}
	}
	return ctx.State.Append(state.Entry{Module: m.Name(), Action: state.ActionRemove, Status: state.StatusOK})
}

// Verify implements module.Module.
func (m *Module) Verify(ctx *module.Context) error {
	rc := filepath.Join(ctx.HomeDir, ".zshrc")
	data, err := os.ReadFile(rc)
	if err != nil || !strings.Contains(string(data), ">>> omamac >>>") {
		return fmt.Errorf("~/.zshrc not hooked by omamac (re-run install)")
	}
	return nil
}
