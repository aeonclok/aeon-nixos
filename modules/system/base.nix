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
    # extraLayouts.fi_noesc = {
    #   description = "fi, no esc, tab>esc";
    #   languages = ["fi"];
    #   symbolsFile = pkgs.writeText "fi_tabesc" ''
    #     default partial alphanumeric_keys
    #     xkb_symbols "basic" {
    #       include "fi(winkeys)"
    #       key <ESC> { [ NoSymbol ] };
    #       key <TAB> { type="ONE_LEVEL", [ Escape ] };
    #     };
    #   '';
    # };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  programs.hyprland.enable = true;
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
