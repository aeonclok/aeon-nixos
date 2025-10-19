{ config, pkgs, ... }:
{
  imports = [
    ../../modules/system/base.nix
  ];

  networking.hostName = "thinkcentre";
  system.stateVersion = "25.05";
}

