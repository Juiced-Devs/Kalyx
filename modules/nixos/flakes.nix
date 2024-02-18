{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.kalix.flakes;
in
{
  options.kalix.flakes = {
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