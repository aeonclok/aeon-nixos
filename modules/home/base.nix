{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    kitty
    nerd-fonts.monaspace
    wget
    fastfetch
    wl-clipboard
    cliphist   
    rofi
    wl-clip-persist
    tldr
    ncdu
    tree
  ];

  programs.lazygit = {
     enable = true;
  };

  programs.git = {
     enable = true;
     userName  = "Reima Kokko";
     userEmail = "reima.kokko@valolink.fi";
  };

  programs.firefox = {
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  programs.starship = {
    enable = true;
    enableFishIntegration = true;   # hooks starship into fish automatically
   settings = builtins.fromTOML ''
"$schema" = "https://starship.rs/config-schema.json"

format = """
[](color_orange)\
$os\
$username\
[](bg:color_yellow fg:color_orange)\
$directory\
[](fg:color_yellow bg:color_aqua)\
$git_branch\
$git_status\
[](fg:color_aqua bg:color_blue)\
$c\
$cpp\
$rust\
$golang\
$nodejs\
$php\
$java\
$kotlin\
$haskell\
$python\
[](fg:color_blue bg:color_bg3)\
$docker_context\
$conda\
$pixi\
[](fg:color_bg3 bg:color_bg1)\
$time\
[ ](fg:color_bg1)\
$line_break$character"""

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

[os]
disabled = false
style = "bg:color_orange fg:color_fg0"

[os.symbols]
Windows = "󰍲"
Ubuntu = "󰕈"
SUSE = ""
Raspbian = "󰐿"
Mint = "󰣭"
Macos = "󰀵"
Manjaro = ""
Linux = "󰌽"
Gentoo = "󰣨"
Fedora = "󰣛"
Alpine = ""
Amazon = ""
Android = ""
Arch = "󰣇"
Artix = "󰣇"
EndeavourOS = ""
CentOS = ""
Debian = "󰣚"
Redhat = "󱄛"
RedHatEnterprise = "󱄛"
Pop = ""

[username]
show_always = true
style_user = "bg:color_orange fg:color_fg0"
style_root = "bg:color_orange fg:color_fg0"
format = "[ $user wsl-toimisto ]($style)"

[directory]
style = "fg:color_fg0 bg:color_yellow"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Developer" = "󰲋 "

[git_branch]
symbol = ""
style = "bg:color_aqua"
format = "[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)"

[git_status]
style = "bg:color_aqua"
staged = "●"
modified = "✚"
deleted = "✖"
renamed = "»"
untracked = "…"
stashed = "📦"
ahead = "⇡"
behind = "⇣"
diverged = "⇕"
conflicted = "✖"
up_to_date = "✓"
format = "[[ $all_status$ahead_behind ](fg:color_fg0 bg:color_aqua)]($style)"

[nodejs]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[c]
symbol = " "
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[cpp]
symbol = " "
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[rust]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[golang]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[php]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[java]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[kotlin]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[haskell]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[python]
symbol = ""
style = "bg:color_blue"
format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)"

[docker_context]
symbol = ""
style = "bg:color_bg3"
format = "[[ $symbol( $context) ](fg:#83a598 bg:color_bg3)]($style)"

[conda]
style = "bg:color_bg3"
format = "[[ $symbol( $environment) ](fg:#83a598 bg:color_bg3)]($style)"

[pixi]
style = "bg:color_bg3"
format = "[[ $symbol( $version)( $environment) ](fg:color_fg0 bg:color_bg3)]($style)"

[time]
disabled = false
time_format = "%R"
style = "bg:color_bg1"
format = "[[  $time ](fg:color_fg0 bg:color_bg1)]($style)"

[line_break]
disabled = false

[character]
disabled = false
success_symbol = ">"
error_symbol = "[>](bold fg:color_red)"
vimcmd_symbol = "_"
vimcmd_replace_one_symbol = "[<](fg:color_purple)"
vimcmd_replace_symbol = "[<](fg:color_purple)"
vimcmd_visual_symbol = "[<](fg:color_yellow)"
'';
  };

  xdg.configFile."fastfetch/config.jsonc".text = ''
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "none"
  },
  "display": {
    "separator": "->   ",
    "color": {
      "separator": "1"
    },
    "constants": [
      "───────────────────────────"
    ],
    "key": {
      "type": "both",
      "paddingLeft": 4
    }
  },
  "modules": [
    {
      "type": "title",
      "format": "                             {user-name-colored}{at-symbol-colored}{host-name-colored}"
    },
    "break",
    {
      "type": "custom",
      "format": "┌{$1} {#1}System Information{#} {$1}┐"
    },
    "break",
    {
      "key": "OS           ",
      "keyColor": "red",
      "type": "os"
    },
    {
      "key": "Machine      ",
      "keyColor": "green",
      "type": "host"
    },
    {
      "key": "Kernel       ",
      "keyColor": "magenta",
      "type": "kernel"
    },
    {
      "key": "Uptime       ",
      "keyColor": "red",
      "type": "uptime"
    },
    {
      "key": "Resolution   ",
      "keyColor": "yellow",
      "type": "display",
      "compactType": "original-with-refresh-rate"
    },
    {
      "key": "WM           ",
      "keyColor": "blue",
      "type": "wm"
    },
    {
      "key": "DE           ",
      "keyColor": "green",
      "type": "de"
    },
    {
      "key": "Shell        ",
      "keyColor": "cyan",
      "type": "shell"
    },
    {
      "key": "Terminal     ",
      "keyColor": "red",
      "type": "terminal"
    },
    {
      "key": "CPU          ",
      "keyColor": "yellow",
      "type": "cpu"
    },
    {
      "key": "GPU          ",
      "keyColor": "blue",
      "type": "gpu"
    },
    {
      "key": "Memory       ",
      "keyColor": "magenta",
      "type": "memory"
    },
    {
      "key": "Local IP     ",
      "keyColor": "red",
      "type": "localip",
      "compact": true
    },
    {
      "key": "Public IP    ",
      "keyColor": "cyan",
      "type": "publicip",
      "timeout": 1000
    },
    "break",
    {
      "type": "custom",
      "format": "└{$1}────────────────────{$1}┘"
    },
    "break",
    {
      "type": "colors",
      "paddingLeft": 34,
      "symbol": "circle"
    }
  ]
}
  '';
}

