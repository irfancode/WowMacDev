{
  description = "Irfan's Nix Package Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in
    {
      packages.aarch64-darwin.default = pkgs.neovim;
      packages.aarch64-darwin.neovim = pkgs.neovim;
      packages.aarch64-darwin.git = pkgs.git;
      packages.aarch64-darwin.go = pkgs.go;
      packages.aarch64-darwin.bat = pkgs.bat;
      packages.aarch64-darwin.eza = pkgs.eza;
      packages.aarch64-darwin.fd = pkgs.fd;
      packages.aarch64-darwin.fzf = pkgs.fzf;
      packages.aarch64-darwin.ripgrep = pkgs.ripgrep;
      packages.aarch64-darwin.starship = pkgs.starship;
      packages.aarch64-darwin.zoxide = pkgs.zoxide;
    };
}