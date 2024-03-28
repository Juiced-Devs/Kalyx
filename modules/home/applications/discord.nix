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
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # nixpkgs.overlays =
    # [ (final: prev: let
    #     mkDiscord = args: pkgs.symlinkJoin {
    #       name = "discord";
    #       paths = [
    #         prev.discord
    #         (pkgs.writeShellScriptBin "discord" "echo hi")
    #       ];
    #     };
    #   in {
    #     discord = mkDiscord commandLineArgs;
    #   })
    # ];

    home.packages = let 
      discordpkg = if cfg.vencordPatch then (pkgs.discord.override {
        withOpenASAR = true;
        withVencord = true;
        withTTS = false; # This is terrible and messes with your audio system if on pipewire.
      }) else pkgs.discord;
    in [
      (discordpkg.overrideAttrs (oldAttrs: rec {
        desktopItem = oldAttrs.desktopItem.override {exec = "XDG_SESSION_TYPE=x11 discord";};
        installPhase = builtins.replaceStrings ["${oldAttrs.desktopItem}"] ["${desktopItem}"] oldAttrs.installPhase;
      }))
    ];
  };
}
