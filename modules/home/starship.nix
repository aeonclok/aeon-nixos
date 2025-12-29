{ config, pkgs, ... }: {
  # home.packages = with pkgs; [ pkgs.starship ];

  programs.starship = {
    enable = true;
    enableFishIntegration = true; # hooks starship into fish automatically
  };
  # Symlink ~/.tmux.conf → ~/nix/modules/home/tmux.conf
  # home.file.".config/starship.toml".source = config.lib.file.mkOutOfStoreSymlink
  #   "/home/reima/nix/modules/home/starship.toml";
}
