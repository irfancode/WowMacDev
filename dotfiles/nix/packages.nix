{ pkgs ? import <nixpkgs> {} }:

pkgs.buildEnv {
  name = "irfan-packages";

  buildInputs = with pkgs; [
    neovim
    nodejs_22
    python312
    git
    github-cli
    go
    rust
    ruby_3_3
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
    httpie
    hugo
    nushell
    gcc
    make
    docker
  ];
}