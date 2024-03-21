# TODO: I plan on making this module much more feature rich, mainly adding support for animated toggles, per monitor config, and crop control.
{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.theming.wallpaper;
in
{
  options.kalyx.theming.wallpaper = {
    enable = mkEnableOption "Wallpaper";

    image = mkOption {
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    home-manager.sharedModules = [{
      kalyx.theming = {
        wallpaper.enable = lib.mkDefault true;
        wallpaper.image = lib.mkDefault cfg.image;
      };
    }];
    #================#
  };
}
