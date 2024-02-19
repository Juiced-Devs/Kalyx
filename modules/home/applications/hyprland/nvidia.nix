{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.hyprland.nvidia;
in
{
  options.kalyx.hyprland.nvidia = {
    enable = mkEnableOption "DESCRIPTION";
  };

  config = mkIf cfg.enable {
    
  };
}
