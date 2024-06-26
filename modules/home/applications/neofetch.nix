{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.kalyx.neofetch;
in
{
  options.kalyx.neofetch = {
    enable = mkEnableOption "Neofetch";

    image= {
      kalyxSvg = mkEnableOption "Display the Kalyx svg";

      # Must be set for non-ascii images
      renderer = mkOption {
        description = "Set the program used to render the image.";
        type = types.str;
        default = "ascii";
        example = "kitty"; # TODO: Document available options (check neofetch source)
      };

      source = mkOption {
        description = ''
          Path to image for neofetch to display.
          Non-ascii images require setting a renderer.
        '';
        type = types.nullOr types.path;
        default = null;
        example = ./kalyx-ansii;
      };

      size = mkOption {
        description = "Change the size of the rendered image.";
        type = types.str;
        default = "auto";
        example = "320px";
      };
    };

    distroName = mkOption {
      description = "Text to be shown in the 'OS:' section.";
      type = types.nullOr types.str;
      default = null;
      example = "Kalyx [Nixos]";
    };

    asciiColors = mkOption {
      description = "Color scheme to use for ascii art.";
      type = types.nullOr types.str;
      default = null;
      example = "11 3 10 2";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      neofetch
    ];

    home.file.".config/neofetch/config.conf".text = ''
      print_info() {
        info title
        info underline
        
        ${if (cfg.distroName != null) then (''distro="${cfg.distroName}"'') else ""}
        info "OS" distro
        info "Host" model
        info "Kernel" kernel
        info "Uptime" uptime
        info "Packages" packages
        info "Shell" shell
        info "Resolution" resolution
        info "DE" de
        info "WM" wm
        info "WM Theme" wm_theme
        info "Theme" theme
        info "Icons" icons
        info "Terminal" term
        info "Terminal Font" term_font
        info "CPU" cpu
        info "GPU" gpu
        info "Memory" memory

        # info "GPU Driver" gpu_driver  # Linux/macOS only
        # info "Disk" disk
        # info "Battery" battery
        # info "Font" font
        # info "Song" song
        # [[ "$player" ]] && prin "Music Player" "$player"
        # info "Local IP" local_ip
        # info "Public IP" public_ip
        # info "Users" users
        # info "Locale" locale  # This only works on glibc systems.

        info cols
      }

      image_backend=${cfg.image.renderer}
      image_size=${cfg.image.size}

      ${if (cfg.asciiColors != null) then ("ascii_colors=(${cfg.asciiColors})") else ""}
      ${if (cfg.image.kalySvg) then ("image_source=${../../../res/kalyx.svg}") else
        if (cfg.image.source != null) then ("image_source=${cfg.image.source}") else ""}
    '';
  };
}
