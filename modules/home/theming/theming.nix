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

  basecolors = types.enum [ "base00" "base01" "base02" "base03" "base04" "base05" "base05" "base06" "base07" "base08" "base09" "base0A" "base0B" "base0C" "base0D" "base0E" "base0F" ];
in
{
  options.kalyx.theming = {
    colors = mkOption {
      type = types.nullOr colors;
      default = null;
    };

    autoEnable = mkEnableOption "Automatically enable all home theming and NixOS theming.";
  };

  config = let
    verifyHexColor = clr: (if lib.strings.hasInfix "#" clr then clr else "#${clr}");
    mapColorHex = clr: verifyHexColor (lib.attrsets.attrByPath [clr] null cfg.colors);
  in
  {
    kalyx = {

    };
  };
}
