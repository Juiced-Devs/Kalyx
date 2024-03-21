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
    hyprlandMappedBinds = import ./applications/hyprland/mapped-binds.nix;
    tofi = import ./applications/launchers/tofi/tofi.nix;
    discord = import ./applications/discord.nix;
    neofetch = import ./applications/neofetch.nix;
    vscode = import ./applications/vscode.nix;
    monitors = import ./hardware/monitors.nix;
    cursorTheming = import ./theming/cursor.nix;
    theming = import ./theming/theming.nix;
    wallpaper = import ./theming/wallpaper.nix;
    default.imports = combineModules config.flake.homeManagerModules;
  };
}