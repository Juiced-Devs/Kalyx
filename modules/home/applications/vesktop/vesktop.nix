{ config, lib, pkgs, ... }:


let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    mapAttrs'
    nameValuePair
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
      example = ''
        kalyx.vesktop.settings = {
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
        kalyx.vesktop.state = {
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
    apis = mkOption {
      description = ''APIs required for certain plugins.'';
      default = { };
      type = with types; attrsOf (submodule {
        options.enable = mkEnableOption "Vencord plugin APIs";
      });
      example = ''
                kalyx.vesktop.apis = {
        	  BadgeAPI.enable = true;
        	  CommandsAPI.enable = false;
        	};
      '';
    };
    plugins = mkOption {
      description = ''Vencord plugins.'';
      default = { };
      type = with types; attrsOf (submodule {
        options.enable = mkEnableOption "Enable specified plugin.";
        options.settings = mkOption {
          type = with types; (either attrs str);
          default = { };
        };
      });
      example = ''
        kalyx.vesktop.plugins = {
          GifPaste.enable = true;
          iLoveSpam = false;
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
          type = types.lines;
        };
      });
      example = ''
        kalyx.vesktop.themes = {
          mytheme.css = "custom css";
          };
        };
      '';
    };
  };

  config = mkIf cfg.enable {
    # Temporarily requires an overlay for nixpkgs unstable, as Vesktop v1.5.0 rebranded from vencorddesktop, changing file structures and directory names. Will be removed after the first 2024 release of nixpkgs.
    home.packages = with pkgs; [
      unstable.vesktop
    ];

    kalyx.vesktop.apis = {
      # Default all APIs to true, and allow overriding one default to keep all others set.
      BadgeAPI.enable = mkDefault true;
      CommandsAPI.enable = mkDefault true;
      ContextMenuAPI.enable = mkDefault true;
      MemberListDecoratorsAPI.enable = mkDefault true;
      MessageAccessoriesAPI.enable = mkDefault true;
      MessageDecorationsAPI.enable = mkDefault true;
      MessageEventsAPI.enable = mkDefault true;
      MessagePopoverAPI.enable = mkDefault true;
      NoticesAPI.enable = mkDefault true;
      ServerListAPI.enable = mkDefault true;
      SettingsStoreAPI.enable = mkDefault true;
      ChatInputButtonAPI.enable = mkDefault true;
    };

    home.file = lib.mkMerge ([
      (mapAttrs'
        (name: themes: nameValuePair
          ".config/vesktop/themes/${name}.css"
          { text = themes.css; })
        cfg.themes)

      {
        ".config/vesktop/settings.json".text = makeConfig cfg.state;
        ".config/vesktop/settings/settings.json".text = makeConfig (lib.recursiveUpdate
          cfg.settings
          {
            plugins =
              (mapAttrs'
                (name: api: nameValuePair
                  name
                  { enabled = api.enable; })
                cfg.apis) //
              (mapAttrs'
                (name: plugin: nameValuePair
                  name
                  ({ enabled = plugin.enable; } // plugin.settings))
                cfg.plugins);
            notifications = cfg.notifications;
            cloud = cfg.cloud;
          }
        );
      }
    ]);
  };
}
