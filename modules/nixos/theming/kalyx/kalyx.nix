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
    kalyx.theming = {
      wallpaper.enable = lib.mkDefault true;
      wallpaper.image = lib.mkDefault ../../../../res/wallpaper.png;
    };

    home-manager.sharedModules = [{
      kalyx = {
        neofetch = {
          enable = lib.mkDefault true;
          imageSource = lib.mkDefault ./kalyx-ansii;
          distroName = lib.mkDefault "Kalyx";
          asciiColors = lib.mkDefault "11 3 10 2";
        };
      };
    }];
    #================#
  };
}
