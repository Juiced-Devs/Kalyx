### WARNING ###
# Unless you are trying to set a wallpaper for a specific user or you are using Home Manager without NixOS
# you should set your wallpaper in the NixOS. The Kylix system themer integration will use the wallpaper in the NixOS module if enabled.
###############

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

  config = mkIf cfg.enable { };
}
