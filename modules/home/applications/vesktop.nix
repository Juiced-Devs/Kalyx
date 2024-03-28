{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mapAttrs'
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    nameValuePair
    recursiveUpdate
    types
    ;
  inherit (builtins)
    listToAttrs
    ;

  cfg = config.kalyx.vesktop;
  makeConfig = builtins.toJSON;
in
{
  options.kalyx.vesktop = {
    enable = mkEnableOption "Vesktop discord client";
    settings = mkOption {
      description = ''Vencord settings.'';
      default = { };
      type = types.attrs;
      example = literalExpression ''
        {
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
        }
      '';
    };
    state = mkOption {
      description = ''Vesktop settings.'';
      default = { };
      type = types.attrs;
      example = literalExpression ''
        {
          discordBranch = "stable";
          firstLaunch = false;
          arRPC = "on";
          splashColor = "rgb(138, 148, 168)";
          splashBackground = "rgb(22, 24, 29)";
          minimizeToTray = false;
          splashTheming = true;
          customTitleBar = false;
        }
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
      example = literalExpression ''
        {
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
        }
      '';
    };
    enabledPlugins = mkOption {
      description = ''List of plugins to enable.''; # Useful for plugins that don't have settings.
      default = [ ];
      type = with types; listOf str;
      example = literalExpression ''
        [
          AlwaysAnimate
          GifPaste
          ImageZoom
        ]
      '';
    };
    notifications = mkOption {
      description = ''Vencord notification settings.'';
      default = { };
      type = with types; attrsOf (either str int);
      example = literalExpression ''
        {
          timeout = 5000;
          position = "bottom-right";
          useNative = "not-focused";
          logLimit = 50;
        }
      '';
    };
    cloud = mkOption {
      description = ''Vencord cloud integration settings.'';
      default = { };
      type = types.attrs;
      example = literalExpression ''
        {
          authenticated = true;
          url = "https://api.vencord.dev";
          settingsSync = true;
        }
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
      example = literalExpression ''
        {
          mytheme.css = ./path/to/css;
          mytheme1.css = '
            theme line 1
            theme line 2
          ';
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    # Temporarily requires an overlay for nixpkgs unstable, as Vesktop v1.5.0 rebranded from vencorddesktop, changing file structures and directory names. Will be removed after the first 2024 release of nixpkgs.
    home.packages = with pkgs; [
      unstable.vesktop
    ];

    home.file = mkMerge ([
      (mapAttrs'
        (name: themes: nameValuePair
          ".config/vesktop/themes/${name}.css"
          {
            text = mkIf (builtins.isString themes.css) themes.css;
            source = mkIf (builtins.isPath themes.css) themes.css;
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
