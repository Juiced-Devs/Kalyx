{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    mkMerge
    ;

  cfg = config.kalyx.nvidia;
in
{
  options.kalyx.nvidia = {
    enable = mkEnableOption "Nvidia";
    proprietary = mkOption { type = types.bool; default = true; };
    
    # GTX 1650 AND NEWER ONL
    openkernel = mkEnableOption "Open Driver";

    cuda = mkEnableOption "Cuda";

    waylandFixups = mkEnableOption "Nvidia Wayland Fixups";
  };

  config = mkIf cfg.enable {
    kalyx.gpu.enable = true;

    boot = {
      initrd.kernelModules = [
        "vfio"
        "vfio_pci"
      ] ++ (if cfg.proprietary then [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ] 
      else [
        "nouveau"
      ]);
      kernelParams = [] ++ (if cfg.proprietary then [
	      "video=vesafb:off,efifb:off"
      ] else []);
    };

    environment.systemPackages = with pkgs; [] ++ (if cfg.proprietary then [
      egl-wayland
      libva-utils
      nvidia-vaapi-driver
    ] else []);

    hardware.opengl.extraPackages = with pkgs; [] ++ (if cfg.proprietary then [
      vaapiVdpau
      libvdpau-va-gl

      # Test
      nvidia-vaapi-driver
    ] else [
      mesa
      libGL
    ]);

    hardware.opengl.setLdLibraryPath = true;

    nixpkgs.config.cudaSupport = mkIf cfg.proprietary cfg.cuda;


    environment.sessionVariables = {
      CUDA_PATH = mkIf (cfg.proprietary && cfg.cuda) "${pkgs.cudatoolkit}";
    };

    # (mkIf cfg.waylandFixups {
    #   LIBVA_DRIVER_NAME="nvidia";
    #   WLR_NO_HARDWARE_CURSORS="1";
    #   GBM_BACKEND = "nvidia";
    #   __GLX_VENDOR_LIBRARY_NAME="nvidia";
    #  # __EGL_VENDOR_LIBRARY_FILENAMES="${boot.kernelPackages}/share/glvnd/egl_vendor.d/10_nvidia.json";
    #   MOZ_DISABLE_RDD_SANDBOX="1";
    #   NVD_BACKEND="direct";
    #   # XDG_SESSION_TYPE = "wayland";
    #   # WLR_BACKEND = "vulkan";
    #   # WLR_RENDERER = "vulkan";
    # })

    # Home Manager fixes.
    home-manager.sharedModules = [

    {  
      # Hyprland Nvidia fixes.
      wayland.windowManager.hyprland.settings = {
        env = [
          (mkIf cfg.proprietary "GBM_BACKEND,nvidia-drm")
          (mkIf cfg.proprietary "__GLX_VENDOR_LIBRARY_NAME,nvidia")
          (mkIf cfg.proprietary "LIBVA_DRIVER_NAME,nvidia")
          (mkIf cfg.proprietary "__GL_VRR_ALLOWED,0")
          "WLR_NO_HARDWARE_CURSORS,1"
          (mkIf cfg.proprietary "WLR_DRM_NO_ATOMIC,1")
        ];
      };
    }

    ];

    boot.extraModprobeConfig = if cfg.proprietary then ''
      options nvidia NVreg_PreserveVideoMemoryAllocations=1
    '' else '''';

    services.xserver.videoDrivers = [ 
      (mkIf cfg.proprietary "nvidia")
    ];

    hardware.nvidia = mkIf cfg.proprietary {
      modesetting.enable = true; #! THIS IS REQUIRED FOR WAYLAND 
      open = cfg.openkernel;
      # nvidiaSettings = true;
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
