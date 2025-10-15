{ config, pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 32;
      modules-left  = [ "hyprland/workspaces" "window" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" "tray" ];
    };

    style = ''
      * { font-family: "MonaspiceNe Nerd Font"; font-size: 12px; }
      window#waybar { background: #1d2021; color: #d4be98; }
    '';
  };
}

