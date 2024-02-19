{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.gpu;
in
{
  options.kalyx.gpu = {
    enable = mkEnableOption "graphics";
  };

  config = mkIf cfg.enable {
    hardware.opengl = {
      driSupport = true;
      driSupport32Bit = true;
      enable = true;
    };
  };
}
