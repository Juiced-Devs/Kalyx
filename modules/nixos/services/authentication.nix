{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.authentication;
in
{
  options.kalyx.authentication = {
    enable = mkEnableOption "Kalyx authentication module.";
    keyringToolkit = mkOption {
      type = types.enum [ "gnome" ];
      default = "gnome";
    };
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    kalyx = { };
    #================#
    
    # Gnome Keyring
    services.gnome.gnome-keyring = mkIf (cfg.keyringToolkit == "gnome") {
      enable = true;
    };
    
    # KWallet
    # security.pam.services.kwallet = mkIf (cfg.keyringToolkit == "kde") {
    #   name = "kwallet";
    #   enableKwallet = true;
    # };


    # GNUPG
    programs.gnupg = mkIf (cfg.keyringToolkit == "gnupg") {
      agent.enable = true;
      agent.enableBrowserSocket = true;
      agent.enableExtraSocket = true;
      agent.enableSSHSupport = true;
      agent.pinentryFlavor = if (cfg.keyringToolkit == "gnome") then "gnome3" else "qt";
    };

    services.yubikey-agent.enable = (cfg.keyringToolkit == "gnupg");
    programs.dconf.enable = true;
    programs.mtr.enable = true;

    # general
    services.dbus.packages = [ 
      (mkIf (cfg.keyringToolkit == "gnome") pkgs.gnome.gnome-keyring)
      (mkIf (cfg.keyringToolkit == "gnome") pkgs.gcr)
    ];

    programs.ssh = {
      startAgent = false;
    };
  };
}
