{ config, pkgs, ... }:
{
  imports = [
    ../../modules/system/base.nix
    ../../modules/system/desktop-hyprland.nix
    ../../modules/system/tailscale.nix
  ];

  networking.hostName = "thinkcentre";
  system.stateVersion = "25.05";
}

