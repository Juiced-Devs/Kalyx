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

    imageSource = mkOption {
      type = types.nullOr types.path;
      default = null;
    };

    distroName = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    asciiColors = mkOption {
      type = types.nullOr types.str;
      default = null;
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
        
        ${if (cfg.distroName != null) then (''distro="${cfg.distroName} x86_64"'') else ""}
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

      ${if (cfg.asciiColors != null) then ("ascii_colors=(${cfg.asciiColors})") else ""}
      ${if (cfg.imageSource != null) then ("image_source=${cfg.imageSource}") else ""}
    '';
  };
}
