{ config, pkgs, ... }: {
  imports = [ ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.networkmanager.enable = true;
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
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  programs.wshowkeys.enable = true;

  programs.hyprland.enable = true;
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
    XDG_CURRENT_DESKTOP = "Hyprland";
    # (optional) GDK_BACKEND = "wayland";
  };
  programs.hyprland.xwayland.enable = true;
  security.pam.services.hyprlock = { };
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.displayManager.defaultSession = "hyprland";
  services.displayManager.autoLogin = {
    enable = true;
    user = "reima";
  };

  console.keyMap = "fi";

  programs.mosh.enable = true;
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
  };

  services.openssh = {
    enable =
      true; # optional; Tailscale SSH doesn’t require sshd, but many keep it running
    openFirewall = false;
  };

  programs.fish.enable = true;

  users.users.reima = {
    isNormalUser = true;
    description = "reima";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };
}
