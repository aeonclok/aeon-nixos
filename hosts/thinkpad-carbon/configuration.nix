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
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };

  boot.initrd.systemd.enable = true;

  # MemTest86+ entry in the systemd-boot menu — rerun occasionally to see
  # whether the RAM fault (bit-28 lane, found 2026-07-02) is spreading.
  boot.loader.systemd-boot.memtest86.enable = true;

  # Userspace RAM tester: `sudo memtester 9G 3` tests only unfenced memory.
  environment.systemPackages = [ pkgs.memtester ];

  # BIOS/firmware updates via LVFS: fwupdmgr refresh && fwupdmgr update
  services.fwupd.enable = true;

  # Rootless podman for project dev shells (e.g. ~/valolink/odysseus).
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    # `docker` CLI alias + docker.sock compatibility for tools that expect Docker.
    dockerCompat = true;
    # Compose containers resolve each other by service name (odysseus -> chromadb).
    defaultNetwork.settings.dns_enabled = true;
  };

  boot.resumeDevice = "/dev/disk/by-uuid/096e32fa-fb71-48c4-8790-55214e4b027c";
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "acpi_osi=Linux"
    "resume_offset=12939264"
    # Fence off RAM regions with memtest-confirmed bit-28 errors (2026-07-02).
    # Costs ~4.3 GB; the fault is a DQ-lane issue so this reduces, not
    # guarantees-away, corruption. Photo of failing addresses in memtest:
    # cluster 14.2-18.2 GB, outliers at 343 MB and pfn 0x49c6f (~1.18 GB).
    "memmap=0x110000000$0x390000000"
    "memmap=1M$0x15700000"
    "memmap=1M$0x49c00000"
  ];

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  systemd.sleep.settings = {
    Sleep = {
      HibernateDelaySec = "20m";
    };
  };

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
