{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalix.hyprland.nvidia;
in
{
  options.kalix.hyprland.nvidia = {
    enable = mkEnableOption "DESCRIPTION";
  };

  config = mkIf cfg.enable {
    
  };
}
