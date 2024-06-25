_: { config, lib, ... }:
let
  inherit (config.flake.lib)
    combineModules
    ;

  inherit (lib)
    mkOption
    types
    ;
in
{
  # options.flake.nixosModules = mkOption {
  #   type = types.attrs;
  #   default = { };
  # };

  config.flake.nixosModules = {
    flakes = import ./flakes.nix;
    hyprlandNixosCompatability = import ./applications/home-compatability/hyprland.nix;
    steam = import ./applications/steam.nix;
    movie-web = import ./movie-web.nix;
    amd = import ./hardware/cpu/amd.nix;
    intel = import ./hardware/cpu/intel.nix;
    amdgpu = import ./hardware/gpu/amdgpu.nix;
    genericgpu = import ./hardware/gpu/generic.nix;
    intelgpu = import ./hardware/gpu/intelgpu.nix;
    nvidia = import ./hardware/gpu/nvidia.nix;
    broadcom = import ./hardware/networking/broadcom.nix;
    sound = import ./hardware/sound/sound.nix;
    pipewireNoSound = import ./hardware/pipewire.nix;
    bluetooth = import ./hardware/bluetooth.nix;
    cameras = import ./hardware/cameras.nix;
    monitors = import ./hardware/monitors.nix;
    printing = import ./hardware/printing.nix;
    virtual-machines = import ./services/virtual-machines/virtual-machines.nix;
    scream = import ./services/virtual-machines/scream.nix;
    authentication = import ./services/authentication.nix;
    branding = import ./theming/kalyx/kalyx.nix;
    theming = import ./theming/theming.nix;
    wallpaper = import ./theming/wallpaper.nix;
    default.imports = combineModules config.flake.nixosModules;
  };
}
