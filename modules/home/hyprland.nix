{ config, pkgs, lib, ... }: {
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

  programs.hyprlock = {
    enable = true;

    settings = {
      general = { grace = 0; };

      background = [{
        monitor = "";
        path = "screenshot";
        blur_passes = 2;
        blur_size = 7;
        noise = 2.0e-2;
      }];

      input-field = [{
        monitor = "";
        size = "300, 40";
        position = "0, -100";
        rounding = 0;
        outline_thickness = 1;

        inner_color = "rgba(0,0,0,0.5)";
        outer_color = "rgba(255,255,255,0.15)";
        font_color = "rgba(255,255,255,0.9)";
        placeholder_text = "<type password>";
        hide_on_empty = false;
        fade_on_empty = false;
        fade_timeout = 0;

        font_family = "MonaspiceNe NFM";
        font_size = 12;
      }];

      label = [{
        monitor = "";
        text = "$TIME";
        font_family = "MonaspiceNe NFM";
        font_size = 12;
        position = "0, 80";
      }];
    };
  };

  services.hypridle = {
    enable = true;
    settings.listener = [{
      timeout = 300;
      "on-timeout" = "hyprlock";
    }];
  };

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      input = {
        kb_layout = "fi";
        repeat_rate = 50;
        repeat_delay = 300;
        mouse_refocus = false;
        touchpad = { natural_scroll = true; };
        kb_options = "caps:swapescape";
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

      exec-once = [ "hyprlock" ];

      "$mod" = "Alt_L";
      bind = [
        "$mod, Q, exec, wezterm"
        "$mod, C, killactive"
        "$mod, U, togglefloating"
        "$mod, F, fullscreen"
        "$mod, RETURN, exec, firefox"
        "$mod, L, exec, hyprlock"

        # switch focus
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"

        "$mod, left,  alterzorder, top"
        "$mod, right, alterzorder, top"
        "$mod, up,    alterzorder, top"
        "$mod, down,  alterzorder, top"
        "$mod, h, alterzorder, top"
        "$mod, j, alterzorder, top"
        "$mod, k, alterzorder, top"
        "$mod, l, alterzorder, top"

        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, j, movewindow, d"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, l, movewindow, r"
      ] ++ (builtins.concatLists (builtins.genList (i:
        let ws = i + 1;
        in [
          "$mod, code:1${toString i}, workspace, ${toString ws}"
          "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
        ]) 9));

      monitor = [
        "desc:AU Optronics 0x2336,preferred,auto,1.6"
        "desc:AOC Q24P2W1 UFTQ4HA000235, preferred, auto, 1.25"
        ",preferred,auto,1"
      ];

      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
      };
    };
  };
}
