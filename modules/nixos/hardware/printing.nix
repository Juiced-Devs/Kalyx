{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.printing;
in
{
  options.kalyx.printing = {
    enable = mkEnableOption "DESCRIPTION";
  };

  config = mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [ 
        hplipWithPlugin
        gutenprint
        gutenprintBin
        hplip
        hplipWithPlugin
        postscript-lexmark
        samsung-unified-linux-driver
        splix
        brlaser
        brgenml1lpr
        brgenml1cupswrapper
        cnijfilter2
      ];
    };
  };
}
