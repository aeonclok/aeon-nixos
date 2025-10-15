{ config, pkgs, lib, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      fish_vi_key_bindings
      fish_add_path ~/.local/bin
      bind \cn accept-autosuggestion
    '';

    functions.fish_greeting = ''fastfetch'';

    functions = {
      debug = ''./debug.sh $argv'';
      how = ''aider --no-git --message $argv'';
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

    shellInit = ''
      set -gx NVM_DIR $HOME/.nvm
      if test -s $NVM_DIR/nvm.sh
        bass source $NVM_DIR/nvm.sh
      end
      if test -f ~/.fzf.bash
        bass source ~/.fzf.bash
      end
    '';

    plugins = [
      { name = "bass"; src = pkgs.fishPlugins.bass.src; }
    ];
  };
}

