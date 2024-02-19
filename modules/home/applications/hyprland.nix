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

    extraConfig = mkOption {
      type = types.lines;
      default = "";
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

        xwayland = {
          force_zero_scaling = true;
        };
      };
    };
  };
}