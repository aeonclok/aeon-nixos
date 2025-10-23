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
      
programs.hyprlock = {
  enable = true;

  settings = {
    general = {
      grace = 0; 
    };

    background = [
      {
        monitor = "";
        path = "screenshot";   
        blur_passes = 2;   
        blur_size = 7;     
        noise = 0.02;
      }
    ];

    input-field = [
      {
        monitor = "";
        size = "300, 40";
        position = "0, -100";
        rounding = 0;
        outline_thickness = 1;

        inner_color = "rgba(0,0,0,0.5)";
        outer_color = "rgba(255,255,255,0.15)";
        font_color  = "rgba(255,255,255,0.9)";
        placeholder_text = "<type password>";
        hide_on_empty = false;
        fade_on_empty = false;
        fade_timeout  = 0;
        
        font_family = "MonaspiceNe NFM";
        font_size = 12;
      }
    ];

    
    label = [
      {
        monitor = "";
        text = "$TIME";
        font_family = "MonaspiceNe NFM";
        font_size = 12;
        position = "0, 80";
      }
    ];
  };
};


  services.hypridle = {
    enable = true;
    settings.listener = [
      { timeout = 300; "on-timeout" = "hyprlock"; }
    ];
  };

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
      
      exec-once = [ "hyprlock" ];

      "$mod" = "Alt_L";
      bind = [
        "$mod, Q, exec, wezterm"
        "$mod, C, killactive"
        "$mod, U, togglefloating"
        "$mod, F, fullscreen"
        "$mod, RETURN, exec, firefox"
        "$mod, L, exec, hyprlock"
      ]
            ++ (
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
        "desc:AU Optronics 0x2336,preferred,auto,1.6"
        ",preferred,auto,1.6"
      ];

      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo    = true;
      };
    };
  };

}
