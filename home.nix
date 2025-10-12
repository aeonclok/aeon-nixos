
{ config, pkgs, ... }:

{
  home.username = "reima";
  home.homeDirectory = "/home/reima";
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      input = {
        kb_layout = "fi";
	repeat_rate = 50;
	repeat_delay = 300;
	mouse_refocus = false;
        touchpad = {
          natural_scroll = true;  # set to false for classic direction
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

      "$mod" = "Alt_L";
      bind = [
        "$mod, Q, exec, kitty"
        "$mod, C, killactive"
        "$mod, U, togglefloating"
        "$mod, F, fullscreen"
        "$mod, RETURN, exec, firefox"
      ]
            ++ (
        # workspaces
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
        "eDP-1,1920x1080@60,0x0,1"
      ];
    };
  };
  programs.nvf = {
    enable = true;
    settings = {
      vim.viAlias = false;
      vim.vimAlias = true;
      vim.lsp = {
        enable = true;
      };
    };
  };
}
