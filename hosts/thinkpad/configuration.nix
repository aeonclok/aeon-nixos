{ config, pkgs, ... }:
{
  imports = [
    ../../modules/system/base.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/tailscale.nix
  ];

  networking.hostName = "thinkpad";
  system.stateVersion = "25.05";
}

