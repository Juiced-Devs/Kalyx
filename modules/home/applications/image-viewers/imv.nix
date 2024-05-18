{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  
  desktop_item = pkgs.makeDesktopItem {
    name = "imv";
    exec = "imv";
    desktopName = "imv";
    categories = [ "Viewer" ];
  };

  defaultAttrset = {
    "image/png" = [ "${desktop_item}" ]; 
    "image/jpg" = [ "${desktop_item}" ]; 
  };

  cfg = config.kalyx.imv;
in
{
  options.kalyx.imv = {
    enable = mkEnableOption "Install file roller with Kalyx functionallity";
    default = mkEnableOption "Set imv as the default.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      imv
    ];
      
    xdg.mimeApps = { 
      enable = true; #
      associations.added = defaultAttrset;
      defaultApplications = mkIf cfg.default defaultAttrset;
    };
  };
}
