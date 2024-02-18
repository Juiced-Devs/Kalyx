{
  description = "General purpose, easy to use base modules for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, self, ... }:
  rec {
    lib = import ./lib nixpkgs.lib;

    homeModulePaths = lib.collectModules ./modules/home;
    nixosModulePaths = lib.collectModules ./modules/nixos;

    nixosModule = { 
      home-manager.sharedModules = [{ imports = homeModulePaths; }];
      imports = nixosModulePaths;
    };
  };
}