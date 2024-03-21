{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.scream;
in
{
  options.kalyx.scream = {
    enable = mkEnableOption "DESCRIPTION";

    firewallRule = mkOption {
      type = types.bool;
      default = true;
    };

    systemdService = mkOption {
      type = types.bool;
      default = true;
    };

    port = mkOption {
      type = types.int;
      default = 4010;
    };

    latency = mkOption {
      type = types.int;
      default = 50;
    };

    maxLatency = mkOption {
      type = types.int;
      default = 100;
    };

    unicast = mkEnableOption "Unicast mode in systemd service";
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.firewallRule {
      allowedTCPPorts = [cfg.port];
      allowedUDPPorts = [cfg.port];
    };

    environment.systemPackages = with pkgs; [
      scream
    ];

    systemd.user.services.scream = {
      enable = true;
      description = "Scream Audio Server";
      serviceConfig = {
          ExecStart = "${pkgs.scream}/bin/scream -v ${if cfg.unicast then "-u" else ""} -p ${builtins.toString cfg.port} -t ${builtins.toString cfg.latency} -l ${builtins.toString cfg.maxLatency}"; #TODO: add options for use outside of network mode.
          Restart = "always";
      };
      wantedBy = [ "default.target" ];
      requires = [ 
        (mkIf (config.kalyx.sound.soundServer == "pipewire") "pipewire-pulse.service")
        (mkIf (config.kalyx.sound.soundServer == "pulse") "pulseaudio.service")
      ];
    };
  };
}
