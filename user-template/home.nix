{pkgs, lib, ...}: 
{
  home.stateVersion = "23.11";

  programs.kitty.enable = true;

  kalyx = {
    neofetch.enable = true;

    hyprland = rec { # Kalyx provides an enable option, so we should use that instead of wayland.windowManager.hyprland.enable, as we usally want the kalyx expansions and compatibility.
      enable = true;
      terminalEmulator = "kitty";
      modKey = "ALT"; # We have a modkey here, regardless of the fact we don't set binds through kalyx.
                      # Kalyx has it's own bindings it may need to build, so we must tell it which 
                      # modkey to default to when creating custom binds, like screenshare! This may change.

      mappedBinds = { # Kalyx offeres a convenient way to set hyprland binds that follow a user defined mapping.
                      # For example, we can create workspace bindings by mapping the number keys to their respective workspace numbers,
                      # or we can set window bindings by mapping the arrow keys to their respective directions.

        workspace = { # <- These names are arbitrary, feel free to name them something sensible, e.g: something = {}, would do the same thing here.
          bindMap = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "0" = "10";
          };

          binds = { # Binds are defined as a function that returns a string and accepts two arguments, where the arguments are provided by the bindMap attrset.
            moveFocusTo = x: y: "${modKey},${x},workspace,${y}"; # Once again, these names are arbitrary and are intended to provide convenience and self-documentation.
            moveWindowTo = x: y: "${modKey}+SHIFT,${x},movetoworkspace,${y}"; # Syntax is exactly the same as configuring Hyprland normally.
            moveWindowSilent = x: y: "${modKey}+CTRL,${x},movetoworkspacesilent,${y}";
          };
        };

        window = {
          bindMap = { # You are allowed to set multiple mappings to the same value, they will not conflict;
            "H" = "l";
            "J" = "d";
            "K" = "u";
            "L" = "r";
            "left" = "l";
            "down" = "d";
            "up" = "u";
            "right" = "r";
          };
          binds = {
            moveFocusTo = x: y: "${modKey},${x},movefocus,${y}";
            moveWindowTo = x: y: "${modKey},${x},movewindow,${y}";
          };
        };
      };
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