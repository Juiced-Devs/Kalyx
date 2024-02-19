{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.kalyx.amd;
in
{
  options.kalyx.amd = {
    enable = mkEnableOption "amd";
  };

  config = mkIf cfg.enable {
    # As of right now no AMD cpu fixes are required.
    boot.kernelParams = mkIf cfg.noPowerManagement[ ];
  };
}