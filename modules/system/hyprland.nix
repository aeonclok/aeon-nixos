
{ config, pkgs, ... }:
{
  programs.hyprland.enable = true; 
  services.displayManager.sddm.wayland.enable = true;
}

