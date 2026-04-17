{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    neovim
    git
    go
    rust
    bat
    eza
    fd
    fzf
    ripgrep
    tmux
    starship
    zellij
    zoxide
    lazygit
  ];
}