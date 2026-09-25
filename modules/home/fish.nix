{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.fish = {
    enable = true;
    generateCompletions = false;
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
      # fastfetch
    '';

    # Your functions / aliases
    functions = {
      valolink = "cd ~/valolink/";

      major = "~/valolink/majorlink/bin/agent";
      baremajor = "~/valolink/majorlink/bin/bare-agent";

      debug = "./debug.sh $argv";

      aurivpn = ''
        "/mnt/c/Program Files/Mozilla Firefox/firefox.exe" -no-remote -P ProxyOn
        ssh -D 1080 -q -C -N vpn
      '';

      mkcd = ''
        if test (count $argv) -eq 0
          echo "Usage: mkcd <directory>"
          return 1
        end
        mkdir -p $argv[1]
        cd $argv[1]
      '';

      # The Accesslink admin page's "Copy for majorlink" button puts
      # "accesslink <host> <key>" on the clipboard; this saves it into
      # ~/valolink/majorlink/.env through bin/accesslink-key, which checks the
      # key against the site first.
      alkey = ''
        set -l clip (wl-paste --no-newline 2>/dev/null | string trim)
        if not string match -qr '^accesslink [a-z0-9.-]+ [A-Za-z0-9]{20,}$' -- "$clip"
          echo "Clipboard does not hold an Accesslink key. Use the Copy for majorlink button on the site's Accesslink page first."
          return 1
        end
        set -l parts (string split ' ' -- "$clip")
        set -l host $parts[2]
        if ~/valolink/majorlink/bin/accesslink-key $host $parts[3] >/dev/null
          echo "api key for host $host accesslink added to valolink/.env"
        else
          echo "The site $host refused the key or did not answer; nothing saved."
          return 1
        end
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
      # lib.mkIf (pkgs.fishPlugins ? fzf-fish) {
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
