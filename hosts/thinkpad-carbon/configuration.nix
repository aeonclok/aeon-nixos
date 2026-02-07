{ config, pkgs, ... }: {
  imports = [ ../../modules/system/base.nix ];

  networking.hostName = "thinkpad-carbon";
  system.stateVersion = "25.05";

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024; # Size in MB (16GB here)
  }];
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [
    "mem_sleep_default=deep"
  ]; # Important for ThinkPads to sleep/resume correctly
  powerManagement.enable = true;
  services.logind.settings.Login = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HibernateDelaySec=1m
    '';
  };
  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
}

