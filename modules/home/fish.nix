{ config, pkgs, lib, ... }: {
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
      debug = "./debug.sh $argv";

      how = ''
        aider --no-git --message
        $argv
      '';

      aurivpn = ''
        "/mnt/c/Program Files/Mozilla Firefox/firefox.exe" -no-remote -P ProxyOn
        ssh -D 1080 -q -C -N vpn
      '';

      ask = "bash ~/openapicli/ask.sh $argv";

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
      {
        name = "bass";
        src = pkgs.fishPlugins.bass.src;
      }

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

  imports = [ ./starship.nix ];
  programs.fzf.enable = true;
}

