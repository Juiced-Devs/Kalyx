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

  cfg = config.kalyx.monitors;
in
{
  # TODO: add automatic TTY adjustments.
  options.kalyx.monitors = {
    disableWarning = mkEnableOption "Disable the 'you should be using the Nixos module' warning";
    monitors = mkOption {
      type = types.listOf types.attrs;
      default = [
        # Read submodule in Nixos module for configuration options.
      ];
    };
    defaultMonitor = mkOption { # This sets the options for all monitors plugged in but not specified.
      type = types.attrs;  # It takes the same options as regular monitors but the adapter, and workspace options do nothing.
      default = {
        resolution = "preffered";
        position = "automatic";
      };
    };
  };

  config = {
    warnings =
      if (!(cfg.disableWarning) && cfg.monitors != [])
      then [ ''KALYX WARNING: 
       - You should be using the Kalyx NixOS module to declare monitor configs. It will automatically sync the home module.
       - Only configure monitors from the Home Manager scope if you are trying to override per user.
       - Use ``kalyx.monitors.disableWarning = true;`` to disable this warning.'' ]
      else [];
    
    assertions = [
      {
        assertion = !((lib.findSingle (x: x.primary) false true cfg.monitors) == true);
        message = ''KALYX ERROR:
- You have two primary monitors set! please remove one.'';
      }
    ];

    # Hyprland
    wayland.windowManager.hyprland.settings = {
      monitor = map (mon: if mon.disable then "${if mon.adapter != null then mon.adapter else ""},disable" else "${if mon.adapter != null then mon.adapter else ""},${if mon.resolution == "maxrefreshrate" then "highrr" else if mon.resolution == "maxresolution" then "highres" else mon.resolution}${if (mon.resolution != "preffered" &&  mon.resolution != "maxresolution" && mon.resolution != "maxrefreshrate" && mon.framerate != null) then "@${builtins.toString mon.framerate}" else ""},${if mon.position == "automatic" then "auto" else mon.position},${builtins.toString mon.scale},transform,${let add = if mon.flipped then 4 else 0; mr = mon.rotation; in (if mr == 0 then (builtins.toString (add + 0)) else if mr == 90 then (builtins.toString (add + 1)) else if mr == 180 then (builtins.toString (add + 2)) else if mr == 270 then (builtins.toString (add + 3)) else "0")}${if mon.mirror != null then ",mirror,${mon.mirror}" else ""}${if mon.bitdepth != 8 then ",bitdepth,10" else ""}") ([ cfg.defaultMonitor ] ++ cfg.monitors);
      workspace = lib.concatLists (map (mon: if mon.disable then [] else map (ws: "${builtins.toString ws},monitor:${mon.adapter},default:${if ws == mon.defaultWorkspace then "true" else "false"}") mon.workspaces) cfg.monitors);
      exec-once = [ (let mon = lib.findSingle (x: x.primary) false false cfg.monitors; in if mon != false then "xrandr --output ${mon.adapter} --primary" else "") ];
    };

    kalyx.hyprland.screenshare.defaultMonitorAdapter = let mon = lib.findSingle (x: x.primary) false false cfg.monitors; in if mon != false then mon.adapter else null;
  };
}
