{ config, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # Nix Darwin Configuration for macOS
  # ═══════════════════════════════════════════════════════════

  # Use unstable packages for newer versions
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # ═══════════════════════════════════════════════════════════
  # Environment Variables
  # ═══════════════════════════════════════════════════════════
  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    XDG_CONFIG_HOME = "$HOME/.config";
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
  };

  # ═══════════════════════════════════════════════════════════
  # Homebrew Packages (for macOS-only apps)
  # ═══════════════════════════════════════════════════════════
  homebrew = {
    enable = true;
    casks = [
      # Terminals
      "ghostty"
      "orbstack"

      # Window Management
      "rectangle"

      # Development
      "cursor"
      "claude"
      "bruno"

      # Productivity
      "obsidian"
      "typora"

      # Communication
      "slack"
      "discord"
      "whatsapp"

      # Browsers
      "firefox"
    ];
  };

  # ═══════════════════════════════════════════════════════════
  # Programs
  # ═══════════════════════════════════════════════════════════
  programs = {
    # Git configuration
    git = {
      enable = true;
      config = {
        user.name = "Irfan";
        user.email = "irfan@email.com";
        core.editor = "nvim";
        init.defaultBranch = "main";
      };
    };
  };
}