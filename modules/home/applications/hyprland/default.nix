{ config
, lib
, pkgs
, inputs
, ...
}:
let
  inherit (lib)
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (builtins)
    toString
    ;

  cfg = config.kalix.hyprland;

  mappedBindSubmodule = types.submodule {
    options = {
      bindMap = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };
      
      binds = {
        type = types.attrsOf (types.functionTo types.str);
        default = { };
      };
    };
  };
in
{
  options.kalix.hyprland = {
    enable = mkEnableOption "Hyprland";

    mappedBinds = mkOption {
      type = types.attrsOf mappedBindSubmodule;
      default = [ ];
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      inherit (cfg) extraConfig;

      settings =
        let
          md = cfg.modKey;

          concatMapAttrsToList = f: a: lib.concatLists (mapAttrsToList f a);

          mapBind = (bindMap: binds:
            (concatMapAttrsToList
              (x: y:
                (mapAttrsToList
                  (_: b: b x y)
                  binds))
              bindMap));
        in
        {
          bind = concatMapAttrsToList (_: mb: mapBind mb.bindMap mb.binds) cfg.mappedBinds;
        };
    };
  };
}