{ config, ... }: {
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    shortcut = "Space";
  };
  # Symlink ~/.tmux.conf → ~/nix/modules/home/tmux.conf
  # home.file.".config/tmux/tmux.conf".source =
  #   config.lib.file.mkOutOfStoreSymlink
  #   "/home/reima/nix/modules/home/tmux.conf";
}
