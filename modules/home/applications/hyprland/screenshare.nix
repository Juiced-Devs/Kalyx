{ config
, lib
, pkgs
, inputs
, ...
}:
let
  inherit (lib)
    mapAttrsToList
    mkIf
    mkOption
    types
    ;

  cfg = config.kalyx.hyprland.screenshare;
in
{
  options.kalyx.hyprland.screenshare = {
    enable = mkOption {
      type = types.bool;
      default = true;
    }; 
    toggleKeybind = mkOption {
      type = types.nullOr types.str;
      default = "SUPER SHIFT, A";
    };
    defaultMonitorAdapter = mkOption { 
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = mkIf (cfg.enable && config.kalyx.hyprland.enable) {
    wayland.windowManager.hyprland.settings = {
      bind = [
        ''${cfg.toggleKeybind},exec,${pkgs.writeScript "screenshareRunner.sh" ''
          ${pkgs.wf-recorder}/bin/wf-recorder ${if cfg.defaultMonitorAdapter != null then ''-g "${cfg.defaultMonitorAdapter}"'' else ""} -x yuv420p --muxer=v4l2 --codec=rawvideo --file=/dev/video77 &
          sleep 1; ${pkgs.ffmpeg-full}/bin/ffplay /dev/video77
        ''}''
        # ''${cfg.toggleKeybind},exec,''
      ];
      windowrule = [
        "float,title:(/dev/video77)"
      ];
    };
  };
}