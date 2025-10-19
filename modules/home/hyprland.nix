{ config, pkgs, lib, ... }:
{

  services.hyprpaper = {
    enable = true;
    settings = {
    ipc = "on";
    splash = false;
     # splash_offset = 2.0;
    preload = [ "/home/reima/nix/background.jpg" ];
    wallpaper = [ ",/home/reima/nix/background.jpg" ];
    };
  };
      
  # systemd.user.services.hyprpaper.Unit.After = lib.mkForce [ "graphical-session.target" ];
  # systemd.user.services.hyprpaper.Install.WantedBy = [ "graphical-session.target" ];


  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      input = {
        kb_layout = "fi";
	repeat_rate = 50;
	repeat_delay = 300;
	mouse_refocus = false;
        touchpad = {
          natural_scroll = true;
        };
      };

      general = {
        gaps_in = 2;
        gaps_out = 2;
        border_size = 0;
        layout = "master";
      };

      decoration = {
        rounding = 0;
        shadow = {
          range = 0;
          render_power = 0;
        };
        blur = {
          enabled = false;
          size = 5;
          passes = 2;
        };
      };
      
      # exec-once = [ "hyprpaper" ];

      "$mod" = "Alt_L";
      bind = [
        "$mod, Q, exec, wezterm"
        "$mod, C, killactive"
        "$mod, U, togglefloating"
        "$mod, F, fullscreen"
        "$mod, RETURN, exec, firefox"
      ]
            ++ (
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
      );
      monitor = [
        # "eDP-1,1920x1080@60,0x0,1"
        ",preferred,auto,1"
      ];

      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo    = true;
      };
    };
  };

}
