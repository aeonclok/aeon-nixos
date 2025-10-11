
{ config, pkgs, ... }:

{
  home.username = "reima";
  home.homeDirectory = "/home/reima";
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
