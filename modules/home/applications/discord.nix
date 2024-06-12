{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.kalyx.discord;
in
{
  options.kalyx.discord = {
    enable = mkEnableOption "discord";
    vencordPatch = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = let 
      discordpkg = (pkgs.discord.override {
        withOpenASAR = false;
        withVencord = cfg.vencordPatch;
        withTTS = false; # This is terrible and messes with your audio system if on pipewire.
      });
    in [
      (discordpkg.overrideAttrs (oldAttrs: rec {
        desktopItem = oldAttrs.desktopItem.override {exec = "XDG_SESSION_TYPE=x11 discord";};
        installPhase = builtins.replaceStrings ["${oldAttrs.desktopItem}"] ["${desktopItem}"] oldAttrs.installPhase;
      }))

      pkgs.vesktop
    ];
  };
}
