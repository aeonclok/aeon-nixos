{ config, pkgs, ... }: {
  imports = [ ../../modules/system/base.nix ];
  networking.hostName = "asusprime";
  system.stateVersion = "25.05";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0CF1-8E41";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };
}

