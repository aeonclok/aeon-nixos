{ config, pkgs, ... }:
{
  programs.nvf = {
    enable = true;
    enableManpages = true;

    settings = {
      vim.extraPackages = with pkgs; [ ripgrep fd git ];
      vim.treesitter.enable = true;
      vim.lsp.enable = true;

      vim.languages.nix = {
        enable = true;
        lsp.server = "nixd";
        format = { enable = true; type = "alejandra"; };
      };
    };
  };
}

