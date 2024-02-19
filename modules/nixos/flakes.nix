{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.kalyx.flakes;
in
{
  options.kalyx.flakes = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    nix.package = pkgs.nixFlakes;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.registry = builtins.mapAttrs (_: flake: { inherit flake; }) inputs;
  };
}