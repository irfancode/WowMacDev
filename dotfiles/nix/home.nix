{ config, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # Home Manager Configuration
  # ═══════════════════════════════════════════════════════════

  home.username = "irfan";
  home.homeDirectory = "/Users/irfan";

  # ═══════════════════════════════════════════════════════════
  # Packages (Nix-managed)
  # ═══════════════════════════════════════════════════════════
  home.packages = with pkgs; [
    # Core tools
    neovim
    nodejs_22
    python312
    git
    github-cli
    go
    rust
    ruby_3_3

    # CLI utilities
    bat
    eza
    fd
    fzf
    ripgrep
    tmux
    btop
    starship
    zellij
    zoxide
    yazi
    lazygit
    hugo
    nushell
    httpie

    # Dev tools
    gcc
    make
    docker
  ];

  # ═══════════════════════════════════════════════════════════
  # Programs Configuration
  # ═══════════════════════════════════════════════════════════
  programs = {
    # Starship prompt
    starship = {
      enable = true;
      settings = {
        format = "$directory$git_branch$git_status$python$rust$node$cmd_duration$character";
        add_newline = true;
        palindrome = true;
        os = { display = true };
        cmd_duration = { format = "[$duration]($style) " };
        git_branch = { format = "[$branch]($style) " };
      };
    };

    # Zoxide
    zoxide = {
      enable = true;
      settings = {
        cmd = "z";
        interact = "auto";
      };
    };

    # FZF
    fzf = {
      enable = true;
      defaultOptions = [
        "--height=40%"
        "--layout=reverse"
        "--border"
      ];
    };

    # Tmux
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      terminal = "tmux-256color";
      extraConfig = ''
        # Split bindings
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # Vim-like pane navigation
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Mouse support
        set -g mouse on
      '';
    };

    # Git
    git = {
      enable = true;
      userName = "Irfan";
      userEmail = "irfan@email.com";
      aliases = {
        s = "status";
        co = "checkout";
        br = "branch";
        st = "status";
        lg = "log --oneline --graph --decorate";
      };
    };
  };

  # ═══════════════════════════════════════════════════════════
  # Dotfiles Symlinks
  # ═══════════════════════════════════════════════════════════
  home.file = {
    # Link dotfiles from this repo
    ".zshrc".source = ../zshrc;
    ".gitconfig".source = ../.gitconfig;
    ".vimrc".source = ../.vimrc;
  };

  # ═══════════════════════════════════════════════════════════
  # Editor Configuration
  # ═══════════════════════════════════════════════════════════
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    extraConfig = ''
      set nocompatible
      filetype plugin indent on
      syntax on
    '';
  };

  # ═══════════════════════════════════════════════════════════
  # Shell Configuration
  # ═══════════════════════════════════════════════════════════
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    historySubstringSearchEnabled = true;
    plugins = [
      "git"
      "docker"
      "node"
      "npm"
      "rust"
    ];
    shellAliases = {
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
    };
  };

  # ═══════════════════════════════════════════════════════════
  # Home Manager Activation
  # ═══════════════════════════════════════════════════════════
  home.stateVersion = "24.11";
}