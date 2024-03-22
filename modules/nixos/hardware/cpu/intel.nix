{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.kalyx.intel;
in
{
  options.kalyx.intel = {
    enable = mkEnableOption "intel";
    noPowerManagement = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    boot.kernelParams = mkIf cfg.noPowerManagement [ "i915.enable_dc=0" "intel_idle.max_cstate=1" "intel_pstate=disable" ];
    hardware.enableRedistributableFirmware = true;
  };
}
