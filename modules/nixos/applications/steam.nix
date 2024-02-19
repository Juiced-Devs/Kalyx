{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.NAME;
in
{
  options.kalyx.NAME = {
    enable = mkEnableOption "DESCRIPTION";
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    kalyx = { };
    #================#
    
    programs.steam = {
      enable = true;
      package = pkgs.steam-small.override {
        extraEnv = {
          MANGOHUD = true;
          OBS_VKCAPTURE = true;
          RADV_TEX_ANISO = 16;
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
