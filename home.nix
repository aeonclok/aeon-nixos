

{ config, pkgs, ... }:
{
  home.username = "reima";
  home.homeDirectory = "/home/reima";
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      input = {
        kb_layout = "fi";
	repeat_rate = 50;
	repeat_delay = 300;
	mouse_refocus = false;
        touchpad = {
          natural_scroll = true;  # set to false for classic direction
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
      bind = [
        "$mod, Q, exec, wezterm"
        "$mod, C, killactive"
        "$mod, U, togglefloating"
        "$mod, F, fullscreen"
        "$mod, RETURN, exec, firefox"
      ]
            ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
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

config.color_scheme = "GruvboxDark"

config.font = wezterm.font({
	family = "MonaspiceNe NFM",
	harfbuzz_features = { "calt", "liga", "dlig", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08" },
})

config.font_size = 12

config.font_rules = {
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font({
			family = "MonaspiceNe NFM",
			weight = "Light",
			stretch = "Normal",
			style = "Italic",
			harfbuzz_features = {
				"calt",
				"liga",
				"dlig",
				"ss01",
				"ss02",
				"ss03",
				"ss04",
				"ss05",
				"ss06",
				"ss07",
				"ss08",
			},
		}),
	},

	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font({
			family = "MonaspiceNe NFM",
			weight = "Bold",
			stretch = "Normal",
			style = "Normal",
			harfbuzz_features = {
				"calt",
				"liga",
				"dlig",
				"ss01",
				"ss02",
				"ss03",
				"ss04",
				"ss05",
				"ss06",
				"ss07",
				"ss08",
			},
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
    # External tools (Telescope, etc.)
    vim.extraPackages = with pkgs; [ ripgrep fd git ];

    vim.theme.enable = false;

    # --- First-class nvf modules (keep these; paths are correct) ---
    vim.autocomplete.blink-cmp.enable = true;
    vim.telescope.enable = true;
    vim.binds.whichKey.enable = true;

    vim.statusline.lualine.enable = true;
    vim.tabline.nvimBufferline.enable = true;

    vim.git.gitsigns.enable = true;

    vim.ui.noice.enable = true;
    vim.notify.nvim-notify.enable = true;

    # Diagnostics dashboard (like LazyVim’s Trouble)
    # vim.diagnostics.trouble.enable = true;

    # TODO comments integration
    vim.notes.todo-comments.enable = true;

    # Treesitter base + LSP core
    vim.treesitter.enable = true;
    vim.lsp.enable = true;

    # --- Nix language pack ---
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
        # Runs in the extraPlugins DAG; no built-in setup will override this
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
      nui = { package = nui-nvim; };
      devicons = { package = nvim-web-devicons; };
      neoTree = {
        package = neo-tree-nvim;
        after = [ "nui" "devicons" ];
        setup = ''
          require("neo-tree").setup({
            sources = { "filesystem", "buffers", "git_status" },
            filesystem = { follow_current_file = { enabled = true } },
            window = { width = 32 },
          })
        '';
      };

      # Comment.nvim (+ ts-context-commentstring for TS/TSX)
      comment = {
        package = comment-nvim;
        setup = ''require("Comment").setup({})'';
      };
      tsCtxComment = {
        package = nvim-ts-context-commentstring;
        after = [ "comment" ];
        setup = ''
          -- Let ts-context-commentstring drive commentstring where applicable
          vim.g.skip_ts_context_commentstring_module = true
          require("ts_context_commentstring").setup({})
        '';
      };

      # mini.surround (LazyVim uses mini for many ops)
      miniSurround = {
        package = mini-surround;
        setup = ''require("mini.surround").setup()'';
      };

      # Autopairs (works fine with Blink without extra glue)
      autopairs = {
        package = nvim-autopairs;
        setup = ''require("nvim-autopairs").setup({})'';
      };

      # Flash.nvim (sneak-like jump used by LazyVim)
      flash = {
        package = flash-nvim;
        setup = ''require("flash").setup({})'';
      };

      # Telescope FZF native extension (faster sorting)
      telescopeFzfNative = {
        package = telescope-fzf-native-nvim;
        after = [ "telescope" ];
        setup = ''
          pcall(function()
            require("telescope").load_extension("fzf")
          end)
        '';
      };

      # Treesitter textobjects (used by many LazyVim mappings)
      tsTextobjects = {
        package = nvim-treesitter-textobjects;
        after = [ /* depends on treesitter */ ];
        setup = ''-- defaults are fine; plugin just needs to be present'';
      };

      # Aerial (symbols outline) – optional but very handy
      aerial = {
        package = aerial-nvim;
        setup = ''require("aerial").setup({})'';
      };
    };

    # --- Keymaps to feel closer to LazyVim (optional starter) ---
    vim.maps.normal = {
      "<leader>e" = { action = "<cmd>Neotree toggle<cr>"; desc = "Explorer (Neo-tree)"; };
      "<leader>ff" = { action = "<cmd>Telescope find_files<cr>"; desc = "Find files"; };
      "<leader>fg" = { action = "<cmd>Telescope live_grep<cr>";  desc = "Grep"; };
      # "s"         = { action = function: "lua", lua = "require('flash').jump()", desc = "Flash jump"; };
    };

      vim.keymaps = [
        {
          key = "<C-h>";
          mode = [ "n" ];
          action = "<C-w>h";
          desc = "Go to Left Window";
          silent = true;
        }
        {
          key = "<C-j>";
          mode = [ "n" ];
          action = "<C-w>j";
          desc = "Go to Lower Window";
          silent = true;
        }
        {
          key = "<C-k>";
          mode = [ "n" ];
          action = "<C-w>k";
          desc = "Go to Upper Window";
          silent = true;
        }
        {
          key = "<C-l>";
          mode = [ "n" ];
          action = "<C-w>l";
          desc = "Go to Right Window";
          silent = true;
        }
        {
          key = "<C-Up>";
          mode = [ "n" ];
          action = ":resize +2<CR>";
          desc = "Increase Window Height";
          silent = true;
        }
        {
          key = "<C-Down>";
          mode = [ "n" ];
          action = ":resize -2<CR>";
          desc = "Decrease Window Height";
          silent = true;
        }
        {
          key = "<C-Left>";
          mode = [ "n" ];
          action = ":vertical resize -2<CR>";
          desc = "Decrease Window Width";
          silent = true;
        }
        {
          key = "<C-Right>";
          mode = [ "n" ];
          action = ":vertical resize +2<CR>";
          desc = "Increase Window Width";
          silent = true;
        }
        {
          key = "<A-j>";
          mode = [ "n" ];
          action = ":m .+1<CR>==";
          desc = "Move Line Down";
          silent = true;
        }
        {
          key = "<A-k>";
          mode = [ "n" ];
          action = ":m .-2<CR>==";
          desc = "Move Line Up";
          silent = true;
        }
        {
          key = "<S-h>";
          mode = [ "n" ];
          action = ":bprevious<CR>";
          desc = "Previous Buffer";
          silent = true;
        }
        {
          key = "<S-l>";
          mode = [ "n" ];
          action = ":bnext<CR>";
          desc = "Next Buffer";
          silent = true;
        }
        {
          key = "<leader>bd";
          mode = [ "n" ];
          action = ":bdelete<CR>";
          desc = "Delete Buffer";
          silent = true;
        }
        {
          key = "<leader>e";
          mode = [ "n" ];
          action = ":Neotree toggle<CR>";
          desc = "File Explorer";
          silent = true;
        }
        {
          key = "<leader>ff";
          mode = [ "n" ];
          action = ":Telescope find_files<CR>";
          desc = "Find Files";
          silent = true;
        }
        {
          key = "<leader>fg";
          mode = [ "n" ];
          action = ":Telescope live_grep<CR>";
          desc = "Grep in Files";
          silent = true;
        }
        {
          key = "<leader>qq";
          mode = [ "n" ];
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
  programs.hyprpanel = {
    # Configure and theme almost all options from the GUI.
    # See 'https://hyprpanel.com/configuration/settings.html'.
    # Default: <same as gui>
    enable = true;
    settings = {

      # Configure bar layouts for monitors.
      # See 'https://hyprpanel.com/configuration/panel.html'.
      # Default: null
      layout = {
        bar.layouts = {
          "0" = {
            left = [ "dashboard" "workspaces" ];
            middle = [ "media" ];
            right = [ "volume" "systray" "notifications" ];
          };
        };
      };

      bar.launcher.autoDetectIcon = true;
      bar.workspaces.show_icons = true;

      menus.clock = {
        time = {
          military = true;
          hideSeconds = true;
        };
        weather.unit = "metric";
      };

      menus.dashboard.directories.enabled = false;
      menus.dashboard.stats.enable_gpu = true;

      theme.bar.transparent = true;

      theme.font = {
        name = "MonaspiceNe Nerd Font Light";
        size = "16px";
      };
    };
  };


  programs.firefox = {
    enable = true;
  };
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    pkgs.kitty
    pkgs.nerd-fonts.monaspace
    wget
  ];
}
