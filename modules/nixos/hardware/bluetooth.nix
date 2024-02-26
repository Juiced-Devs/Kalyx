{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.kalyx.bluetooth;
in
{
  options.kalyx.bluetooth = {
    enable = mkEnableOption "Bluetooth";
    mediaControls = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    systemd.user.services.mpris-proxy = mkIf cfg.mediaControls {
      description = "Mpris proxy";
      after = [ "network.target" "sound.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };
  };
}