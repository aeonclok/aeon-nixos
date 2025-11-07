{ config, pkgs, ... }: {
  imports = [ ../../modules/system/base.nix ];

  networking.hostName = "thinkpad-carbon";
  system.stateVersion = "25.05";
}

