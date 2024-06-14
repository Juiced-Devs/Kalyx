{ config, inputs, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.kalyx.intelgpu;
in
{
  options.kalyx.intelgpu = {
	  enable = mkEnableOption "intelgpu";
  };

  config = mkIf cfg.enable {
    kalyx.gpu.enable = true;

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };

    hardware.opengl = {
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
}
