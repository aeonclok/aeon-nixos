{
  lib,
  pkgs,
  ...
}: let
  mkLuaInline = lib.generators.mkLuaInline;
in {
  programs.nvf = {
    enable = true;
    enableManpages = true;

    settings = {
      vim.extraPackages = with pkgs; [ripgrep fd git];
      vim.clipboard.enable = true;
      vim.clipboard.registers = "unnamedplus";
      vim.clipboard.providers.wl-copy.enable = true;

      vim.theme.enable = false;

      vim.lsp.enable = true;
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          format_on_save = {
            lsp_fallback = true;
            timeout_ms = 1000;
          };
          formatters = {
            alejandra = {command = "${pkgs.alejandra}/bin/alejandra";};
          };
          formatters_by_ft = {nix = ["alejandra"];};
        };
      };

      vim.mini.ai.enable = true;
      vim.mini.align.enable = true;
      vim.mini.comment.enable = true;
      vim.mini.completion = {
        enable = true;
        setupOpts = {
          lsp_completion = {
            source_func = "omnifunc";
            auto_setup = true;
          };
          mappings = {
            force_twostep = "<C-Space>";
            confirm = "<CR>";
          };
        };
      };
      # vim.mini.keymap.enable = true;
      vim.mini.move.enable = true;
      vim.mini.operators.enable = true;
      vim.mini.pairs.enable = true;
      vim.mini.snippets.enable = true;
      vim.mini.splitjoin.enable = true;
      vim.mini.surround.enable = true;
      vim.mini.basics.enable = true;
      vim.mini.bracketed.enable = true;
      vim.mini.bufremove.enable = true;

      vim.mini.clue = {
        setupOpts = {
          triggers = [
            {
              mode = "n";
              keys = "s";
            }
            {
              mode = "n";
              keys = "<Leader>";
            }
            {
              mode = "x";
              keys = "<Leader>";
            }
            {
              mode = "i";
              keys = "<C-x>";
            }
            {
              mode = "n";
              keys = "g";
            }
            {
              mode = "x";
              keys = "g";
            }
            {
              mode = "n";
              keys = "'";
            }
            {
              mode = "n";
              keys = "`";
            }
            {
              mode = "x";
              keys = "'";
            }
            {
              mode = "x";
              keys = "`";
            }
            {
              mode = "n";
              keys = "\"";
            }
            {
              mode = "x";
              keys = "\"";
            }
            {
              mode = "i";
              keys = "<C-r>";
            }
            {
              mode = "c";
              keys = "<C-r>";
            }
            {
              mode = "n";
              keys = "<C-w>";
            }
            {
              mode = "n";
              keys = "z";
            }
            {
              mode = "x";
              keys = "z";
            }
          ];

          clues = [
            (mkLuaInline "require('mini.clue').gen_clues.builtin_completion()")
            (mkLuaInline "require('mini.clue').gen_clues.g()")
            (mkLuaInline "require('mini.clue').gen_clues.marks()")
            (mkLuaInline "require('mini.clue').gen_clues.registers()")
            (mkLuaInline "require('mini.clue').gen_clues.windows()")
            (mkLuaInline "require('mini.clue').gen_clues.z()")
          ];
        };
      };

      # vim.mini.deps.enable = true;
      vim.mini.diff.enable = true;
      vim.mini.extra.enable = true;
      vim.mini.files.enable = true;
      vim.mini.git.enable = true;
      vim.mini.jump.enable = true;
      # vim.mini.jump2d.enable = true;
      vim.mini.misc.enable = true;
      vim.mini.pick.enable = true;
      vim.mini.sessions.enable = true;
      vim.mini.visits.enable = true;
      vim.mini.animate.enable = true;
      # vim.mini.base16.enable = true;
      vim.mini.colors.enable = true;
      vim.mini.cursorword.enable = true;
      vim.mini.hipatterns.enable = true;
      # vim.mini.hues.enable = true;
      vim.mini.icons.enable = true;
      vim.mini.indentscope.enable = true;
      vim.mini.map.enable = true;
      vim.mini.notify.enable = true;
      vim.mini.starter.enable = true;
      vim.mini.statusline.enable = true;
      vim.mini.tabline.enable = true;
      vim.mini.trailspace.enable = true;
      vim.mini.doc.enable = true;
      vim.mini.fuzzy.enable = true;
      vim.mini.test.enable = true;

      vim.languages.nix = {
        enable = true;

        lsp = {
          enable = true;
          server = "nixd";
        };

        extraDiagnostics.enable = true;
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
      };

      vim.maps.normal = {
        "<leader>ff" = {
          action = "<cmd>lua require('mini.pick').builtin.files()<CR>";
          desc = "Find files";
        };
        "<leader>fg" = {
          action = "<cmd>lua require('mini.pick').builtin.grep_live()<CR>";
          desc = "Live grep";
        };
        "<leader>fb" = {
          action = "<cmd>lua require('mini.pick').builtin.buffers()<CR>";
          desc = "Buffers";
        };
        "<leader>fh" = {
          action = "<cmd>lua require('mini.pick').builtin.help()<CR>";
          desc = "Help tags";
        };
        "<leader>e" = {
          action = "<cmd>lua require('mini.files').open()<CR>";
          desc = "File browser";
        };
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
          action = ":resize -2<CR>";
          mode = ["n"];
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
          desc = "Delete Buffer (preserve windows)";
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
}
