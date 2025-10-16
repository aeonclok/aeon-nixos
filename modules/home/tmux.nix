{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      unbind-key C-b
      set-option -g prefix C-Space
      bind-key C-Space send-prefix
    '';
  };
}
