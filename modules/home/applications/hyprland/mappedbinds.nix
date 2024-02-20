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
        type = with types; attrsOf (funtionTo (functionTo str));
      };
    };
  };

  mapBind = (bindMap: binds:
    let
      concatMapAttrsToList = f: a: lib.concatLists (mapAttrsToList f a);
    in
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
    mappedBinds = {
      type = types.attrsOf mappedBindSubmodule;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings = {
        bind = mapAttrsToList (_: v: mapBind v.bindMap v.binds) cfg.mappedBinds;
      };
    };
  };
}