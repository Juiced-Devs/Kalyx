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
    home.packages = with pkgs; [
      (mkIf cfg.vencordPatch (discord.override {
        withOpenASAR = true;
        withVencord = true;
        withTTS = false; # This is terrible and messes with your audio system if on pipewire.
      }))
      (mkIf (cfg.vencordPatch == false) discord)
    ];
  };
}
