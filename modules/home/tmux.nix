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
  # Print this machine's Wayland clipboard even from an SSH session. The
  # forced command of the clip-pull key (users.users.reima in system/base.nix).
  clip-local = pkgs.writeShellApplication {
    name = "clip-local";
    runtimeInputs = [
      pkgs.wl-clipboard
      pkgs.coreutils
    ];
    text = ''
      dir=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
      for s in "$dir"/wayland-[0-9]*; do
        [[ $s == *.lock ]] && continue
        [ -S "$s" ] || continue
        WAYLAND_DISPLAY=''${s##*/} exec wl-paste --no-newline --type text
      done
      echo "no Wayland session on $(uname -n)" >&2
      exit 1
    '';
  };

  # tmux prefix+P: fetch the clipboard of the machine the given tmux client
  # is SSH'd in from (over Tailscale) into the tmux buffer, so nvim's p and
  # prefix+] paste it.
  clip-pull = pkgs.writeShellApplication {
    name = "clip-pull";
    runtimeInputs = [
      config.programs.tmux.package
      pkgs.openssh
      pkgs.coreutils
      pkgs.gnused
    ];
    text = ''
      client_pid=$1 client_name=$2
      say() { tmux display-message -c "$client_name" "$1"; }

      conn=$(tr '\0' '\n' <"/proc/$client_pid/environ" | sed -n 's/^SSH_CONNECTION=//p')
      if [ -z "$conn" ]; then
        say "clip-pull: you're at this machine, its clipboard is already in use"
        exit 0
      fi
      ip=''${conn%% *}

      tmp=$(mktemp) err=$(mktemp)
      trap 'rm -f "$tmp" "$err"' EXIT
      if ssh -i "$HOME/.ssh/clip_pull" -o IdentitiesOnly=yes -o BatchMode=yes \
        -o ConnectTimeout=3 -o StrictHostKeyChecking=accept-new "$ip" >"$tmp" 2>"$err"; then
        tmux load-buffer "$tmp"
        say "Pulled $(wc -c <"$tmp") bytes from the clipboard of $ip"
      else
        say "clip-pull: couldn't read the clipboard of $ip: $(tail -n1 "$err")"
      fi
    '';
  };
in
{
  home.packages = [
    clip-copy
    clip-paste
    clip-local
    clip-pull
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

      # Pull the clipboard of the machine this client is SSH'd in from.
      bind P run-shell -b "clip-pull '#{client_pid}' '#{client_name}'"

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
