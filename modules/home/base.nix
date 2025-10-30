{
  config,
  pkgs,
  ...
}: {
  # programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neovim
    kitty
    nerd-fonts.monaspace
    wget
    fastfetch
    wl-clipboard
    cliphist
    rofi
    wl-clip-persist
    hyprpaper
    hyprcursor
    ncdu
    tree
    fd
    ripgrep
    bat
    eza
    procs
    tokei
    sd
    choose
    xan
    jq
    yq-go
    hyperfine
    just
    entr
    tealdeer
    yazi
    nnn
    xplr
    broot
    btop
    gdu
    duf
    dust
    gitui
    gh
    gh-dash
    glow
    newsboat
    onefetch
    foot
    waybar
    wofi
    mako
    grim
    slurp
    swappy
    grimblast
    hyprpicker
    xdg-desktop-portal-hyprland
    zathura
    imv
    mpv
    ytfzf
    bandwhich
    bmon
    mtr
    httpie
    curlie
    direnv
    nix-direnv
    nix-index
    comma
    nix-tree
    nix-du
    nvd
    nh
    nix-output-monitor
    deadnix
    statix
    nixpkgs-fmt
    pass
    age
    rage
    sops
    zulip
    pnpm
    nodejs
    curl
    gcc
    unzip
    gnutar
    gzip
  gnumake pkg-config tree-sitter

 
  trash-cli            # provides `trash` command
  glib                 # provides `gio` command
  

  imagemagick          # provides `magick` and `convert`
  ghostscript          # provides `gs`
  tectonic             # LaTeX renderer (or use texlive if you prefer pdflatex)
  nodePackages.mermaid-cli  # provides `mmdc`

  
  ];

  home.file."./.config/nvim/" = {
    source = ./nvim;
    recursive = true;
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.hackneyed;
    name = "Hackneyed";
    size = 24;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.hackneyed;
      name = "Hackneyed";
    };

    iconTheme = {
      package = pkgs.hackneyed;
      name = "Hackneyed";
    };
  };

  programs.lazygit = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Reima Kokko";
    userEmail = "reima.kokko@valolink.fi";
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
