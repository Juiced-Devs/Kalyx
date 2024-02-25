{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.vscode;
in
{
  options.kalyx.vscode = {
    enable = mkEnableOption "Kalyx VSCode module.";
  };

  config = mkIf cfg.enable {
    #=# KALYX DEPS #=#
    kalyx = { };
    #================#
    
    programs.vscode = {
      enable = true;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      mutableExtensionsDir = true;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ]; 
      userSettings = {
        "window.titleBarStyle" = "custom";
        "[nix]"."editor.tabSize" = 2;
      };
    };
  };
}
