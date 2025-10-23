{ lib, config, pkgs, ... }:
let
  mkLuaInline = lib.generators.mkLuaInline;
in
{
  programs.nvf = {
  enable = true;
  enableManpages = true;

  settings = {
    vim.extraPackages = with pkgs; [ ripgrep fd git ];
    # vim.opt.clipboard = "unnamedplus";
    vim.theme.enable = false;

    # vim.autocomplete.blink-cmp.enable = true;
    # vim.telescope.enable = true;
    # vim.binds.whichKey.enable = true;
    #
    # vim.statusline.lualine.enable = true;
    # vim.tabline.nvimBufferline.enable = true;
    #
    # vim.git.gitsigns.enable = true;
    #
    # vim.ui.noice.enable = true;
   # vim.notify.nvim-notify.enable = true;
    #
    # # vim.diagnostics.trouble.enable = true;
    #
    # vim.notes.todo-comments.enable = true;
    #
    # vim.treesitter.enable = true;
    vim.lsp.enable = true;

    vim.mini.ai.enable = true;
    vim.mini.align.enable = true;
    vim.mini.comment.enable = true;
    vim.mini.completion.enable = true;
    # vim.mini.keymap.enable = true;
    vim.mini.move.enable = true;
    vim.mini.operators.enable = true;
    vim.mini.pairs.enable = true;
    vim.mini.snippets.enable = true;
    vim.mini.splitjoin.enable = true;
    vim.mini.surround.enable  = true;
    vim.mini.basics.enable = true;
    vim.mini.bracketed.enable = true;
    vim.mini.bufremove.enable = true;

    vim.mini.clue = {
      enable = true;
      setupOpts = {
        # exactly your triggers
        triggers = [
          { mode = "n"; keys = "<Leader>"; }
          { mode = "x"; keys = "<Leader>"; }
          { mode = "i"; keys = "<C-x>"; }
          { mode = "n"; keys = "g"; }
          { mode = "x"; keys = "g"; }
          { mode = "n"; keys = "'"; }
          { mode = "n"; keys = "`"; }
          { mode = "x"; keys = "'"; }
          { mode = "x"; keys = "`"; }
          { mode = "n"; keys = "\""; }
          { mode = "x"; keys = "\""; }
          { mode = "i"; keys = "<C-r>"; }
          { mode = "c"; keys = "<C-r>"; }
          { mode = "n"; keys = "<C-w>"; }
          { mode = "n"; keys = "z"; }
          { mode = "x"; keys = "z"; }
        ];

        # the generated clue sets – emitted as Lua calls
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
    vim.mini.jump2d.enable = true;
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
        after = [ "telescope" ];
        setup = ''
          pcall(function()
            require("telescope").load_extension("fzf")
          end)
        '';
      };

      tsTextobjects = {
        package = nvim-treesitter-textobjects;
        after = [ /* depends on treesitter */ ];
        setup = ''-- defaults are fine; plugin just needs to be present'';
      };

      aerial = {
        package = aerial-nvim;
        setup = ''require("aerial").setup({})'';
      };
    };

    vim.maps.normal = {
      # "<leader>e" = { action = "<cmd>Neotree toggle<cr>"; desc = "Explorer (Neo-tree)"; };
      # "<leader>ff" = { action = "<cmd>Telescope find_files<cr>"; desc = "Find files"; };
      # "<leader>fg" = { action = "<cmd>Telescope live_grep<cr>";  desc = "Grep"; };
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
        # {
        #   key = "<A-j>";
        #   mode = [ "n" ];
        #   action = ":m .+1<CR>==";
        #   desc = "Move Line Down";
        #   silent = true;
        # }
        # {
        #   key = "<A-k>";
        #   mode = [ "n" ];
        #   action = ":m .-2<CR>==";
        #   desc = "Move Line Up";
        #   silent = true;
        # }
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
}

