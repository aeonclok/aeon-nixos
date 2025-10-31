{ config, pkgs, ... }: {
  programs.tmux = {
    enable = true;
    extraConfig = ''
          # Prefix & basics
          unbind C-b
          set -g prefix C-Space
          set -sg escape-time 10
          bind C-Space send-prefix
          bind c new-window -c "#{pane_current_path}"
          bind '"' split-window -c "#{pane_current_path}"
          bind % split-window -h -c "#{pane_current_path}"
          set -g base-index 1
          set -g pane-base-index 1
          setw -g pane-base-index 1
          set -g renumber-windows on

      # 24-bit color (needed for hex)
      set -ga terminal-overrides ",*:Tc"

      #### Base status layout
      set -g status on
      set -g status-style bg=default,fg="#d4be98"     # transparent bar, subtext1 fg
      set -g status-justify left                       # windows to the left
      set -g status-left-length 20
      set -g status-right-length 160

      # Palette (cool/neutral only)
      # aqua=#89b482  blue=#7daea3  text=#ddc7a1  sub1=#d4be98
      # grey1=#928374 surf2=#5a524c mantle=#32302f crust=#1b1b1b

      #### Windows (left side)
      # set -g window-status-separator ""                # we’ll manage separators ourselves
      # # Inactive: transparent, muted
      # set -g window-status-format '#[fg=#928374,bg=default] #I:#W '
      # # Active: sharp, connected pill (default → blue → default). No bold.
      # set -g window-status-current-format '#[fg=#7daea3,bg=default]#[bg=#7daea3,fg=#1b1b1b] #I:#W #[fg=#7daea3,bg=default]'
      #
      # # Activity/Bell hints (cool hues only)
      # setw -g window-status-activity-style fg="#a89984",bg=default
      # setw -g window-status-bell-style     fg="#1b1b1b",bg="#7daea3"
      #
      # #### Right side segments (connected, sharp, no outer edge glyph)
      # # Use left-pointing separators () to build from the right edge inward.
      # # Order (rightmost → left): date (mantle) ← time (surf2) ← cwd (blue)
      # set -g status-right '#[fg=#32302f,bg=default]#[bg=#32302f,fg=#d4be98] %Y-%m-%d #[fg=#5a524c,bg=#32302f]#[bg=#5a524c,fg=#ddc7a1]  %H:%M #[fg=#7daea3,bg=#5a524c]#[bg=#7daea3,fg=#1b1b1b]  #{pane_current_path} '
      #
      # #### Borders / modes (kept cool/neutral, no bold)
      # set -g pane-border-style fg="#45403d"                 # surface1
      # set -g pane-active-border-style fg="#7daea3"          # blue
      # set -g mode-style bg="#5a524c",fg="#ddc7a1"           # copy-mode banner (neutral)
      # set -g message-style bg="#45403d",fg="#ddc7a1"
      # set -g message-command-style bg="#45403d",fg="#89b482"
      # setw -g mode-keys vi
      # setw -g copy-mode-match-style bg="#89b482",fg="#1b1b1b"         # search match (aqua)
      # setw -g copy-mode-current-match-style bg="#7daea3",fg="#1b1b1b" # current match (blue)
    '';
  };
}
