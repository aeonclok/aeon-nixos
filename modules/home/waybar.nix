{ config, pkgs, ... }:
let
  modulePadding = "0 10px";
in
{
  programs.waybar = {
    enable = true;

    systemd.enable = true;

    # Waybar JSON settings (module layout & behavior)
    # https://man.archlinux.org/man/extra/waybar/waybar-clock.5.en
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        margin = "2 2 2 2";

        # Use your Nerd Font
        # "font-family" = "MonaspiceNe Nerd Font";
        # "font-size" = 12;

        # Modules
        modules-left = [
          "niri/workspaces"
          "niri/window"
          "hyprland/workspaces"
          "window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "pulseaudio"
          "memory"
          "cpu"
          "disk"
          "bluetooth"
          "network"
          "battery"
          "tray"
          "backlight/slider"
        ];

        # Configure the Niri Workspaces module
        "niri/workspaces" = {
          format = "{icon}";
          "format-icons" = {
            active = "";
            default = "";
          };
        };

        # Configure the Niri Window Title module
        "niri/window" = {
          format = "{}";
          "rewrite" = {
            "(.*) - Mozilla Firefox" = "🌎 $1";
            "(.*) - zsh" = "> [$1]";
          };
        };
        "hyprland/workspaces" = {
          "all-outputs" = false;
          # "format" = "{name}: {icon}";
          "format" = "{name}";
          "format-icons" = {
            "active" = "";
            "default" = "";
          };
        };

        window.format = "{title}";
        window.max-length = 50;

        "backglight/slider" = {
          min = 20;
          max = 100;
          orientation = "horizontal";
        };

        disk = {
          format = "󰋊 {percentage_used}%";
          interval = 60;
          on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] kitty --override font_size=14 --title float_kitty btop'";
        };

        cpu = {
          format = "  {usage}%";
          format-alt = "  {avg_frequency} GHz";
          interval = 2;
          on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] kitty --override font_size=14 --title float_kitty btop'";
        };

        memory = {
          format = "󰟜 {}%";
          format-alt = "󰟜 {used} GiB"; # 
          interval = 2;
          # on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] kitty --override font_size=14 --title float_kitty btop'";
        };

        clock = {
          format = "{:%A %d.%m, %H:%M:%S}";
          tooltip = true;
          tooltip-format = ''
            Viikko {:%V}
            {calendar}'';
          interval = 1;
        };

        bluetooth = {
          # tweak to taste; these work out of the box
          format = "󰂯";
          format-connected = "󰂯 {num_connections}";
          format-disabled = "󰂲"; # shown when rfkilled/off
          tooltip = true;

          # handy actions
          on-click = "blueman-manager"; # open GUI
          on-click-right = "bluetoothctl power on"; # or toggle
          on-click-middle = "bluetoothctl power off";
        };

        network = {
          #   format-wifi = "  {essid} {signal}%";
          #   format-ethernet = "󰈁  {ifname}";
          #   format-disconnected = "󰤭  offline";
          #   tooltip = true;
          format-wifi = "󰖩  {signalStrength}%";
          format-ethernet = "󰀂 ";
          tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
          format-linked = "{ifname} (No IP)";
          format-disconnected = "󰖪 ";
          on-click-right = "networkmanager_dmenu";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟  muted";
          "format-icons" = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          # tooltip = false;
        };

        battery = {
          format = "{icon} {capacity}%";
          "format-icons" = [
            "󰁺"
            "󰁼"
            "󰁿"
            "󰂂"
            "󰁹"
          ];
          tooltip = true;
        };

        tray = {
          icon-size = 18;
          spacing = 8;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 3px;
      }

      window#waybar {
        background: alpha(@base00, 0.800000);
      }

      .modules-left #workspaces button.focused,
      .modules-right label, .modules-left #workspaces button.active {
        border-bottom: 3px solid transparent;
        background: alpha(@base01, 0.800000);
      }

      .modules-right label {
        background: alpha(@base01, 0.800000);
        margin-left: 4px;
        padding-right: 18px;
      }

      #wireplumber,
      #pulseaudio,
      #sndio {
        padding: ${modulePadding};
      }
      #wireplumber.muted,
      #pulseaudio.muted,
      #sndio.muted {
        padding: ${modulePadding};
      }
      #upower,
      #battery {
        padding: ${modulePadding};
      }
      #upower.charging,
      #battery.Charging {
        padding: ${modulePadding};
      }
      #network {
        padding: ${modulePadding};
      }
      #network.disconnected {
        padding: ${modulePadding};
      }
      #user {
        padding: ${modulePadding};
      }
      #clock {
        padding: ${modulePadding};
      }
      #backlight {
        padding: ${modulePadding};
      }
      #cpu {
        padding: ${modulePadding};
      }
      #disk {
        padding: ${modulePadding};
      }
      #idle_inhibitor {
        padding: ${modulePadding};
      }
      #temperature {
        padding: ${modulePadding};
      }
      #mpd {
        padding: ${modulePadding};
      }
      #language {
        padding: ${modulePadding};
      }
      #keyboard-state {
        padding: ${modulePadding};
      }
      #memory {
        padding: ${modulePadding};
      }
      #window {
        padding: ${modulePadding};
      }
      #bluetooth {
        padding: ${modulePadding};
      }
      #bluetooth.disabled {
        padding: ${modulePadding};
      }
    '';
    #   /* === Your palette === */
    #   @define-color base      #1d2021;
    #   @define-color mantle    #141414;
    #   @define-color crust     #141414;
    #   @define-color surface0  #32302f;
    #   @define-color surface1  #458588;
    #   @define-color surface2  #504945;
    #   @define-color overlay0  #665c54;
    #   @define-color overlay1  #7c6f64;
    #   @define-color overlay2  #928374;
    #   @define-color subtext0  #928374;
    #   @define-color subtext1  #458588;
    #   @define-color text      #d4be98;
    #   @define-color rosewater #ddc7a1;
    #   @define-color flamingo  #ea6962;
    #   @define-color red       #c14a4a;
    #   @define-color peach     #d3869b;
    #   @define-color yellow    #d4be98;
    #   @define-color green     #a9b665;
    #   @define-color teal      #89b482;
    #   @define-color blue      #7daea3;
    #   @define-color mauve     #e78a4e;
    #   @define-color sapphire  #458588;
    #
    #   * {
    #     font-family: "MonaspiceNe Nerd Font";
    #     font-size: 12px;
    #   }
    #
    #   window#waybar {
    #     background: @base;
    #     color: @text;
    #     border: 0px solid transparent;
    #   }
    #
    #   #workspaces button {
    #     color: @subtext0;
    #     background: transparent;
    #     padding: 0 8px;
    #     border-radius: 6px;
    #   }
    #   #workspaces button.active {
    #     background: @surface0;
    #     color: @text;
    #   }
    #   #workspaces button:hover {
    #     background: @surface1;
    #     color: @base;
    #   }
    #
    #   #cpu, #disk, #memory, #window, #clock, #network, #pulseaudio, #battery, #tray, #bluetooth {
    #     padding: 6px 10px;
    #     margin: 4px 6px;
    #     border-radius: 8px;
    #     background: @surface0;
    #     color: @text;
    #   }
    #
    #   #clock { background: @surface1; color: @base; }
    #   #network.disconnected { background: @overlay0; color: @rosewater; }
    #   #battery.critical { background: @red; color: @base; }
    #   #pulseaudio.muted { background: @overlay0; color: @overlay2; }
    # '';
  };
}
