{pkgs, lib, ...}: 
{
  home.stateVersion = "23.11";

  programs.kitty.enable = true;

  kalyx = {
    neofetch.enable = true;

    hyprland = { # Kalyx provides an enable option, so we should use that instead of wayland.windowManager.hyprland.enable, as we usally want the kalyx expansions and compatibility.
      enable = true;
      terminalEmulator = "kitty";
      modKey = "ALT"; # We have a modkey here, regardless of the fact we don't set binds through kalyx.
                      # Kalyx has it's own bindings it may need to build, so we must tell it which 
                      # modkey to default to when creating custom binds, like screenshare! This may change.
    };
  };

  # The Kalyx module and the standard module work in tandem.
  # Any configuration options Kalyx provides ontop of modules
  # should generally, exclusively be done through Kalyx.
  ###############################
  wayland.windowManager.hyprland.settings = let 
    modKey = "ALT";
  in 
  {
    bind = [ # Kalyx doesn't provide a bindings setting as of current, so we use the default module.
      "${modKey},RETURN,exec,${pkgs.kitty}/bin/kitty"
      "${modKey},C,killactive"
      "${modKey},SPACE,togglefloating"
      "${modKey},M,exit"
      "${modKey},F,fullscreen"
    ];

    bindm = [
      "${modKey},mouse:272,movewindow"
      "${modKey},mouse:273,resizewindow"
    ];
  };
  ###############################
}