{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  
  #=# HOME MANAGER DEPS #=#
  homeModuleAOrBEnabled = (lib.any (currentelm: currentelm == true) [ # If any of the elements in the list is true, this will be true.
    # If any user has A enabled.
    (lib.any (user: user.kalyx.A.enable) (lib.attrValues config.home-manager.users))
    # If any user has B enabled.
    (lib.any (user: user.kalyx.B.enable) (lib.attrValues config.home-manager.users))
  ]);
  #=======================#

  cfg = config.kalyx.NAME;
in
{
  options.kalyx.NAME = {
    enable = mkEnableOption "DESCRIPTION";
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    kalyx = { };

    home-manager.sharedModules = [{
      kalyx = { };
    }];
    #================#
  };
}
