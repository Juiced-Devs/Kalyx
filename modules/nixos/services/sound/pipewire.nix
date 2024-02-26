{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.pipewire;
in
{
  options.kalyx.pipewire = {
    enable = mkEnableOption "Pipewire Kalyx";
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    kalyx = { };
    #================#

    services.pipewire = {
      enable = true;
    };

    # The current lack of extra configuration is temporary as I have multiple pipewire modules I want to integrate
  };
}
