{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  
  cfg = config.kalyx.thunar;
in
{
  options.kalyx.thunar = {
    enable = mkEnableOption "Install thunar.";

    default = mkEnableOption "Set thunar as default fm.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xfce.thunar
    ];

    xdg.mimeApps = { 
      enable = true;
      associations.added = {
        "inode/directory" = [ "thunar.desktop" ]; 
      };
      defaultApplications = mkIf cfg.default {
        "inode/directory" = [ "thunar.desktop" ];
      };
    };
  };
}
