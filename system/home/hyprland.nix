{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      input = {
        kb_layout = "fi";
        repeat_rate = 50;
        repeat_delay = 300;
        touchpad.natural_scroll = true;
      };

      general = {
        gaps_in = 2;
        gaps_out = 2;
        border_size = 0;
        layout = "master";
      };

      "$mod" = "Alt_L";
      bind = [
        "$mod, Q, exec, wezterm"
        "$mod, C, killactive"
        "$mod, U, togglefloating"
        "$mod, F, fullscreen"
        "$mod, RETURN, exec, firefox"
      ] ++ (
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]) 9)
      );

      monitor = [ "eDP-1,1920x1080@60,0x0,1" ];
    };
  };
}

