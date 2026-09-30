{ config, pkgs, ... }:
let
  # Print this machine's WAYLAND_DISPLAY if the person at the keyboard sits at
  # it; fail if they're connected over SSH/mosh. Inside tmux that is decided by
  # the most recently active client of this pane's session (its environment, not
  # the pane's, which may be stale).
  localWaylandDisplay = ''
    local_wayland_display() {
      local env
      if [ -n "''${TMUX:-}" ]; then
        local pid
        pid=$(tmux display-message -p '#{client_pid}' 2>/dev/null) || return 1
        [ -n "$pid" ] || return 1
        env=$(tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null) || return 1
      elif [ -z "''${SSH_CONNECTION:-}" ]; then
        env="WAYLAND_DISPLAY=''${WAYLAND_DISPLAY:-}"
      else
        return 1
      fi
      local wd
      wd=$(sed -n 's/^WAYLAND_DISPLAY=//p' <<<"$env")
      [ -n "$wd" ] && printf '%s\n' "$wd"
    }
  '';

  runtimeInputs = [
    config.programs.tmux.package
    pkgs.wl-clipboard
    pkgs.coreutils
    pkgs.gnused
  ];

  # Clipboard of whoever is at the keyboard: the Wayland clipboard when sitting
  # at this machine, the remote terminal's clipboard (OSC 52 via tmux) when
  # attached over SSH. Used by nvim (options.lua) and fish (alkey).
  clip-copy = pkgs.writeShellApplication {
    name = "clip-copy";
    inherit runtimeInputs;
    text = localWaylandDisplay + ''
      tmp=$(mktemp)
      trap 'rm -f "$tmp"' EXIT
      cat >"$tmp"

      if wd=$(local_wayland_display); then
        WAYLAND_DISPLAY=$wd wl-copy <"$tmp"
        if [ -n "''${TMUX:-}" ]; then tmux load-buffer - <"$tmp"; fi
      elif [ -n "''${TMUX:-}" ]; then
        # -w also hands it to the client's terminal (OSC 52), i.e. the remote machine.
        tmux load-buffer -w - <"$tmp"
      elif [ -n "''${SSH_TTY:-}" ]; then
        printf '\033]52;c;%s\a' "$(base64 -w0 <"$tmp")" >"$SSH_TTY"
      fi
    '';
  };

  # A remote terminal's clipboard can't be read back, so remotely this is the
  # newest tmux buffer (the last thing yanked in nvim or tmux copy mode).
  clip-paste = pkgs.writeShellApplication {
    name = "clip-paste";
    inherit runtimeInputs;
    text = localWaylandDisplay + ''
      if wd=$(local_wayland_display); then
        WAYLAND_DISPLAY=$wd wl-paste --no-newline
      elif [ -n "''${TMUX:-}" ]; then
        tmux save-buffer -
      else
        exit 1
      fi
    '';
  };
in
{
  home.packages = [
    clip-copy
    clip-paste
  ];

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    shortcut = "Space";
    mouse = true;
    keyMode = "vi";

    extraConfig = ''
      bind x copy-mode

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Don't copy env from attaching clients: attaching over SSH (e.g. Termux)
      # would drop WAYLAND_DISPLAY and set SSH_CONNECTION for every new pane,
      # breaking wl-paste and making LazyVim disable the system clipboard.
      # New panes always use the server's (local desktop) environment instead.
      set -g update-environment ""
      # Stable gnome-keyring agent (wezterm's agent.<pid> symlink points here).
      set-environment -g SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gcr/ssh"
    '';
  };
  # Symlink ~/.tmux.conf → ~/nix/modules/home/tmux.conf
  # home.file.".config/tmux/tmux.conf".source =
  #   config.lib.file.mkOutOfStoreSymlink
  #   "/home/reima/nix/modules/home/tmux.conf";
}
