{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.theming;

  colors = types.submodule {
    options = { # All options here take a Hex code
      base00 = mkOption { 
        type = types.str;
      };

      base01 = mkOption { 
        type = types.str;
      };

      base02 = mkOption { 
        type = types.str;
      };

      base03 = mkOption { 
        type = types.str;
      };

      base04 = mkOption { 
        type = types.str;
      };

      base05 = mkOption { 
        type = types.str;
      };

      base06 = mkOption { 
        type = types.str;
      };

      base07 = mkOption { 
        type = types.str;
      };

      base08 = mkOption { 
        type = types.str;
      };

      base09 = mkOption { 
        type = types.str;
      };

      base0A = mkOption { 
        type = types.str;
      };

      base0B = mkOption { 
        type = types.str;
      };

      base0C = mkOption { 
        type = types.str;
      };

      base0D = mkOption { 
        type = types.str;
      };

      base0E = mkOption { 
        type = types.str;
      };

      base0F = mkOption { 
        type = types.str;
      };
    };
  };
in
{
  options.kalyx.theming = {
    colors = mkOption {
      type = types.nullOr colors;
      default = null;
    };

    autoEnable = mkEnableOption "Automatically enable all home theming and NixOS theming.";
  };

  config = {
    #=# KALYX DEPS #=#
    kalyx = { };

    home-manager.sharedModules = [{
      kalyx = {
        theming = {
          colors = lib.mkDefault cfg.colors;
          autoEnable = lib.mkDefault cfg.autoEnable;
        };
      };
    }];
    #================#
  };
}
