{
  description = "General purpose, easy to use base modules for NixOS";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
      (toplevel@ {config, flake-parts-lib, ...}: #
      let
        inherit (flake-parts-lib) importApply;

        flakeModules = {
          home-manager = importApply ./modules/home toplevel;
          nixos = importApply ./modules/nixos toplevel;
          libraries = importApply ./libraries toplevel;
        };
      in {
        imports = with flakeModules; [
          home-manager
          nixos
          libraries
        ];

        flake = {
          inherit flakeModules;
          adminGroups = [ "libvirtd" ];
          universalGroups = [];
        };
      });
}
