{ config, pkgs, lib, ... }:
{
  imports = [ ../stylix.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  # /etc/hosts is a symlink to /etc/hosts.local — edit that file directly
  # (sudoedit /etc/hosts.local) and changes take effect on save without a rebuild.
  environment.etc.hosts = lib.mkForce {
    source = "/etc/hosts.local";
    mode = "symlink";
  };
  system.activationScripts.hostsLocalSeed.text = ''
    if [ ! -e /etc/hosts.local ]; then
      cat > /etc/hosts.local <<'EOF'
    127.0.0.1 localhost
    ::1 localhost
    127.0.0.2 ${config.networking.hostName}

    # --- user overrides below; edit freely, no rebuild needed ---

    # 94.237.113.119 soutuveneet.fi www.soutuveneet.fi
    # 94.237.113.119 ykiveneet.fi www.ykiveneet.fi
    # 212.147.236.211 rainset.fi www.rainset.fi
    # 89.167.14.205 operaria.fi www.operaria.fi
    # 94.237.39.7 kuumalahde.fi www.kuumalahde.fi

    89.167.14.205 valolink.fi www.valolink.fi staging.valolink.fi
    EOF
      chmod 0644 /etc/hosts.local
    fi
  '';
  time.timeZone = "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

  services.xserver.xkb = {
    layout = "fi";
    options = "caps:escape";
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = [ "gtk" ];
    config.niri.default = [
      "gnome"
      "gtk"
    ];
  };

  programs.wshowkeys.enable = true;

  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";

  programs.niri.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
  };

  programs.thunar.enable = true;

  services.udisks2.enable = true;

  services.gvfs.enable = true;

  environment.variables = {
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
  };

  services.displayManager.gdm.enable = true;

  console.keyMap = "fi";

  programs.mosh.enable = true;
  services.tailscale = {
    enable = true;
    # NOTE: extraUpFlags only take effect via the autoconnect service (authKeyFile).
    # Since `tailscale up` was run manually, Tailscale SSH must be enabled per
    # machine with: sudo tailscale set --ssh
    extraUpFlags = [ "--ssh" ];
  };

  services.openssh = {
    enable = true; # optional; Tailscale SSH doesn’t require sshd, but many keep it running
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Required so the Home Manager-installed swaylock can authenticate unlocks.
  security.pam.services.swaylock = { };

  programs.fish.enable = true;

  users.users.reima = {
    isNormalUser = true;
    description = "reima";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

}
