{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.tofi;
in
{
  options.kalyx.tofi = {
    enable = mkEnableOption "Tofi";
    bind = mkOption {
      default = "SUPER,r";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ tofi ];
    wayland.windowManager.hyprland.settings = {
      bind = [ # Kalyx doesn't provide a bindings setting as of current, so we use the default module.
        "${cfg.bind},exec,${pkgs.tofi}/bin/tofi-drun --config ${./config} | xargs hyprctl dispatch exec --" # TODO: Provide configuration options.
      ];
    };
  };
}
