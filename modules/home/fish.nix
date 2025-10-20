{ config, pkgs, lib, ... }:
{
  programs.fish = {
    enable = true;

    # Runs for interactive shells (good place for keybindings & PATH additions)
    interactiveShellInit = ''
      # Your interactive block
      fish_vi_key_bindings
      fish_add_path ~/.local/bin

      # Use Ctrl-n to accept autosuggestion
      bind \cn accept-autosuggestion
    '';

    # Show fastfetch as greeting
    functions.fish_greeting = ''
      fastfetch
    '';

    # Your functions / aliases
    functions = {
      debug = ''./debug.sh $argv'';

      how = ''
        aider --no-git --message
        $argv
      '';

      aurivpn = ''
        "/mnt/c/Program Files/Mozilla Firefox/firefox.exe" -no-remote -P ProxyOn
        ssh -D 1080 -q -C -N vpn
      '';

      ask = ''bash ~/openapicli/ask.sh $argv'';

      mkcd = ''
        if test (count $argv) -eq 0
          echo "Usage: mkcd <directory>"
          return 1
        end
        mkdir -p $argv[1]
        cd $argv[1]
      '';
    };

    # This runs for *all* shells (login + interactive).
    # Keep your NVM + FZF bash sourcing via `bass` exactly as you had it.
    shellInit = ''
      # --- NVM setup ---
      set -gx NVM_DIR $HOME/.nvm
      if test -s $NVM_DIR/nvm.sh
        bass source $NVM_DIR/nvm.sh
      end

      # --- FZF setup (fallback to bash profile if present) ---
      if test -f ~/.fzf.bash
        bass source ~/.fzf.bash
      end
    '';
    
    # Plugins via nixpkgs (no external plugin manager needed)
    plugins = [
      # `bass` lets us source bash scripts (for your nvm/fzf bits)
      { name = "bass"; src = pkgs.fishPlugins.bass.src; }

      # Nice Fish integration for fzf (CTRL-R, etc.). Keep the bass fallback above too.
      # (lib.mkIf (pkgs.fishPlugins ? fzf-fish) {
      #   name = "fzf-fish";
      #   src  = pkgs.fishPlugins.fzf-fish.src;
      # })
      #
      # # If nixpkgs has a bang-bang plugin, enable it here, otherwise skip.
      # (lib.mkIf (pkgs.fishPlugins ? bang-bang) {
      #   name = "bang-bang";
      #   src  = pkgs.fishPlugins.bang-bang.src;
      # })
      #
      # # If nixpkgs has fish-bax, enable it; otherwise skip.
      # (lib.mkIf (pkgs.fishPlugins ? fish-bax) {
      #   name = "fish-bax";
      #   src  = pkgs.fishPlugins.fish-bax.src;
      # })
    ];
  };
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

  programs.fzf.enable = true;
}

