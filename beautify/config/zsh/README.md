# Shell modules

`config/zshrc` is a loader, not a config. It finds its own directory and
sources every `NN-*.zsh` file here in numeric order:

```zsh
_zshrc="${ZDOTDIR:-$HOME}/.zshrc"
ZSH_CONFIG_DIR="${_zshrc:A:h}/zsh"
typeset -gU path PATH
for _f in "$ZSH_CONFIG_DIR"/[0-9][0-9]-*.zsh; do source "$_f"; done
```

Use `${_zshrc:A:h}` rather than `$0` or a relative path: the shell does not set
`$0` to the config file, and a relative path breaks the moment you `cd`.

## Why numbers

Renaming a file renumbers the load order, so nothing depends on where a module
sits in this README. The numbers exist only to make the order self-evident and
stable.

| Module | Responsibility | Must come after |
|---|---|---|
| `00-paths` | PATH order and de-duplication | — |
| `05-exports` | `LESS`, `GIT_PAGER`, `AWS_PAGER` | `00-paths` |
| `10-history` | history file, sharing, trimming | `00-paths` |
| `20-keys` | ZLE key bindings | `10-history` |
| `30-tools` | eza/bat/fd/rg aliases, `watch` | `00-paths` |
| `45-git` | git aliases | `00-paths` |
| `50-fzf` | fzf, key bindings, pickers | `30-tools` |
| `55-zoxide` | zoxide init and aliases | `50-fzf` |
| `60-cloud` | AWS/Azure/GCP reporting | `00-paths` |
| `65-k8s` | kubectl helpers, production guard | `60-cloud` |
| `70-docker` | docker helpers, guarded cleanup | `00-paths` |
| `80-functions` | `env-show`, `hget`, `killport` | `00-paths` |
| `90-prompt` | Starship init, `profile` | `50-fzf` |
| `95-plugins` | autosuggestions, direnv, syntax-highlighting | everything |

`95-plugins` is last because zsh-syntax-highlighting re-wraps every ZLE widget;
anything sourced after it gets clobbered. direnv sits just before it, since
direnv's hook installs widgets of its own that highlighting must see.

## Adding a module

Create `NN-name.zsh`. It is plain zsh, not a plugin, so guard anything
optional:

```zsh
if have some-tool; then
  alias x='some-tool'
fi
```

`have <name>` is defined in `00-paths` and is a `command -v` that stays quiet.

## Checking it works

```bash
for f in config/zsh/*.zsh; do zsh -n "$f" || echo "SYNTAX: $f"; done
zsh -i -c 'echo $ZSH_CONFIG_DIR'      # the module directory
zsh -i -c 'env-show'                  # a broad smoke test
```
