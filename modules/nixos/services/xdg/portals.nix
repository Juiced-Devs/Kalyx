{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  hyprlandInUse = (lib.any (user: user.kalyx.hyprland.enable) (lib.attrValues config.home-manager.users));
  
  homeModuleNeedsPortals = (lib.any (currentelm: currentelm == true) [
    # v v v DE/WM's that need ANY KIND OF portals here. v v v

    # If any user has Hyprland enabled.
    hyprlandInUse
  ]);

  homeModuleNeedsWLRPortalCompositor = (lib.any (currentelm: currentelm == true) [
    # v v v DE/WM's that need the wlr portal here. v v v
  ]);

  cfg = config.kalyx.xdg.portal;
in
{
  options.kalyx.xdg.portal = {
    enable = mkOption {
      type = types.bool;
      default = homeModuleNeedsPortals;
    };

    defaultPortal = mkOption {
      type = types.enum [ "gtk" "kde" ];
      default = "gtk";
    };
    
    useHyprlandPortalInsteadOfWLR = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    kalyx = { };
    #================#
    
    xdg.portal = {
      enable = true;
      config = {
        common = {
          default = [ cfg.defaultPortal ];
        };
      };
      wlr = {
        enable = (homeModuleNeedsWLRPortalCompositor || (!(cfg.useHyprlandPortalInsteadOfWLR) && hyprlandInUse));
        # settings = {
        #   screencast = {
        #     max_fps = 30;
        #     chooser_type = "simple";
        #     chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        #   };
        # };
      };
      extraPortals = with pkgs; [
        (mkIf (cfg.defaultPortal == "gtk") xdg-desktop-portal-gtk)
        (mkIf (cfg.defaultPortal == "kde") xdg-desktop-portal-kde)
        (mkIf (hyprlandInUse && cfg.useHyprlandPortalInsteadOfWLR) xdg-desktop-portal-hyprland)
      ];
    };
  };
}
