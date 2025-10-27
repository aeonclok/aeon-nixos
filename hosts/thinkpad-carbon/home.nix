{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/home/base.nix
    ../../modules/home/fish.nix
    ../../modules/home/wezterm.nix
    ../../modules/home/hyprland.nix
    ../../modules/home/waybar.nix
    ../../modules/home/nvim.nix
    ../../modules/home/tmux.nix
  ];

  home.username = "reima";
  home.homeDirectory = "/home/reima";
  home.stateVersion = "25.05";
}
