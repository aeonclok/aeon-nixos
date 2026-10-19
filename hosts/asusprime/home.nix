{ ... }:
{
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/fish.nix
    ../../modules/home/wezterm.nix
    ../../modules/home/waybar.nix
    ../../modules/home/tmux.nix
    ../../modules/home/mail.nix
    ../../modules/home/laya-mail.nix # mail triage model + automatic triage (asusprime only)
  ];

  home = {
    username = "reima";
    homeDirectory = "/home/reima";
    stateVersion = "25.05";
  };
}
