{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  
  cfg = config.kalyx.file-roller;
in
{
  options.kalyx.file-roller = {
    enable = mkEnableOption "Install file roller with Kalyx functionallity";
    default = mkEnableOption "Set file-roller as the default.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnome.file-roller
    ];
      
    xdg.mimeApps = { 
      enable = true;
      associations.added = {
        "application/zip" = [ "org.gnome.FileRoller.desktop" ]; 
      };
      defaultApplications = mkIf cfg.default {
        "application/zip" = [ "org.gnome.FileRoller.desktop" ];
      };
    };
  };
}
