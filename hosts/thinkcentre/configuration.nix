{ config, pkgs, ... }:
{
  imports = [
    ../../modules/system/base.nix
    ../../modules/system/desktop-hyprland.nix
    ../../modules/system/tailscale.nix
  ];

  networking.hostName = "nixos-laptop";
  system.stateVersion = "25.05";
}

