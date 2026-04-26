{ config, pkgs, ... }:
{
  imports = [ ../../modules/system/base.nix ];

  networking.hostName = "thinkpad-carbon";
  system.stateVersion = "25.05";

  services.upower = {
    enable = true;
    percentageLow = 30;
    percentageCritical = 20;
    percentageAction = 15;
    criticalPowerAction = "PowerOff";
  };

  services.tlp = {
    enable = true;
    settings = {
      USB_AUTOSUSPEND = 1;
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  boot.initrd.systemd.enable = true;

  boot.resumeDevice = "/dev/disk/by-uuid/096e32fa-fb71-48c4-8790-55214e4b027c";
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "acpi_osi=Linux"
    "resume_offset=12939264"
  ];

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=20m
  '';

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];
  powerManagement.enable = true;
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
}
