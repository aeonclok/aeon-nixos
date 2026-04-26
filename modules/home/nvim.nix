{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
  };

  home.packages = with pkgs; [
    typescript
    vtsls
    vue-language-server
  ];

  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
