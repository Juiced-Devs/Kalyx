{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.sound;
in
{
  options.kalyx.sound = {
    enable = mkEnableOption "DESCRIPTION";
    soundServer = mkOption {
      type = types.enum [ "pulse" "pipewire" ];
      default = "pipewire";
    };
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    kalyx = { };
    #================#
    sound.enable = true;
    
    environment.systemPackages = with pkgs; [
      pavucontrol
    ];

    hardware.pulseaudio = mkIf (cfg.soundServer == "pulse") {
      enable = true;
      package = pkgs.pulseaudioFull; # Install all the codecs for pulseaudio.
    };

    kalyx.pipewire.enable = (cfg.soundServer == "pipewire"); 
    services.pipewire = mkIf (cfg.soundServer == "pipewire") {
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
