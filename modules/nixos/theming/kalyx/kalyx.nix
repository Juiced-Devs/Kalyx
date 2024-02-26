{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.branding;
in
{
  options.kalyx.branding = {
    enable = mkEnableOption "DESCRIPTION";
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    kalyx = { };

    home-manager.sharedModules = [{
      kalyx = { 
        neofetch = {
          imageSource = ./kalyx-ansii;
          distroName = "Kalyx";
          asciiColors = "11 3 10 2";
        };
      };
    }];
    #================#
  };
}
