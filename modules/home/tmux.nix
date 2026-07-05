{ config, ... }:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    shortcut = "Space";
    mouse = true;
    keyMode = "vi";

    extraConfig = ''
      bind x copy-mode

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };
  # Symlink ~/.tmux.conf → ~/nix/modules/home/tmux.conf
  # home.file.".config/tmux/tmux.conf".source =
  #   config.lib.file.mkOutOfStoreSymlink
  #   "/home/reima/nix/modules/home/tmux.conf";
}
