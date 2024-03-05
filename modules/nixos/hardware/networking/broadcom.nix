{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.broadcom;
in
{
  options.kalyx.broadcom = {
    enable = mkEnableOption "Broadcom driver support";
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  };
}
