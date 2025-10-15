{ config, pkgs, ... }:
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
local wezterm = require "wezterm"
local config = wezterm.config_builder()
config.window_background_opacity = 0.90
config.audible_bell = "Disabled"
config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font({ family = "MonaspiceNe NFM" })
config.font_size = 12
return config
    '';
  };
}

