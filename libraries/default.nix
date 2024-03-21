_: { config, lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options.flake.homeModules = mkOption {
    type = types.attrs;
    default = { };
  };

  config.flake.lib = {
    combineModules = modules: builtins.attrValues (lib.filterAttrs (k: _: k != "default") modules);
  };
}