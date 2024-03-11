{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  
  #=# HOME MANAGER DEPS #=#
  homeHyprlandEnabled = (lib.any (currentelm: currentelm == true) [ # If any of the elements in the list is true, this will be true.
    (lib.any (user: user.kalyx.hyprland.enable) (lib.attrValues config.home-manager.users))
  ]);
  #=======================#

  cfg = config.kalyx.home-compatability.hyprland;
in
{
  options.kalyx.home-compatability.hyprland = {
    enable = mkOption {
      type = types.bool;
      default = homeHyprlandEnabled;
    };
  };

  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
    };
  };
}
