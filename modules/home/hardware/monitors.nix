###############################
#           WARNING           #
###############################

# Unless using only Home Manager or trying to configure an override for a specific user,
# you should probably use the Kalyx NixOS module for monitors as it makes these applications
# to all home environments, syncronizing the monitor config system wide.

{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  inherit (builtins)
    toString
    ;

  cfg = config.kalyx.monitors;
  mon = builtins.foldl' (acc: attrs: acc // attrs) {} ([ cfg.defaultMonitor ] ++ cfg.monitors);

  bitdepth = if mon.bitdepth != 8 then ",bitdepth,10" else "";
  mirror = if mon.mirror != null then ",mirror,${mon.mirror}" else "";
  position = if mon.position == "automatic" then "auto" else mon.position;

  resolution = if mon.resolution == "maxrefreshrate" then "highrr"
    else if mon.resolution == "maxresolution" then "highres"
    else if mon.resolution == "preffered" then mon.resolution
    else "${mon.resolution}@${toString mon.framerate}" # The assertion supplants checking `mon.framerate != null` here.
    ;

  rotation = let add = if mon.flipped then 4 else 0; mr = mon.rotation; in (
    if mr == 0 then (toString (add + 0))
    else if mr == 90 then (toString (add + 1))
    else if mr == 180 then (toString (add + 2))
    else if mr == 270 then (toString (add + 3))
    else "0"
  );
in
{
  # TODO: add automatic TTY adjustments.
  options.kalyx.monitors = {
    disableWarning = mkEnableOption "Disable the 'you should be using the Nixos module' warning";

    monitors = mkOption {
      type = types.listOf types.attrs;
      default = [ /* This option shares a value with the nixos `monitors` option. */ ];
    };

    defaultMonitor = mkOption {
      description = ''Set options for all monitors plugged in but not configured.'';
      type = types.attrs;
      default = {
        resolution = "preffered";
        position = "automatic";
      };
    };
  };

  config = {
    warnings =
      if (!(cfg.disableWarning) && cfg.monitors != [])
      then [ ''
        KALYX WARNING:
       - You should be using the Kalyx NixOS module to declare monitor configs. It will automatically sync the home module.
       - Only configure monitors from the Home Manager scope if you are trying to override per user.
       - Use ``kalyx.monitors.disableWarning = true;`` to disable this warning.
       '' ]
      else [];
    
    assertions = [
      {
        # Check for multiple monitors being set as primary.
        assertion = !((lib.findSingle (x: x.primary) false true cfg.monitors) == true);
        message = ''
          KALYX ERROR:
          You have two primary monitors set! please remove one.
        '';
      }
      {
        # Check if refreshRate is unset, and error when using a manual resolution
        assertion = (builtins.any (bool: bool == true) (if mon.framerate == null then map (res: res == mon.resolution) [ "maxresolution" "maxrefreshrate" "preffered" ] else [true]));
        message = ''
          KALYX ERROR:
          Manual screen resolution requires setting a refresh rate.
        '';
      }
    ];

    # Hyprland
    wayland.windowManager.hyprland.settings = {
      monitor = if mon.disable then "${mon.adapter},disable" else
        "${mon.adapter},${resolution},${position},${toString mon.scale},transform,${rotation}${mirror}${bitdepth}"
        ;

      workspace = if mon.disable then []
        else map (ws: "${toString ws},monitor:${mon.adapter},default:${if ws == mon.defaultWorkspace then "true" else "false"}") mon.workspaces
        ;

      exec-once = [ (let mon = lib.findSingle (x: x.primary) false false cfg.monitors; in if mon != false then "xrandr --output ${mon.adapter} --primary" else "") ];
    };

    kalyx.hyprland.screenshare.defaultMonitorAdapter = let mon = lib.findSingle (x: x.primary) false false cfg.monitors; in if mon != false then mon.adapter else null;
  };
}
