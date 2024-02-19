{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.NAME;
in
{
  options.kalyx.NAME = {
    enable = mkEnableOption "DESCRIPTION";
  };

  config = mkIf cfg.enable {
    
  };
}
