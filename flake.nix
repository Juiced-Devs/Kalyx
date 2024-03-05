{
  description = "General purpose, easy to use base modules for NixOS";

  inputs = { };

  outputs = inputs@{ nixpkgs, self, ... }:
  rec {
    kalyxlib = import ./lib nixpkgs.lib;
    specialArgs = { inherit kalyxlib; };

    homeModulePaths = kalyxlib.collectModules ./modules/home;
    nixosModulePaths = kalyxlib.collectModules ./modules/nixos;

    homeManagerModules = {
      imports = homeModulePaths;
    };

    nixosModules = { 
      imports = nixosModulePaths;
    };
  };
}