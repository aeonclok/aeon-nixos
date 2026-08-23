{ config, pkgs, ... }:
{
  imports = [
    ../../modules/system/base.nix
    ../../modules/system/syncthing.nix
  ];

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

  # Fan control. Enabling thinkfan auto-adds `thinkpad_acpi fan_control=1`
  # (via boot.extraModprobeConfig), which is what unlocks writes to
  # /proc/acpi/ibm/fan. Requires a reboot (or module reload) after first switch.
  #
  # The legacy tpacpi thermal sensor (/proc/acpi/ibm/thermal) only exposes one
  # live reading here — the rest are -128/0 dead slots — so the curve is driven
  # off the coretemp CPU package sensor instead. The query points at the stable
  # platform path (bare hwmonN numbers shuffle across boots); indices = [ 0 ]
  # selects temp1_input (Package id 0).
  services.thinkfan = {
    enable = true;
    sensors = [
      {
        type = "hwmon";
        query = "/sys/devices/platform/coretemp.0/hwmon";
        indices = [ 0 ];
      }
    ];
    # [ LEVEL LOW HIGH ]: step up when temp reaches HIGH, step down at LOW.
    # Quiet-biased — fan stays off below 55 °C, ramps toward level 7 by ~83 °C.
    levels = [
      [ 0 0 55 ]
      [ 1 50 63 ]
      [ 2 58 70 ]
      [ 3 65 77 ]
      [ 4 72 82 ]
      [ 5 78 86 ]
      [ 7 83 32767 ]
    ];
  };

  # Automatic deduplicating backups of /home to Google Drive via restic's
  # rclone backend (reuses the `gdrive:` remote). Runs as the reima user so it
  # can read the user's rclone token; restic talks to the remote directly and
  # never touches the ~/cloud/drive FUSE mount. Repo password lives outside the
  # nix repo at ~/.config/restic/password (mode 600 — save it in a password
  # manager; losing it means the repo is unrecoverable).
  services.restic.backups.home = {
    user = "reima";
    repository = "rclone:gdrive:backups/restic/thinkpad-carbon";
    rcloneConfigFile = "/home/reima/.config/rclone/rclone.conf";
    passwordFile = "/home/reima/.config/restic/password";
    initialize = true;
    paths = [ "/home/reima" ];
    exclude = [
      "/home/reima/cloud" # the gdrive FUSE mount — never back gdrive into gdrive
      "/home/reima/.cache"
      "/home/reima/.local/share/Trash"
      "/home/reima/.local/share/containers" # podman/docker image store, regenerable
      "/home/reima/.cargo/registry"
      "/home/reima/.rustup"
      "**/node_modules"
      "**/.direnv"
      "**/.venv"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true; # catch up after the laptop was asleep/off
      RandomizedDelaySec = "45min";
    };
    # Retention applied after each run (forget --prune, grouped per host+paths).
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
    ];
  };

  boot.initrd.systemd.enable = true;

  # MemTest86+ entry in the systemd-boot menu — rerun occasionally to see
  # whether the RAM fault (bit-28 lane, found 2026-07-02) is spreading.
  boot.loader.systemd-boot.memtest86.enable = true;

  # BIOS/firmware updates via LVFS: fwupdmgr refresh && fwupdmgr update
  services.fwupd.enable = true;

  # Rootless podman for project dev shells (e.g. ~/valolink/odysseus).
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  boot.resumeDevice = "/dev/disk/by-uuid/050bf0f0-9d1d-4d16-b0f8-466d17ab1452";
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "acpi_osi=Linux"
  ];

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  systemd.sleep.settings = {
    Sleep = {
      HibernateDelaySec = "20m";
    };
  };

  powerManagement.enable = true;
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
}
