{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    kitty
    nerd-fonts.monaspace
    wget
    fastfetch
  ];

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = builtins.fromTOML ''
"$schema" = "https://starship.rs/config-schema.json"
format = "[](color_orange)$os$username[](bg:color_yellow fg:color_orange)$directory[](fg:color_yellow bg:color_aqua)$git_branch$git_status[](fg:color_aqua bg:color_blue)$c$cpp$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:color_blue bg:color_bg3)$docker_context$conda$pixi[](fg:color_bg3 bg:color_bg1)$time[ ](fg:color_bg1)$line_break$character"
palette = "gruvbox_dark"
[palettes.gruvbox_dark]
color_fg0 = "#fbf1c7"
color_bg1 = "#3c3836"
color_bg3 = "#665c54"
color_blue = "#458588"
color_aqua = "#689d6a"
color_green = "#98971a"
color_orange = "#d65d0e"
color_purple = "#b16286"
color_red = "#cc241d"
color_yellow = "#d79921"
'';
  };

  xdg.configFile."fastfetch/config.jsonc".text = ''
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": { "type": "none" },
  "display": { "separator": "->   " },
  "modules": [ "os", "host", "kernel", "uptime" ]
}
  '';
}

