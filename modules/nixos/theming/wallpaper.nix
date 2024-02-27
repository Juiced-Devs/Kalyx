# TODO: I plan on making this module much more feature rich, mainly adding support for animated toggles, per monitor config, and crop control.
{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.wallpaper;
in
{
  options.kalyx.wallpaper = {
    enable = mkEnableOption "Wallpaper";

    image = mkOption {
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    home-manager.sharedModules = [{
      kalyx = {
        wallpaper.enable = lib.mkDefault true;
        wallpaper.image = lib.mkDefault cfg.image;
      };
    }];
    #================#
  };
}
