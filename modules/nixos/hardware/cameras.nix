{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  # #=# HOME MANAGER DEPS #=#
  hyprlandScreenshare = (lib.any (currentelm: currentelm == true) [ # If any of the elements in the list is true, this will be true.
    (lib.any (user: user.kalyx.hyprland.screenshare.enable) (lib.attrValues config.home-manager.users))
  ]);
  hyprland = (lib.any (currentelm: currentelm == true) [ # If any of the elements in the list is true, this will be true.
    (lib.any (user: user.kalyx.hyprland.enable) (lib.attrValues config.home-manager.users))
  ]);
  # #=======================#

  cfg = config.kalyx.camera;
in
{
  options.kalyx.camera = {
    enable = mkEnableOption "";

    virtualCam = {
      enable = mkEnableOption "VirtualCam";
      camNumbers = mkOption {
        type = types.listOf types.int;
        default = [ 9 ];
      };
    };
  };

  config = mkIf (cfg.enable || cfg.virtualCam.enable || (hyprland && hyprlandScreenshare)) {
    kalyx.camera.virtualCam.camNumbers = mkIf hyprlandScreenshare [ 77 78 ];
    boot.kernelModules = lib.mkIf cfg.virtualCam.enable [ "v4l2loopback" ];
    boot.extraModulePackages = with config.boot.kernelPackages; [ ( lib.mkIf cfg.virtualCam.enable v4l2loopback) ];
    boot.extraModprobeConfig = lib.mkIf cfg.virtualCam.enable '' 
      options v4l2loopback exclusive_caps=1 video_nr=${lib.strings.concatStringsSep "," (map (x: builtins.toString x) cfg.virtualCam.camNumbers )} card_label=VirtualVideoDevice
    '';
  };
}
