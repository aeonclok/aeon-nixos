{ config, pkgs, ... }: {
  imports = [ ../../modules/system/fonts.nix ../../modules/system/base.nix ];
  networking.hostName = "asusprime";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 3030 ];

  system.stateVersion = "25.05";

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  powerManagement.enable = true;

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

