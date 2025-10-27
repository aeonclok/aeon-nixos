{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
    ];
  };

  home.packages = with pkgs; [
    nodejs_20
    nodePackages.typescript
    vtsls
    vue-language-server
  ];

  home.file.".config/nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
