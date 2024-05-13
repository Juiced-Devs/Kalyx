{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mapAttrs'
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    nameValuePair
    recursiveUpdate
    types
    ;
  inherit (builtins)
    isPath
    isString
    listToAttrs
    ;

  cfg = config.programs.vesktop;
  makeConfig = builtins.toJSON;
in
{
  options.programs.vesktop = {
    enable = mkEnableOption "Vesktop discord client";
    package = mkPackageOption pkgs "vesktop" { };
    settings = mkOption {
      description = ''Vencord settings.'';
      default = { };
      type = types.attrs;
      example = ''
        programs.vesktop.settings = {
          notifyAboutUpdates = true;
          autoUpdate = true;
          autoUpdateNotification = true;
          useQuickCss = false;
          themeLinks = [
            "https://mytheme.url/path/to/theme.css"
          ];
          enabledThemes = [
            "mytheme.css"
          ];
          enableReactDevtool = false;
          frameless = false;
          transparent = false;
        };
      '';
    };
    state = mkOption {
      description = ''Vesktop settings.'';
      default = { };
      type = types.attrs;
      example = ''
        programs.vesktop.state = {
          discordBranch = "stable";
          firstLaunch = false;
          arRPC = "on";
          splashColor = "rgb(138, 148, 168)";
          splashBackground = "rgb(22, 24, 29)";
          minimizeToTray = false;
          splashTheming = true;
          customTitleBar = false;
        };
      '';
    };
    plugins = mkOption {
      description = ''Vencord plugins.'';
      default = { };
      type = with types; attrsOf (submodule {
        options.enable = mkEnableOption "Enable specified plugin.";
        options.settings = mkOption {
          type = types.attrs;
          default = { };
        };
      });
      example = ''
        programs.vesktop.plugins = {
          GifPaste.enable = true;
          iLoveSpam.enable = false;
          ImageZoom = {
            enable = true;
            settings = {
              saveZoomValues = false;
              invertScroll = false;
              nearestNeighbour = false;
              square = false;
              zoom = 2;
              size = 100.00;
              zoomSpeed = 0.5;
            };
          };
        };
      '';
    };
    enabledPlugins = mkOption {
      description = ''List of plugins to enable.''; # Useful for plugins that don't have settings.
      default = [ ];
      type = with types; listOf str;
      example = ''
        programs.vesktop.enabledPlugins = [
          AlwaysAnimate
          GifPaste
          ImageZoom
        ];
      '';
    };
    notifications = mkOption {
      description = ''Vencord notification settings.'';
      default = { };
      type = with types; attrsOf (either str int);
      example = ''
        timeout = 5000;
        position = "bottom-right";
        useNative = "not-focused";
        logLimit = 50;
      '';
    };
    cloud = mkOption {
      description = ''Vencord cloud integration settings.'';
      default = { };
      type = types.attrs;
      example = ''
        authenticated = true;
        url = "https://api.vencord.dev";
        settingsSync = true;
      '';
    };
    themes = mkOption {
      description = ''Local css themes for vencord.'';
      default = { };
      type = with types; attrsOf (submodule {
        options.css = mkOption {
          type = with types; (either lines path);
        };
      });
      example = ''
        programs.vesktop.themes = {
          mytheme.css = "custom css";
          mytheme2.css = ./path/to/css;
          };
        };
      '';
    };
  };

  config = mkIf cfg.enable {
    # Requires Vesktop v1.5.0 or new, as vesktop was rebranded from vencorddesktop, changing file structures and directory names.
    home.packages = [ cfg.package ];

    home.file = mkMerge ([
      (mapAttrs'
        (name: themes: nameValuePair
          ".config/vesktop/themes/${name}.css"
          {
            text = mkIf (isString themes.css) themes.css;
            source = mkIf (isPath themes.css) themes.css;
          })
        cfg.themes)

      {
        ".config/vesktop/settings.json".text = makeConfig cfg.state;
        ".config/vesktop/settings/settings.json".text = makeConfig (recursiveUpdate
          cfg.settings
          {
            notifications = cfg.notifications;
            cloud = cfg.cloud;
            plugins =
              # Convert enabled plugins list to "plugin":{ "enabled" = true }
              (listToAttrs (map
                (plugins: nameValuePair
                  plugins
                  { enabled = true; })
                cfg.enabledPlugins)) //
              # Map 'settings' attrset
              (mapAttrs'
                (name: plugin: nameValuePair
                  name
                  ({ enabled = plugin.enable; } // plugin.settings))
                cfg.plugins);
          }
        );
      }
    ]);
  };
}
