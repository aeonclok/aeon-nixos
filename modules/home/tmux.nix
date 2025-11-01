{ config, pkgs, ... }: {
  home.packages = with pkgs; [ pkgs.tmux ];

  # Symlink ~/.tmux.conf → ~/nix/modules/home/tmux.conf
  home.file.".config/tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink
    "/home/reima/nix/modules/home/tmux.conf";
}
