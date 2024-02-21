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
  inherit (builtins)
    toString
    ;

  mappedBindSubmodule = types.submodule {
    options = {
      bindMap = {
        type = with types; attrsOf str;
      };
      binds = {
        type = with types; attrsOf (functionTo (functionTo str));
      };
    };
  };

  concatMapAttrsToList = f: a: lib.concatLists (mapAttrsToList f a);

  mapBind = (bindMap: binds:
    (concatMapAttrsToList
      (x: y:
        (mapAttrsToList
          (_: b: b x y)
          binds))
      bindMap));

  cfg = config.kalyx.hyprland;
in
{
  options.kalyx.hyprland = {
    mappedBinds = mkOption {
      type = types.attrsOf mappedBindSubmodule;
      default = { };
    };
  };

  config = mkIf (cfg.mappedBinds != { }) {
    wayland.windowManager.hyprland = {
      settings = {
        bind = concatMapAttrsToList (_: v: mapBind v.bindMap v.binds) cfg.mappedBinds;
      };
    };
  };
}