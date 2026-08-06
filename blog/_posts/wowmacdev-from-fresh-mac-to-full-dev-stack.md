---
layout: post
title: "From Fresh Mac to Full Dev Stack: The WowMacDev Way"
date: 2026-08-05
categories: macos productivity developer-tools terminal diagnostics
author: irfancode
description: "One consolidated toolkit that provisions a new Mac, themes your terminal, keeps you healthy, and manages your whole system — everything I've built, unified."
---

> **TL;DR** — I merged 13 years of my macOS tooling into a single consolidated repo, **WowMacDev**. One command provisions your machine, another diagnoses it, and the whole thing is reversible, verifiable, and beautiful. Here's the story of how it all fits together.

---

## The Ritual

Every developer knows the drill when a new MacBook arrives. The box is shiny. The machine is useless. And then begins the three-hour ritual:

- `xcode-select --install`, because nothing works without it
- clone the dotfiles repo, symlink *everything*
- a wall of `brew install` one-liners you've re-saved for a decade
- `defaults write com.apple.dock autohide-delay -float 0` — memorized, and you're not sure if that's a flex or a cry for help
- 20 minutes Googling how to enable "press and hold to repeat keys"
- realizing your `.zshrc` references a tool you never installed

Two days later, when the fiddling finally stops, you stare at your terminal and think: *this should have taken one command.*

It can. Meet **WowMacDev**.

---

## What WowMacDev Is

WowMacDev is a **consolidated monorepo** that unifies everything I've built for macOS over the years into one place. It's organized into four pillars — each solving a real, painful problem.

```
┌───────────────────────────────────────────────────────────────┐
│                      WOW MAC DEV  ·  MONOREPO                  │
├───────────────┬───────────────┬───────────────┬───────────────┤
│   PROVISION   │    DIAGNOSE   │   MONITOR     │   BEAUTIFY    │
│  setup/boot   │  health/check │  resource     │  terminal     │
│   omamac      │  macOS-System │  Mac-Sysmon   │  chroma-      │
│  mac-bootstrap│  -Diagnostics │  MacAdmin     │  terminal     │
│  mac-catalyst │  macos-setup- │               │  dotfiles     │
│  mac-app-sync │  tools        │               │               │
│  mac-dev-setup│               │               │               │
└───────────────┴───────────────┴───────────────┴───────────────┘
```

### 1. Provision — from fresh to functional in one command

The classic answer to Mac setup is a shell script — and that answer has exactly three problems: it's **not reversible**, **not verifiable**, and **not extendable**.

WowMacDev fixes that with a layered approach:

- **[omamac](omamac/)** — a single Go binary that treats setup the way you treat production: as *declarative, reversible, and verifiable* state. Organized around modules, each with four hooks: `install`, `update`, `verify`, and uninstall. Inspired by Omakub, built for Apple Silicon.
- **[mac-bootstrap](mac-bootstrap/)** — the one-liner for the rest of us. Installs 55+ Homebrew packages, 12 desktop apps, language runtimes (Node, Go, Rust, Python, Java), Cloud CLIs (AWS, Azure, GCP, K8s, Terraform), and macOS preferences in a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/irfancode/WowMacDev/main/mac-bootstrap/bootstrap.sh | bash
```

- **[mac-app-sync](mac-app-sync/)** — backup and restore *everything*: Homebrew formulae, casks, App Store apps, npm/pnpm/yarn/pip gems, and VS Code extensions. Your entire app inventory, portable.
- **[mac-catalyst](mac-catalyst/)** — recreate your development environment on any machine in minutes with export/install/diff workflows.
- **[mac-dev-setup](mac-dev-setup/)** — the original Forward Deployment Engineer's guide (now superseded by mac-bootstrap) that documents *why* each tool earns its place.

> **A note on history:** three upstream repos (`MacDevEnv`, `Mac-Sysmon`, `MacAdmin-master`) were empty shells, so they've been merged in as placeholders ready for content.

### 2. Diagnose — know your Mac's health in seconds

Two tools, both born from the same frustration: manual hardware checks that take 30+ seconds and require remembering arcane commands.

- **[macOS-System-Diagnostics](macOS-System-Diagnostics/)** — checks **16+ system components in parallel** and gives you a complete health overview in ~2 seconds. Parallelized checks, hardware-level insight, one clean report.
- **[macos-setup-tools](macos-setup-tools/)** — a four-script toolkit: setup, diagnostics, performance checks, and disk usage, automating everything from enabling battery percentage to monitoring performance.

### 3. Monitor & manage — keep your system healthy

- **[MacAdmin](MacAdmin/)** — a beautiful native macOS system administration tool with a SwiftUI-inspired design, React frontend + FastAPI backend. Built specifically for macOS Tahoe/Sequoia.

### 4. Beautify — a terminal you actually want to work in

Your terminal is where you run code, manage files, interact with Git, and SSH into servers. Making it look good isn't vanity — it's ergonomics.

- **[chroma-terminal](chroma-terminal/)** — 10 beautiful Monokai Pro–inspired themes for Ghostty, Alacritty, Warp, Hyper.js, Foot, Kitty, and macOS Terminal, with a single-command cross-platform setup utility.
- **[dotfiles](dotfiles/)** — the full terminal stack: Ghostty + Zellij + Starship, plus a Nix package manager guide, all config-as-code and portable to new machines.

---

## Why One Repo?

For years these lived as 13 separate repositories. Consolidating into WowMacDev gives you:

- **One README** to understand the whole stack
- **One command** to provision, and **one command** to diagnose
- **Cross-repo consistency** — themes from chroma-terminal pair with the dotfiles they were designed for
- **One place to contribute** — PRs, issues, and release notes in a single home

---

## Getting Started

Everything is in this repo. Start with the pillar that matches your pain:

| Your pain | Start here |
|-----------|------------|
| "New Mac, three-hour setup ritual" | [omamac](omamac/) · [mac-bootstrap](mac-bootstrap/) |
| "My Mac feels slow / something's wrong" | [macOS-System-Diagnostics](macOS-System-Diagnostics/) |
| "My terminal looks like 1999" | [chroma-terminal](chroma-terminal/) · [dotfiles](dotfiles/) |
| "How do I migrate to a new machine?" | [mac-app-sync](mac-app-sync/) · [mac-catalyst](mac-catalyst/) |
| "I want to manage my whole system" | [MacAdmin](MacAdmin/) |

---

## The Moral

After setting up Macs six times across a career, I stopped re-learning the same lessons and started encoding them. WowMacDev is the sum of that work — declarative, reversible, verifiable, and beautiful. The next time a MacBook arrives, the ritual is over.

It takes one command.

*Irfan · irfancode*
