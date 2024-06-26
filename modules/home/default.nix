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
  options.flake.homeManagerModules = mkOption {
    type = types.attrs;
    default = { };
  };

  config.flake.homeManagerModules = {
    hyprland = import ./applications/hyprland/default.nix;
    thunar = import ./applications/file-managers/thunar.nix;
    file-roller = import ./applications/file-managers/file-roller.nix;
    imv = import ./applications/image-viewers/imv.nix;
    hyprlandMappedBinds = import ./applications/hyprland/mapped-binds.nix;
    hyprlandScreenshare = import ./applications/hyprland/screenshare.nix;
    discord = import ./applications/discord.nix;
    neofetch = import ./applications/neofetch.nix;
    vscode = import ./applications/vscode.nix;
    monitors = import ./hardware/monitors.nix;
    theming = import ./theming/theming.nix;
    wallpaper = import ./theming/wallpaper.nix;
    carla = import ./applications/carla.nix;
    default.imports = combineModules config.flake.homeManagerModules;
  };
}
