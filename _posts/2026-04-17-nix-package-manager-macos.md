---
layout: post
title: "Switching to Nix: Reproducible Package Management on macOS"
date: 2026-04-17
categories: [macOS, Nix, DevOps, Package Manager]
author: Irfan
---

> **TL;DR** — I migrated from Homebrew to Nix for declarative, reproducible package management. Here's why and how you can too.

---

## The Problem with Homebrew

Don't get me wrong — Homebrew is great. Simple, fast, works. But after 5 years, I ran into issues:

- ❌ **No rollbacks** — Upgrade breaks something? Good luck.
- ❌ **One version at a time** — Need nodejs_18 AND nodejs_20? Hope you like Docker.
- ❌ **Not reproducible** — `brew list` on one machine ≠ another.
- ❌ **Dependency conflicts** — "Formula depends on openssl@1.1, but unrelated package needs openssl@3"

Enter **Nix**.

---

## Why Nix?

```
┌─────────────────────────────────────────────────────────────┐
│                    NIX BENEFITS                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ✅ Reproducible     ─  Declarative config = exact same env   │
│   ✅ Rollbacks       ─  nix-env --rollback (instant)         │
│   ✅ Multi-version  ─  nodejs_18 AND nodejs_20 side-by-side │
│   ✅ Isolated deps  ─  No dependency conflicts             │
│   ✅ Cross-platform  ─  macOS + Linux                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## My Package Inventory

Analyzed my current setup — **100+ packages** installed via Homebrew. Here's what migrated to Nix:

| Category | Packages |
|----------|----------|
| **Editors** | neovim |
| **Languages** | nodejs_22, python312, go, rust, ruby_3_3 |
| **CLI Utils** | bat, eza, fd, fzf, ripgrep, tmux, btop |
| **Productivity** | starship, zellij, zoxide, yazi, lazygit |
| **Dev Tools** | git, github-cli, hugo, httpie, docker, lima |

### What's NOT in Nix (use Homebrew):

- Ghostty (macOS only)
- OrbStack (macOS only)
- Rectangle (macOS only)
- Electron apps (Cursor, Claude, Zed, Obsidian)

---

## Configuration

Created a declarative Nix config in my dotfiles:

```nix
# flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  
  outputs = { self, nixpkgs }: {
    packages = nixpkgs.legacyPackages.aarch64-darwin // {
      neovim = nixpkgs.legacyPackages.aarch64-darwin.neovim;
      nodejs_22 = nixpkgs.legacyPackages.aarch64-darwin.nodejs_22;
      # ... more packages
    };
  };
}
```

---

## Installation

```bash
# 1. Install Nix
sh <(curl https://nixos.org/nix/install) --daemon

# 2. Clone dotfiles
git clone https://github.com/irfancode/dotfiles ~/dotfiles

# 3. Enter development shell
cd ~/dotfiles/nix && nix-shell shell.nix

# 4. Or install packages globally
nix-env -f packages.nix -i
```

---

## Quick Usage

```bash
# Enter dev shell with all tools
nix-shell shell.nix

# Install single package
nix-env -iA pkgs.neovim

# List installed
nix-env -q

# Rollback (if something breaks)
nix-env --rollback
```

---

## Home Manager

For dotfile sync, using **Home Manager**:

```nix
# home.nix
home.packages = with pkgs; [
  neovim
  nodejs_22
  starship
  zoxide
  # ...
];

programs.starship.enable = true;
programs.tmux.enable = true;
```

---

## The Trade-offs

| Aspect | Nix | Homebrew |
|--------|-----|---------|
| **Ease of use** | Steeper learning | Easier |
| **Package count** | ~80k packages | ~15k formulas |
| **macOS apps** | Limited | Full (Cask) |
| **Rollbacks** | ✅ Native | ❌ Manual |

---

## Conclusion

Nix isn't for everyone. If you:
- Want reproducible setups across machines → **Nix**
- Need multi-version support → **Nix**
- Just want it to work → **Homebrew**

For me? Nix is the future. My dotfiles now describe my *entire* dev environment — and that's powerful.

---

## Resources

- [Nix Official](https://nixos.org)
- [Nixpkgs](https://search.nixos.org/packages)
- [Home Manager](https://github.com/nix-community/home-manager)
- [My Dotfiles](https://github.com/irfancode/dotfiles)

---

**#Nix #PackageManager #macOS #Reproducibility #DevOps**