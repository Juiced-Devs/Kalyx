{ config
, lib
, pkgs
, inputs
, ...
}:
let
  inherit (lib)
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (builtins)
    toString
    ;

  cfg = config.kalyx.hyprland;
in
{
  options.kalyx.hyprland = {
    enable = mkEnableOption "Hyprland";

    terminalEmulator = mkOption {
      type = types.str;
    };

    modKey = mkOption {
      type = types.str;
      default = "SUPER";
    };
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    kalyx = {
      cursor.enable = true;
    };
    #================#

    wayland.windowManager.hyprland = {
      enable = true;
      
      settings = let
        mod = cfg.modKey;
        backend = "swaybg";  # For now this is statically set as swaybg, I plan on making an auto configurator that selects
                             # the best backend for what you want to do. Lets say you want an animated wallpaper, theoretically the backend would choose swww.
      in {
        env = [
          "NIXOS_OZONE_WL,1"
          "wayland,x11"
          "QT_QPA_PLATFORM,wayland;xcb"
          "SDL_VIDEODRIVER,wayland"
          "CLUTTER_BACKEND,wayland"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
        ];

        exec = mkIf ((backend == "swaybg") && config.kalyx.wallpaper.enable) "${pkgs.swaybg}/bin/swaybg -i ${config.kalyx.wallpaper.image}";

        misc = {
          disable_hyprland_logo = true;
        };

        xwayland = {
          force_zero_scaling = true;
        };
      };
    };
  };
}
