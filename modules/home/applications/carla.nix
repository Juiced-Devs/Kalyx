{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  makeConfig = lib.generators.toINI { };

  cfg = config.kalyx.carla;
in
{
  options.kalyx.carla = {
    enable = mkEnableOption "Carla audio plugin host";
    settings = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        INI Settings for ~/.config/falkTX/Carla2.conf.
        INI headers are written as attrs.
      '';
      example = ''
        carla.settings = {
          General = {
            ShowKeyboard = false;
            ShowToolbar = true;
          };
          Canvas = {
            AutoHideGroups = false;
          };
        };
      '';
    };
    paths = {
      # MIDI, VST2, and VST3 support planned.
      description = ''
        Set path settings for Carla. Carla has a bug in which paths are ignored if a directory under
        home is omitted. This option automatically adds sane home directories before user defined paths.
      '';
      example = ''
        kalyx.carla.paths.folders = [
          /etc/nixos/configs/carla
          "''${pkgs.rnnoise-plugin}/lib"
          "''${config.home.homeDirectory}/Carla"
          "/etc/nixos/configs/carla"
        ];
      '';
      folders = mkOption {
        type = with types; listOf (either str path);
        default = [ ];
      };
      dssi = mkOption {
        type = with types; listOf (either str path);
        default = [ ];
      };
      ladspa = mkOption {
        type = with types; listOf (either str path);
        default = [ ];
      };
      lv2 = mkOption {
        type = with types; listOf (either str path);
        default = [ ];
      };
      sf2 = mkOption {
        type = with types; listOf (either str path);
        default = [ ];
      };
      sfz = mkOption {
        type = with types; listOf (either str path);
        default = [ ];
      };
      projectFolder = mkOption {
        type = types.str;
        default = "";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ carla ];
    home.file = {
      ".config/falkTX/Carla2.conf".text = makeConfig (lib.recursiveUpdate
        cfg.settings
        {
          # Carla only reads paths if a path under home is set. I'm not sure how to avoid this workaround, or if it's even possible.
          General = {
            DiskFolders = lib.concatStringsSep ", " ([ config.home.homeDirectory ] ++ cfg.paths.folders);
          };
          Paths = {
            DSSI = lib.concatStringsSep ", " ([ "${config.home.homeDirectory}/.dssi" ] ++ cfg.paths.dssi);
            LADSPA = lib.concatStringsSep ", " ([ "${config.home.homeDirectory}/.ladspa" ] ++ cfg.paths.ladspa);
            lv2 = lib.concatStringsSep ", " ([ "${config.home.homeDirectory}/.lv2" ] ++ cfg.paths.lv2);
            sf2 = lib.concatStringsSep ", " ([ "${config.home.homeDirectory}/.sounds/sf2" ] ++ cfg.paths.sf2);
            sfz = lib.concatStringsSep ", " ([ "${config.home.homeDirectory}/.sounds/sfz" ] ++ cfg.paths.sfz);
          };
          Main = {
            ProjectFolder = cfg.paths.projectFolder;
          };
        }
      );
    };
  };
}
