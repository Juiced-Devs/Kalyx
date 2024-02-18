{
  description = "General purpose, easy to use base modules for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
  {
    lib = import ./lib nixpkgs.lib;

    nixosModule = import ./modules/nixos;
    homeManagerModule = import ./modules/home;
  };
}