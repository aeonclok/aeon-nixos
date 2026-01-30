{ config, pkgs, ... }: {
  imports = [ ../../modules/system/base.nix ];

  networking.hostName = "thinkpad";
  system.stateVersion = "25.05";
}

