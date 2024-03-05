{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.steam;
in
{
  options.kalyx.steam = {
    enable = mkEnableOption "Steam";
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    kalyx = { };
    #================#
    
    # Enable Steam hardware (Steam Controller, HTC Vive, etc...)
    hardware.steam-hardware.enable = true;

    programs.steam = {
      enable = true;
      package = pkgs.steam-small.override {
        extraEnv = {
          MANGOHUD = true;
          OBS_VKCAPTURE = true;
        };
        extraLibraries = p: with p; [
          atk
        ];
      };
    };

    # Home Manager fixes.
    home-manager.sharedModules = [{
      
      # Hyprland steam dropdown menu fix.
      wayland.windowManager.hyprland.settings = {
        windowrulev2 = [
          "stayfocused, title:^()$,class:^(steam)$"
          "minsize 1 1, title:^()$,class:^(steam)$"
        ];
      };
    }];
  };
}
