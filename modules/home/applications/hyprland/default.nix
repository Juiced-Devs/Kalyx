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

    clipboard = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    kalyx = {
      theming.cursor.enable = true;
    };
    #================#

    programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];

    home.packages = with pkgs; [
      (mkIf cfg.clipboard.enable wl-clipboard)
      (mkIf cfg.clipboard.enable wl-clip-persist)
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      
      settings = let
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
          "MOZ_DISABLE_WAYLAND_PROXY,1" # This is a temporary fix because firefox caused a 475GB file to be created on my system. https://bugzilla.mozilla.org/show_bug.cgi?id=1882449
          "MOZ_ENABLE_WAYLAND,1"
        ];

        exec = [
          (mkIf ((backend == "swaybg") && config.kalyx.theming.wallpaper.enable) "${pkgs.swaybg}/bin/swaybg -i ${config.kalyx.theming.wallpaper.image} -m fill")
          (mkIf cfg.clipboard.enable "wl-clip-persist --clipboard regular")
        ];

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
