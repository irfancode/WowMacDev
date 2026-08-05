# The last time you'll set up a Mac by hand

> Opinionated macOS workstation bootstrapping — one command, fully reversible,
> and extendable with nothing but shell scripts.

---

You've been there. The new MacBook arrives, shiny and useless. And then the
three-hour ritual begins:

- `xcode-select --install`, because nothing works without it
- clone the dotfiles repo, symlink *everything*
- a wall of `brew install` one-liners you've saved and re-saved for a decade
- `defaults write com.apple.dock autohide-delay -float 0` — you have this one
  memorized, and you're not sure if that's a flex or a cry for help
- install nvm, install zsh plugins, install a font, install *another* font
- spend 20 minutes Googling how to enable "press and hold to repeat keys"
- realize your `.zshrc` references a tool you didn't install yet
- find the git global config that hardcodes the *previous* machine's email

Two days later, when you've finally stopped fiddling, you stare at your
terminal and think: *this should have taken one command.*

It can. Meet **omamac**.

---

## The problem with shell scripts

The classic answer is a setup script — and it has exactly three problems:

1. **Not reversible.** Run it once and it's done. There's no uninstall, no
   rollback, no "did that actually work?" There's just you and a lot of state
   you didn't mean to create.
2. **Not verifiable.** A script that "ran" is not a script that *worked*. Did
   the Homebrew tap get added? Did the cask actually install? Nothing checks.
3. **Not extendable.** Every team has *that* internal tool that needs three
   brew formulae and an env var. Adding it means editing the script — and
   re-running the whole damn thing, because no one knows which parts are safe
   to skip.

omamac treats setup the way you treat production: as **declarative,
reversible, and verifiable** state.

---

## What omamac is

omamac is a single Go binary that turns a fresh macOS install into a fully
configured developer workstation. Inspired by
[Omakub](https://omakub.org), built for Apple Silicon, and designed like a
small, well-tested product instead of a script someone's friend gave them.

It's organized around **modules**. Every capability is a module with four
hooks:

```
install   → set it up
update    → bring it up to date
verify    → prove it's actually working
remove    → roll it back cleanly
```

Homebrew, fonts, applications, git, shell, language toolchains, cloud CLIs,
VS Code, AI tooling, macOS preferences, dotfiles, cleanup — eighteen modules
out of the box, each with tests and a CI-enforced contract. Pick what you want,
enable what you don't, and let the order of operations be the framework's
problem, not yours.

## The three ideas that make it feel like magic

**1. Every change is recorded in an append-only journal.**

Before omamac touches anything, it writes down what it's about to do — and
afterwards, what it did. `omamac uninstall` reads that journal and reverses
every mutation, in reverse order. You don't need to remember what you
installed. The machine remembers for you.

**2. Dry-run is real.**

```
$ omamac install --dry-run
▸ homebrew        ensure Homebrew is installed
▸ fonts           install Nerd Fonts from config
▸ git             configure identity, LFS, SSH keys
▸ shell           set up zsh, Starship, zoxide, fzf
▸ macos           apply macOS preferences
```

Nothing runs. Nothing is written. You see exactly what *will* happen — and you
can preview the entire thing with `--json` and pipe it into your own tooling.
Dry-run is *so* respected that even the state journal doesn't get touched when
you use it.

**3. `verify` is a first-class citizen.**

`omamac doctor` checks your network, your shell, your Homebrew — and then
runs every module's `verify` hook to prove the setup actually works. "It
ran" is no longer an acceptable answer. Now it's "all 10 checks passed."

Plus a full backup/restore cycle: `omamac backup` snapshots your Brewfile,
your `defaults`, your VS Code extensions, and the config itself into a
restorable archive — so a machine can be resurrected, not just installed.

---

## Extending it with shell scripts

Here's the part that hooks people: **you don't need to know Go to add
capabilities.**

A plugin is a directory with a YAML manifest and plain shell scripts:

```
~/.config/omamac/plugins/
  company/
    acme/
      plugin.yaml      # name, description, depends_on
      install.sh       # the four lifecycle hooks
      update.sh
      remove.sh
      verify.sh
```

```yaml
# plugin.yaml
name: acme
title: Acme Toolkit
description: Installs the Acme CLI and shell integration
depends_on: [homebrew]
commands:
  install: install.sh
  update: update.sh
  remove: remove.sh
  verify: verify.sh
```

```sh
# install.sh — written by you, run by omamac
brew install --formula acme/tap/acme
echo 'eval "$(acme shell-init)"' >> "$HOME/.config/omamac/shell/20-acme.sh"
```

Add it, list it, enable it, disable it — same journal, same dry-run safety,
same verify hook — and `omamac install --module acme` runs just that plugin.

Your team's internal tooling is now a five-minute plugin instead of a
"helpful" shell script that lives on a wiki page and deletes your home
directory if you run it twice.

---

## Why it's production-shaped

This isn't a weekend script. It's built like software that has to work on
Monday morning:

- **One static binary.** `brew install omamac`, or build it with `make build`.
- **A real module contract.** Enforced by the Go interfaces, tested in CI.
- **CI on macOS arm64 *and* x86_64.** Because Apple Silicon didn't kill
  Intel machines.
- **Linting, unit tests, shellcheck, and a smoke test in every pipeline run.**
  `make check` runs all of it locally too.
- **A Homebrew tap formula and goreleaser release pipeline**, because a tool
  that bootstraps Homebrew should respect the ecosystem it lives in.

```sh
# the whole journey
curl -fsSL https://raw.githubusercontent.com/irfancode/omamac/main/install.sh | bash
omamac install --yes     # or: omamac install --dry-run first
omamac doctor            # prove it all works
omamac backup            # so you never have to do this again
```

---

## What a fresh machine feels like

Thirty seconds after the box is opened:

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/irfancode/omamac/main/install.sh)"
$ omamac install --yes
```

And then the terminal does what you spent an evening doing last time —
installs the tools, configures the shell, drops in your aliases and
functions, applies the macOS preferences that make your Mac feel like yours,
sets up git identity and SSH keys, and ends with:

```
✓ all 10 modules finished
✓ verify: all 10 checks passed
```

Your dotfiles, your aliases, your prompt, your fonts, your keyboard. On a
brand-new machine. In one command. And when you buy the *next* Mac, you won't
redo any of it — you'll run `omamac restore` on a backup that's one keystroke
away.

That's the last time you set up a Mac by hand.

---

*omamac is MIT-licensed, open source, and hungry for contributors. Star it,
file an issue, or write a plugin for your team's stack — the docs for writing
plugins take about ten minutes to read.*

**[github.com/irfancode/omamac](https://github.com/irfancode/omamac)**
