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
  };

  config = mkIf (cfg.enable && config.kalyx.hyprland.enable) {
    wayland.windowManager.hyprland.settings = {
      bind = [
        ''${cfg.toggleKeybind},exec,${pkgs.wf-recorder}/bin/wf-recorder -g "$(${pkgs.slurp}/bin/slurp -o)" --muxer=v4l2 --codec=rawvideo --file=/dev/video77 & sleep 1; ${pkgs.ffmpeg-full}/bin/ffplay /dev/video77}''
      ];
    };
  };
}