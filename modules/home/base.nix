{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  gruvbox-palette = import ./gruvbox-palette.nix;
in
{

  programs.ags = {
    enable = true;

    # symlink to ~/.config/ags
    configDir = null;

    # additional packages and executables to add to gjs's runtime
    extraPackages = with pkgs; [
      inputs.astal.packages.${pkgs.system}.battery
      fzf
    ];
  };

  home.sessionVariables = {
    # 1. Add your manual variables here
    MOZ_ENABLE_WAYLAND = "1";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1"; # Useful for Chromium/Electron apps

  }
  // (lib.mapAttrs' (name: value: {
    # 2. This part merges in your Gruvbox palette
    name = "THEME_${lib.strings.toUpper name}";
    value = value;
  }) gruvbox-palette);

  home.packages = with pkgs; [
    brightnessctl
    pamixer # volume control
    playerctl # media keys
    bluetui
    prisma-engines
    prisma
    openssl
    httrack
    lsyncd
    go
    calc
    age # Simple, modern encryption tool
    bandwhich # Terminal bandwidth utilization viewer
    bat # `cat` clone with syntax highlighting
    bmon # Bandwidth monitor and rate estimator
    broot # Interactive tree viewer and file navigator
    btop # Resource monitor (CPU, RAM, processes)
    cargo # Rust package manager
    choose # Command-line field selector
    cliphist # Clipboard history manager for Wayland
    comma # Run software without installing (Nix utility)
    curl # Command-line HTTP client
    curlie # `curl` with an easier interface, inspired by HTTPie
    deadnix # Detect unused Nix code
    direnv # Load/unload environment variables automatically
    duf # Disk usage/free utility with nicer UI
    dust # `du` alternative for visualizing disk usage
    entr # Run commands when files change
    eza # Modern replacement for `ls`
    fastfetch # System info fetcher (like neofetch, but faster)
    fd # Simple, fast `find` alternative
    foot # Lightweight Wayland terminal emulator
    gcc # GNU C compiler
    gdu # Fast disk usage analyzer written in Go
    gh # GitHub CLI
    gh-dash # TUI dashboard for GitHub issues and PRs
    ghostscript # PostScript and PDF processing tools
    gitui # TUI Git interface
    glib # Core GNOME/GTK utility library (required by many tools)
    glow # Render Markdown in the terminal
    gnumake # Build automation tool
    gnutar # Archiving utility (tar)
    grim # Screenshot utility for Wayland
    grimblast # Wrapper around grim and slurp for screenshots
    gzip # File compression tool
    httpie # User-friendly HTTP client
    hyperfine # Command-line benchmarking tool
    hyprcursor # Hyprland cursor management utility
    hyprpaper # Wallpaper utility for Hyprland
    hyprpicker # Color picker for Wayland/Hyprland
    imagemagick # Image manipulation tools
    imv # Simple image viewer for Wayland/X11
    jq # Command-line JSON processor
    just # Command runner (like `make`, but simpler)
    kitty # GPU-accelerated terminal emulator
    mako # Notification daemon for Wayland
    mpv # Media player (audio/video)
    mtr # Network diagnostic tool (traceroute + ping)
    networkmanager_dmenu
    ncdu # Disk usage analyzer with ncurses interface
    neovim # Modern Vim fork, extensible text editor
    nerd-fonts.monaspace # Nerd Font patched Monaspace font
    newsboat # RSS/Atom feed reader for the terminal
    nh # Helper for managing Nix environments/profiles
    nix-direnv # Integrate Nix with direnv
    nix-du # Disk usage for Nix store paths
    nix-index # Search packages by file in nixpkgs
    nix-output-monitor # Enhanced output viewer for Nix builds
    nix-tree # Visualize dependencies of Nix derivations
    nixfmt # Formatter for Nix expressions
    nixpkgs-fmt # Alternative Nix formatter
    nnn # Terminal file manager
    nodePackages.mermaid-cli # Generate diagrams and flowcharts from Markdown
    nodejs # JavaScript runtime
    nvd # Compare Nix generations
    onefetch # Git repository summary in terminal
    pass # Unix password manager (uses GPG)
    pkg-config # Manage compile/link flags for libraries
    pnpm # Fast, disk-efficient Node.js package manager
    procs # Modern replacement for `ps`
    rage # Encryption tool compatible with `age`
    ripgrep # Fast recursive search (like `grep`)
    rofi # Window/app launcher and dmenu replacement
    rustc # Rust compiler
    sd # Fast find-and-replace CLI tool
    slurp # Select regions of the screen (used with grim)
    sops # Secrets management via encryption
    statix # Linter for Nix expressions
    stylua # Lua code formatter
    swappy # Screenshot annotation tool
    tealdeer # Simplified `tldr` command helper
    tectonic # Modern LaTeX distribution
    tokei # Count lines of code
    trash-cli # Move files to trash instead of deleting
    tree # Directory tree visualizer
    tree-sitter # Parser generator and syntax highlighting library
    unzip # Extract `.zip` archives
    waybar # Customizable status bar for Wayland
    wget # HTTP/FTP file downloader
    wl-clip-persist # Persistent clipboard manager for Wayland
    wl-clipboard # Wayland clipboard utilities (`wl-copy`, `wl-paste`)
    wofi # App launcher for Wayland
    xan # (Possibly custom or uncommon package — verify usage)
    xdg-desktop-portal-hyprland # Portal backend for Hyprland
    xdg-desktop-portal-gnome # Portal backend for Hyprland
    xplr # File explorer for the terminal
    yazi # Fast TUI file manager inspired by ranger
    yq-go # YAML processor (like jq for YAML)
    ytfzf # CLI YouTube search and play tool
    zathura # Lightweight PDF viewer
    zulip # Zulip chat client
    chromium
    rclone
    fuse3
    (pkgs.callPackage ./autodarts.nix { })
  ];

  stylix.targets.hyprlock.enable = false;
  stylix.targets.firefox.profileNames = [ "reima" ];
  # Fetch WhatsApp icon into ~/.local/share/icons/whatsapp.png
  # Replace sha256 with: nix-prefetch-url https://static.whatsapp.net/rsrc.php/v3/yP/r/rYZqPCBaG70.png
  # home.file.".local/share/icons/whatsapp.png".source = pkgs.fetchurl {
  #   url = "https://static.whatsapp.net/rsrc.php/v3/yP/r/rYZqPCBaG70.png";
  #   sha256 = "sha256-REPLACE_ME_WITH_REAL_HASH";
  # };

  # xdg.desktopEntries.org-protocol = {
  #   name = "org-protocol";
  #   exec = "emacsclient -- %u";
  #   terminal = false;
  #   type = "Application";
  #   categories = [ "System" ];
  #   mimeType = [ "x-scheme-handler/org-protocol" ];
  # };

  services.udiskie = {
    enable = true;
    tray = "auto";
  };

  systemd.user.services."rclone-gdrive" = {
    Unit = {
      Description = "Rclone Mount for Google Drive";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount gdrive: ${config.home.homeDirectory}/cloud/drive \
          --vfs-cache-mode=full \
          --vfs-cache-max-size=15G \
          --vfs-cache-max-age=8h \
          --dir-cache-time=72h \
          --poll-interval=5m \
          --buffer-size=64M \
          --umask=022 \
      '';

      ExecStop = ''
        ${pkgs.fuse3}/bin/fusermount3 -u ${config.home.homeDirectory}/cloud/drive || true
      '';

      Restart = "on-failure";
      Type = "notify";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services."rclone-dropbox" = {
    Unit = {
      Description = "Rclone Mount for Dropbox";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount dropbox: ${config.home.homeDirectory}/cloud/dropbox \
          --vfs-cache-mode=full \
          --vfs-cache-max-size=15G \
          --vfs-cache-max-age=8h \
          --dir-cache-time=72h \
          --poll-interval=5m \
          --buffer-size=64M \
          --umask=022 \
      '';

      ExecStop = ''
        ${pkgs.fuse3}/bin/fusermount3 -u ${config.home.homeDirectory}/cloud/dropbox || true
      '';

      Restart = "on-failure";
      Type = "notify";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  xdg.desktopEntries.whatsapp = {
    name = "WhatsApp";
    exec = "${pkgs.chromium}/bin/chromium --disable-features=WaylandWpColorManagerV1 --ozone-platform=wayland --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer --user-data-dir=${config.xdg.dataHome}/whatsapp-chromium --app=https://web.whatsapp.com";
    terminal = false;
    # icon = "${config.home.homeDirectory}/.local/share/icons/whatsapp.png";
    type = "Application";
    categories = [
      "Network"
      "InstantMessaging"
    ];
    mimeType = [
      "text/html"
      "text/xml"
    ];
  };

  xdg.desktopEntries.zulip = {
    name = "Zulip";
    exec = "${pkgs.chromium}/bin/chromium --ozone-platform=wayland --disable-features=WaylandWpColorManagerV1 --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer --user-data-dir=${config.xdg.dataHome}/whatsapp-chromium --app=https://zulip.valolink.fi";
    terminal = false;
    # icon = "${config.home.homeDirectory}/.local/share/icons/whatsapp.png";
    type = "Application";
    categories = [
      "Network"
      "InstantMessaging"
    ];
    mimeType = [
      "text/html"
      "text/xml"
    ];
  };

  fonts = {
    fontconfig = {
      enable = true;

      defaultFonts = {
        # serif = [ "Noto Serif" ];
        # sansSerif = [ "Inter" "Noto Sans" "Cantarell" ];
        # monospace = [ "Monaspace Neon" ];
        # emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  qt = {
    enable = true;
    # platformTheme.name = "Adwaita-dark";
    style = {
      # name = "Adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Optional: freetype fine-tuning (reduces weird boldness on some setups)
  # home.sessionVariables.FREETYPE_PROPERTIES =
  #   "truetype:interpreter-version=40 cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";

  home.file.".config/niri/config.kdl" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/reima/nix/modules/home/niriconf.kdl";
    force = true;
  };

  home.file.".config/nvim/" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/reima/nix/modules/home/nvim/";
    force = true;
  };

  # home.pointerCursor = {
  #   gtk.enable = true;
  #   package = pkgs.hackneyed;
  #   name = "Hackneyed";
  #   size = 24;
  # };

  # programs.dconf.enable = true;
  dconf = {
    settings = {
      "org/gnome/desktop/interface" = {
        # gtk-theme = "Adwaita-dark";
        # color-scheme = "prefer-dark";
      };
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    configPackages = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      # This creates ~/.config/xdg-desktop-portal/niri-portals.conf
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
      # Fallback for other sessions
      common.default = [ "gtk" ];
    };
    # Optional, if you want to be explicit about backends:
    # config.common = {
    #   "org.freedesktop.impl.portal.FileChooser" = "gtk";
    #   "org.freedesktop.impl.portal.Settings" = "gtk";
    #   "org.freedesktop.impl.portal.Screencast" = "hyprland";
    #   "org.freedesktop.impl.portal.Screenshot" = "hyprland";
    # };
  };
  home.pointerCursor = {
    gtk.enable = true;
    # Adwaita is part of the gnome-themes-extra package usually
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  gtk = {
    enable = true;

    gtk3.extraConfig = {
      "gtk-use-portal" = 1;
    };
    gtk4.extraConfig = {
      "gtk-use-portal" = 1;
    };

    # Using standard Adwaita ensures binaries are cached
    # theme = {
    #   name = "adw-gtk3-dark"; # Modern GTK3 theme that matches GNOME 40+
    #   package = pkgs.adw-gtk3;
    # };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  programs.lazygit = {
    enable = true;
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Reima Kokko";
      email = "reima.kokko@valolink.fi";
    };
    includes = [
      {
        condition = "gitdir:~/valolink/";
        contents.user = {
          name = "Reima Kokko";
          email = "reima.kokko@valolink.fi";
        };
        contents.core.sshCommand = "ssh -i ~/.ssh/id_valolink";
      }
    ];
  };

  programs.firefox = {
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;

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
