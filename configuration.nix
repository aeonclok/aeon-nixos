
{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
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
    variant = "winkeys";
  };

  console.keyMap = "fi";

  users.users.reima = {
    isNormalUser = true;
    description = "reima";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ vim git ];
  };
  programs.hyprland = {
    enable = true;
  };

  programs.neovim = {
    enable = true; 
    defaultEditor = true;
  };

  programs.firefox = {
    enable = true;
  };
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    pkgs.kitty
    wget
  ];

  system.stateVersion = "25.05"; # Did you read the comment?
}
