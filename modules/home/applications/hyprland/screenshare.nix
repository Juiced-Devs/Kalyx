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
    changeMonitorKeybind = mkOption {
      type = types.nullOr types.str;
      default = "SUPER SHIFT, S";
    };
    defaultMonitorAdapter = mkOption { 
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = mkIf (cfg.enable && config.kalyx.hyprland.enable) {
    wayland.windowManager.hyprland.settings = {
      bind = let
        genscreenparams = adapter: ''"$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.name=="${adapter}") | .x'),$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.name=="${adapter}") | .y') $(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.name=="${adapter}") | .width')x$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.name=="${adapter}") | .height')"'';
        startscreen = screenparams: ''
          ${pkgs.wf-recorder}/bin/wf-recorder -g ${screenparams} -c mpegts -x rgb24 --muxer=v4l2 --codec=rawvideo --file=/dev/video77 &
          sleep 1; SDL_VIDEODRIVER="x11" ${pkgs.ffmpeg-full}/bin/ffplay /dev/video77 -probesize 500M -analyzeduration 500M
        '';
      in [
        ''${cfg.toggleKeybind},exec,${pkgs.writeScript "screenshareRunner.sh" ''
          #!${pkgs.bash}/bin/bash

          if [[ $(ps -ef | pgrep -f "/dev/video77") ]]; then
            ps -ef | pgrep -f "/dev/video77" | xargs kill -9
          else
            ${if !((lib.findSingle (x: x.primary) true false config.kalyx.monitors.monitors) == true) then
                startscreen (genscreenparams (lib.strings.toUpper cfg.defaultMonitorAdapter))
              else
                ''export KALYX_SCREEN_NAME_TMP=$(${pkgs.slurp}/bin/slurp -o); ${startscreen ''"$KALYX_SCREEN_NAME_TMP"''}''}
          fi
        ''}''

        ''${cfg.changeMonitorKeybind},exec,${pkgs.writeScript "screenshareRunner.sh" ''
          #!${pkgs.bash}/bin/bash

          if [[ $(ps -ef | pgrep -f 'wf-recorder.*\/dev\/video77') ]]; then
            ps -ef | pgrep -f 'wf-recorder.*\/dev\/video77' | xargs kill -9
            export KALYX_SCREEN_NAME_TMP=$(${pkgs.slurp}/bin/slurp -o); ${startscreen ''"$KALYX_SCREEN_NAME_TMP"''}
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