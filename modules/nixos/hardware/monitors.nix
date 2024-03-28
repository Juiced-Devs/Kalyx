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
      disable = mkOption { # This will ignore ALL other options that are set and will simply disable this monitor.
        type = types.bool;
        default = false;
      };

      adapter = mkOption {
        type = types.nullOr types.str; # This is the name of your display port "DP-X", "HDMI-A-X", etc. You can get the adapter by using wlr-randr.
        default = null;
      };

      resolution = mkOption {
        type = types.str;
        default = "preffered"; # This can be 'maxrefreshrate', 'maxresolution', 'preffered' or a specific resolution such as '1920x1080' 
      };                       # if you specify a verbatum monitor resolution you need to set a framerate.

      framerate = mkOption {
        type = types.nullOr types.int;
        default = null;
      };

      primary = mkEnableOption "Set this monitor as the default";

      position = mkOption {
        type = types.str;
        default = "automatic"; # This can be 'automatic' or '0x0' where the first 0 is the x position and the second is the y.
      };                       # TODO: add functionality for 'leftof DP-X', 'rightof DP-X', etc.

      mirror = mkOption {
        type = types.nullOr types.str; # If you set this to the name of a display it will mirror that display, this and useVirtualMonitorProxy cannot be used together.
        default = null;
      };

      scale = mkOption {
        type = types.int;
        default = 1; # For HIDPI monitors, this will scale the size of the UI elements.
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
        type = types.enum [ 8 10 ]; # Allows you to change the bitdepth
        default = 8;
      };

      flipped = mkEnableOption "Flip Monitor"; # This will flip the monitor horizontally making a 'mirrored' effect, e.g text will be backwards and unreadable.

      useVirtualMonitorProxy = mkEnableOption "Create a virtual display and cast that to this display."; # TODO: Impliment this.
    };
  };

  cfg = config.kalyx;
in
{
  # TODO: add automatic TTY adjustments.
  options.kalyx = {
    monitors = mkOption {
      type = types.listOf monitorSubmodule;
      default = [
        # See submodule above for configuration options.
      ];
    };
    defaultMonitor = mkOption { # This sets the options for all monitors plugged in but not specified.
      type = monitorSubmodule;  # It takes the same options as regular monitors but the adapter, and workspace options do nothing.
      default = {
        resolution = "preffered";
        position = "automatic";
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = !((lib.findSingle (x: x.primary) false true cfg.monitors) == true);
        message = ''KALYX ERROR:
- You have two primary monitors set! please remove one.'';
      }

      {
        assertion = !((lib.findSingle (x: x.adapter == null) false true cfg.monitors) == true);
        message = ''KALYX ERROR:
- You created a monitor without an adapter set.'';
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
    [{ # something
      kalyx.monitors.disableWarning = lib.mkDefault (cfg.monitors != []);
      kalyx.monitors.monitors = monitorList;
      kalyx.monitors.defaultMonitor = defaultMon;
    }];
    #=========================#
  };
}
