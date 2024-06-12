{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.branding;
  kalyxSvg = config.kalyx.neofetch.image.kalyxSvg;
in
{
  options.kalyx.branding = {
    enable = mkEnableOption "Enable Kalyx branding";
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
          # Set distro name based on nixpkgs version and system architecture.
          # (i.e. "Kalyx [Nixos 24.05] x86_64-linux")
          distroName = lib.mkDefault "Kalyx [Nixos ${config.system.nixos.release}] ${config.nixpkgs.hostPlatform.system}";
          asciiColors = lib.mkDefault "11 3 10 2";
          image = {
            source = lib.mkDefault ./kalyx-ansii;
            size = mkIf kalyxSvg lib.mkDefault "320px";
          };
        };
      };
    }];
    #================#
  };
}
