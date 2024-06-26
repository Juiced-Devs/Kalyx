{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  # Kalyx allows you to configure your monitors without limits, these monitor settings will apply on any DE/WM that Kalyx supports.
  # Finally! A standardized monitor system where I don't gotta mess with my configs every time I try a new WM.
  # These changes apply to home manager and nixos, meaning you can setup your TTY's to follow your monitor configuration automatically.
  monitorSubmodule = types.submodule {
    options = {
      disable = mkEnableOption "Disable the monitor.";
      flipped = mkEnableOption "Flip the monitor horizontally."; # TODO: Warn when using (cursed).
      primary = mkEnableOption "Set this monitor as the default";
      useVirtualMonitorProxy = mkEnableOption "Create a virtual display and cast that to this display."; # TODO: Implement this.

      adapter = mkOption {
        type = types.str;
        default = "";
      };

      resolution = mkOption {
        description = ''
          Set the display resolution.

          Accepted values are "maxrefreshrate", "maxresolution",
          "preffered", or a specified pixel ratio, such as "1920x1080".
        '';
        type = types.str;
        default = "preffered";
      };

      framerate = mkOption {
        type = types.nullOr types.int;
        default = null;
      };


      position = mkOption {
        description = ''
          Set the monitor's position.

          Accepted values are 'automatic' or XY coordinates (i.e 0x0, 1920x1080)
        '';
        type = types.str;
        default = "automatic"; # TODO: add functionality for 'leftof DP-X', 'rightof DP-X', etc.
      };

      mirror = mkOption {
        description = ''Mirror the specified display.'';
        type = types.nullOr types.str;
        default = null;
      };

      scale = mkOption {
        type = types.int;
        default = 1;
      };

      rotation = mkOption {
        type = types.enum [ 0 90 180 270 ];
        default = 0;
      };

      workspaces = mkOption {
        type = types.listOf types.int;
        default = [];
      };

      defaultWorkspace = mkOption {
        type = types.nullOr types.int;
        default = null;
      };

      bitdepth = mkOption {
        type = types.enum [ 8 10 ];
        default = 8;
      };
    };
  };

  cfg = config.kalyx;
  # Remove the list surrounding cfg.monitors
  mon = builtins.foldl' (acc: attrs: acc // attrs) {} cfg.monitors;
in
{
  # TODO: add automatic TTY adjustments.
  options.kalyx = {
    monitors = mkOption {
      type = types.listOf monitorSubmodule;
      default = [ /* See submodule above for configuration options. */ ];
    };

    defaultMonitor = mkOption {
      description = ''Set options for all monitors plugged in but not configured.'';
      type = monitorSubmodule;
      default = {
        resolution = "preffered";
        position = "automatic";
      };
    };
  };

  config = {
    assertions = [
      {
        # Check for multiple monitors being set as primary.
        assertion = !(lib.findSingle (x: x.primary) false true cfg.monitors);
        message = ''
          KALYX ERROR:
          More than one primary monitor was set.
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

    #=# KALYX DEPS #=#
    kalyx = { };
    #================#
    
    #=# GLOBAL HOME MANAGER #=#
    home-manager.sharedModules = let
      monitorList = cfg.monitors;
      defaultMon = cfg.defaultMonitor;
    in
    [{
      kalyx.monitors.disableWarning = lib.mkDefault (cfg.monitors != []);
      kalyx.monitors.monitors = monitorList;
      kalyx.monitors.defaultMonitor = defaultMon;
    }];
    #=========================#
  };
}
