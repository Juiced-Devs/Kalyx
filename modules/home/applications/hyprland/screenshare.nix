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
    assertions = [
      {
        assertion = !((lib.findSingle (x: x.primary) true false config.kalyx.monitors.monitors) == true);
        message = ''KALYX ERROR:
- You have no primary monitor set and you are attempting to use the Hyprland screenshare module please add primary=true to one of your monitors.
  Alternativly you can disable the screenshare patch by doing kalyx.hyprland.screenshare.enable = false;'';
      }
    ];

    wayland.windowManager.hyprland.settings = {
      bind = let
        startscreen = adapter: ''
          ${pkgs.wf-recorder}/bin/wf-recorder ${''-g "$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.name=="${adapter}") | .x'),$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.name=="${adapter}") | .y') $(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.name=="${adapter}") | .width')x$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.name=="${adapter}") | .height')"''} -c mpegts -x rgb24 --muxer=v4l2 --codec=rawvideo --file=/dev/video77 &
          sleep 1; SDL_VIDEODRIVER="x11" ${pkgs.ffmpeg-full}/bin/ffplay /dev/video77
        '';
      in [
        ''${cfg.toggleKeybind},exec,${pkgs.writeScript "screenshareRunner.sh" ''
          #!${pkgs.bash}/bin/bash
a
          if [[ $(ps -ef | pgrep -f "/dev/video77") ]]; then
            ps -ef | pgrep -f "/dev/video77" | xargs kill -9
          else
            ${startscreen (lib.strings.toUpper cfg.defaultMonitorAdapter )}
          fi
        ''}''
      ];
      windowrule = [
        "float,title:(/dev/video77)"
        "pin,title:(/dev/video77)"
        "nofocus,title:(/dev/video77)"
        "opacity 0.0,title:(/dev/video77)"
      ];
    };
  };
}