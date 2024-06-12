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
    services.xserver.enable = true;
    hardware.enableRedistributableFirmware = true;    

    hardware.opengl = {
      setLdLibraryPath = true;
      driSupport = true;
      driSupport32Bit = true;
      enable = true;
    };
  };
}
