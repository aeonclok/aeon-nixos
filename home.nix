{
  config,
  pkgs,
  ...
}: {
  home.username = "reima";
  home.homeDirectory = "/home/reima";
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    pkgs.kitty
    pkgs.nerd-fonts.monaspace
    wget
    pkgs.fastfetch
  ];
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

  programs.starship = {
    enable = true;
    enableFishIntegration = true; # hooks starship into fish automatically
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

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      input = {
        kb_layout = "fi";
        repeat_rate = 50;
        repeat_delay = 300;
        mouse_refocus = false;
        touchpad = {
          natural_scroll = true;
          disable_while_scrolling = true;
        };
      };

      general = {
        gaps_in = 2;
        gaps_out = 2;
        border_size = 0;
        layout = "master";
      };

      decoration = {
        rounding = 0;
        shadow = {
          range = 0;
          render_power = 0;
        };
        blur = {
          enabled = false;
          size = 5;
          passes = 2;
        };
      };

      "$mod" = "Alt_L";
      bind =
        [
          "$mod, Q, exec, wezterm"
          "$mod, C, killactive"
          "$mod, U, togglefloating"
          "$mod, F, fullscreen"
          "$mod, RETURN, exec, firefox"
        ]
        ++ (
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
        );
      monitor = [
        "eDP-1,1920x1080@60,0x0,1"
      ];
    };
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require "wezterm"
      local config = wezterm.config_builder()

      config.window_background_opacity = 0.90

      config.audible_bell = "Disabled"
      config.visual_bell = {
        fade_in_duration_ms = 75,
        fade_out_duration_ms = 75,
        fade_in_function = "EaseIn",
        fade_out_function = "EaseOut",
      }

      config.hide_tab_bar_if_only_one_tab = true

      config.freetype_load_target = "HorizontalLcd"
      config.freetype_render_target = "HorizontalLcd"
      config.cell_width = 0.9

      -- REMOVE this when using custom colors:
      -- config.color_scheme = "GruvboxDark"

      -- === Catppuccin “mocha” with your overrides ===
      local P = {
        base      = "#1d2021",
        mantle    = "#141414",
        crust     = "#141414",
        surface0  = "#32302f",
        surface1  = "#458588",
        surface2  = "#504945",
        overlay0  = "#665c54",
        overlay1  = "#7c6f64",
        overlay2  = "#928374",
        subtext0  = "#928374",
        subtext1  = "#458588",
        text      = "#d4be98",
        rosewater = "#ddc7a1",
        flamingo  = "#ea6962",
        red       = "#c14a4a",
        peach     = "#d3869b",
        yellow    = "#d4be98",
        green     = "#a9b665",
        teal      = "#89b482",
        blue      = "#7daea3",
        mauve     = "#e78a4e",
        sapphire  = "#458588",
      }

      config.colors = {
        foreground = P.text,
        background = P.base,

        cursor_bg = P.text,
        cursor_fg = P.base,
        cursor_border = P.text,

        selection_bg = P.surface0,
        selection_fg = P.text,

        scrollbar_thumb = P.surface2,
        split = P.surface2,

        -- 16-color ANSI palette
        ansi = {
          P.base,     -- black
          P.red,      -- red
          P.green,    -- green
          P.yellow,   -- yellow
          P.blue,     -- blue
          P.peach,    -- magenta-ish (your palette's pink/purple leans warm)
          P.teal,     -- cyan
          P.text,     -- white
        },
        brights = {
          P.surface0, -- bright black
          P.flamingo, -- bright red
          P.green,    -- bright green
          P.rosewater,-- bright yellow
          P.blue,     -- bright blue
          P.mauve,    -- bright magenta
          P.teal,     -- bright cyan
          P.rosewater -- bright white
        },
      }

      config.font = wezterm.font({
        family = "MonaspiceNe NFM",
        harfbuzz_features = { "calt","liga","dlig","ss01","ss02","ss03","ss04","ss05","ss06","ss07","ss08" },
      })
      config.font_size = 12

      config.font_rules = {
        {
          intensity = "Normal",
          italic = true,
          font = wezterm.font({
            family = "MonaspiceNe NFM",
            weight = "Light",
            style = "Italic",
            harfbuzz_features = { "calt","liga","dlig","ss01","ss02","ss03","ss04","ss05","ss06","ss07","ss08" },
          }),
        },
        {
          intensity = "Bold",
          italic = false,
          font = wezterm.font({
            family = "MonaspiceNe NFM",
            weight = "Bold",
            style = "Normal",
            harfbuzz_features = { "calt","liga","dlig","ss01","ss02","ss03","ss04","ss05","ss06","ss07","ss08" },
          }),
        },
      }

      return config
    '';
  };

  programs.nvf = {
    enable = true;
    enableManpages = true;

    settings = {
      vim.extraPackages = with pkgs; [ripgrep fd git];

      vim.theme.enable = false;

      vim.autocomplete.blink-cmp.enable = true;
      vim.telescope.enable = true;
      vim.binds.whichKey.enable = true;

      vim.statusline.lualine.enable = true;
      vim.tabline.nvimBufferline.enable = true;

      vim.git.gitsigns.enable = true;

      vim.ui.noice.enable = true;
      vim.notify.nvim-notify.enable = true;

      # vim.diagnostics.trouble.enable = true;

      vim.notes.todo-comments.enable = true;

      vim.treesitter.enable = true;
      vim.lsp.enable = true;

      vim.languages.nix = {
        enable = true;
        treesitter.enable = true;

        lsp = {
          enable = true;
          server = "nixd";
        };

        format = {
          enable = true;
          type = "alejandra";
        };

        extraDiagnostics.enable = true;
        # extraDiagnostics.types = [ "statix" "deadnix" ];
      };

      vim.extraPlugins = with pkgs.vimPlugins; {
        catppuccin = {
          package = pkgs.vimPlugins.catppuccin-nvim;
          setup = ''
            require("catppuccin").setup({
              flavour = "mocha",
              transparent_background = true,
              color_overrides = {
                mocha = {
                  rosewater = "#ddc7a1",
                  flamingo  = "#ea6962",
                  pink      = "#7daea3",
                  mauve     = "#e78a4e",
                  red       = "#c14a4a",
                  maroon    = "#e78a4e",
                  peach     = "#d3869b",
                  yellow    = "#d4be98",
                  green     = "#a9b665",
                  teal      = "#89b482",
                  sky       = "#a9b665",
                  sapphire  = "#458588",
                  blue      = "#7daea3",
                  lavender  = "#7daea3",
                  text      = "#d4be98",
                  subtext1  = "#458588",
                  subtext0  = "#928374",
                  overlay2  = "#928374",
                  overlay1  = "#7c6f64",
                  overlay0  = "#665c54",
                  surface2  = "#504945",
                  surface1  = "#458588",
                  surface0  = "#32302f",
                  base      = "#1d2021",
                  mantle    = "#141414",
                  crust     = "#141414",
                },
              },
              integrations = {
                enabled = true,
                nvimtree = {
                  transparent_panel = true,
                  show_root = true,
                },

                hop = true,
                gitsigns = true,
                telescope = true,
                treesitter = true,
                treesitter_context = true,
                ts_rainbow = true,
                fidget = true,
                alpha = true,
                leap = true,
                lsp_saga = true,
                markdown = true,
                noice = true,
                notify = true, -- nvim-notify
                which_key = true,
                navic = {
                  enabled = true,
                  custom_bg = "NONE",
                },
                aerial = true,
                cmp = true,
                dashboard = true,
                flash = true,
                headlines = true,
                illuminate = true,
                indent_blankline = { enabled = true },
                lsp_trouble = true,
                mason = true,
                mini = true,
                native_lsp = {
                  enabled = true,
                  underlines = {
                    errors = { "undercurl" },
                    hints = { "undercurl" },
                    warnings = { "undercurl" },
                    information = { "undercurl" },
                  },
                },
                neotest = true,
                neotree = true,
                semantic_tokens = true,
              },
            })
            vim.cmd.colorscheme("catppuccin")
          '';
        };
        nui = {package = nui-nvim;};
        devicons = {package = nvim-web-devicons;};
        neoTree = {
          package = neo-tree-nvim;
          after = ["nui" "devicons"];
          setup = ''
            require("neo-tree").setup({
              sources = { "filesystem", "buffers", "git_status" },
              filesystem = { follow_current_file = { enabled = true } },
              window = { width = 32 },
            })
          '';
        };

        comment = {
          package = comment-nvim;
          setup = ''require("Comment").setup({})'';
        };
        tsCtxComment = {
          package = nvim-ts-context-commentstring;
          after = ["comment"];
          setup = ''
            -- Let ts-context-commentstring drive commentstring where applicable
            vim.g.skip_ts_context_commentstring_module = true
            require("ts_context_commentstring").setup({})
          '';
        };

        miniSurround = {
          package = mini-surround;
          setup = ''require("mini.surround").setup()'';
        };

        autopairs = {
          package = nvim-autopairs;
          setup = ''require("nvim-autopairs").setup({})'';
        };

        flash = {
          package = flash-nvim;
          setup = ''require("flash").setup({})'';
        };

        telescopeFzfNative = {
          package = telescope-fzf-native-nvim;
          after = ["telescope"];
          setup = ''
            pcall(function()
              require("telescope").load_extension("fzf")
            end)
          '';
        };

        tsTextobjects = {
          package = nvim-treesitter-textobjects;
          after = [
            /*
            depends on treesitter
            */
          ];
          setup = ''-- defaults are fine; plugin just needs to be present'';
        };

        aerial = {
          package = aerial-nvim;
          setup = ''require("aerial").setup({})'';
        };
      };

      vim.maps.normal = {
        "<leader>e" = {
          action = "<cmd>Neotree toggle<cr>";
          desc = "Explorer (Neo-tree)";
        };
        "<leader>ff" = {
          action = "<cmd>Telescope find_files<cr>";
          desc = "Find files";
        };
        "<leader>fg" = {
          action = "<cmd>Telescope live_grep<cr>";
          desc = "Grep";
        };
        # "s"         = { action = function: "lua", lua = "require('flash').jump()", desc = "Flash jump"; };
      };

      vim.keymaps = [
        {
          key = "<C-h>";
          mode = ["n"];
          action = "<C-w>h";
          desc = "Go to Left Window";
          silent = true;
        }
        {
          key = "<C-j>";
          mode = ["n"];
          action = "<C-w>j";
          desc = "Go to Lower Window";
          silent = true;
        }
        {
          key = "<C-k>";
          mode = ["n"];
          action = "<C-w>k";
          desc = "Go to Upper Window";
          silent = true;
        }
        {
          key = "<C-l>";
          mode = ["n"];
          action = "<C-w>l";
          desc = "Go to Right Window";
          silent = true;
        }
        {
          key = "<C-Up>";
          mode = ["n"];
          action = ":resize +2<CR>";
          desc = "Increase Window Height";
          silent = true;
        }
        {
          key = "<C-Down>";
          mode = ["n"];
          action = ":resize -2<CR>";
          desc = "Decrease Window Height";
          silent = true;
        }
        {
          key = "<C-Left>";
          mode = ["n"];
          action = ":vertical resize -2<CR>";
          desc = "Decrease Window Width";
          silent = true;
        }
        {
          key = "<C-Right>";
          mode = ["n"];
          action = ":vertical resize +2<CR>";
          desc = "Increase Window Width";
          silent = true;
        }
        {
          key = "<A-j>";
          mode = ["n"];
          action = ":m .+1<CR>==";
          desc = "Move Line Down";
          silent = true;
        }
        {
          key = "<A-k>";
          mode = ["n"];
          action = ":m .-2<CR>==";
          desc = "Move Line Up";
          silent = true;
        }
        {
          key = "<S-h>";
          mode = ["n"];
          action = ":bprevious<CR>";
          desc = "Previous Buffer";
          silent = true;
        }
        {
          key = "<S-l>";
          mode = ["n"];
          action = ":bnext<CR>";
          desc = "Next Buffer";
          silent = true;
        }
        {
          key = "<leader>bd";
          mode = ["n"];
          action = ":bdelete<CR>";
          desc = "Delete Buffer";
          silent = true;
        }
        {
          key = "<leader>e";
          mode = ["n"];
          action = ":Neotree toggle<CR>";
          desc = "File Explorer";
          silent = true;
        }
        {
          key = "<leader>ff";
          mode = ["n"];
          action = ":Telescope find_files<CR>";
          desc = "Find Files";
          silent = true;
        }
        {
          key = "<leader>fg";
          mode = ["n"];
          action = ":Telescope live_grep<CR>";
          desc = "Grep in Files";
          silent = true;
        }
        {
          key = "<leader>qq";
          mode = ["n"];
          action = ":qa<CR>";
          desc = "Quit All";
          silent = true;
        }
      ];
    };
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      unbind-key C-b
      set-option -g prefix C-Space
      bind-key C-Space send-prefix
    '';
  };

  programs.lazygit = {
    enable = true;
  };

  programs.git = {
    enable = true;
  };

  programs.waybar = {
    enable = true;

    systemd.enable = true;

    # Waybar JSON settings (module layout & behavior)
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        margin = "0 0 6 0";

        # Use your Nerd Font
        "font-family" = "MonaspiceNe Nerd Font";
        "font-size" = 12;

        # Modules
        modules-left = ["hyprland/workspaces" "window"];
        modules-center = ["clock"];
        modules-right = ["pulseaudio" "network" "battery" "tray"];

        "hyprland/workspaces" = {
          "all-outputs" = true;
          "format" = "{name}";
        };

        window.format = "{title}";
        window.max-length = 50;

        clock = {
          format = "{:%a %Y-%m-%d  %H:%M}";
          tooltip = false;
        };

        network = {
          format-wifi = "  {essid} {signal}%";
          format-ethernet = "󰈁  {ifname}";
          format-disconnected = "󰤭  offline";
          tooltip = true;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟  muted";
          "format-icons" = {default = ["" "" ""];};
          tooltip = false;
        };

        battery = {
          format = "{icon} {capacity}%";
          "format-icons" = ["󰁺" "󰁼" "󰁿" "󰂂" "󰁹"];
          tooltip = true;
        };

        tray = {
          icon-size = 18;
          spacing = 8;
        };
      };
    };

    # CSS theme using your palette
    style = ''
      /* === Your palette === */
      @define-color base      #1d2021;
      @define-color mantle    #141414;
      @define-color crust     #141414;
      @define-color surface0  #32302f;
      @define-color surface1  #458588;
      @define-color surface2  #504945;
      @define-color overlay0  #665c54;
      @define-color overlay1  #7c6f64;
      @define-color overlay2  #928374;
      @define-color subtext0  #928374;
      @define-color subtext1  #458588;
      @define-color text      #d4be98;
      @define-color rosewater #ddc7a1;
      @define-color flamingo  #ea6962;
      @define-color red       #c14a4a;
      @define-color peach     #d3869b;
      @define-color yellow    #d4be98;
      @define-color green     #a9b665;
      @define-color teal      #89b482;
      @define-color blue      #7daea3;
      @define-color mauve     #e78a4e;
      @define-color sapphire  #458588;

      * {
        font-family: "MonaspiceNe Nerd Font";
        font-size: 12px;
      }

      window#waybar {
        background: @base;
        color: @text;
        border: 0px solid transparent;
      }

      #workspaces button {
        color: @subtext0;
        background: transparent;
        padding: 0 8px;
        border-radius: 6px;
      }
      #workspaces button.active {
        background: @surface0;
        color: @text;
      }
      #workspaces button:hover {
        background: @surface1;
        color: @base;
      }

      #window, #clock, #network, #pulseaudio, #battery, #tray {
        padding: 6px 10px;
        margin: 4px 6px;
        border-radius: 8px;
        background: @surface0;
        color: @text;
      }

      #clock { background: @surface1; color: @base; }
      #network.disconnected { background: @overlay0; color: @rosewater; }
      #pulseaudio.muted { background: @overlay0; color: @overlay2; }
      #battery.critical { background: @red; color: @base; }
    '';
  };

  programs.firefox = {
    enable = true;
  };
  nixpkgs.config.allowUnfree = true;
}
