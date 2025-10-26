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
      vim = {
        extraPackages = with pkgs; [
          ripgrep
          fd
          git
          nodePackages.typescript
          nodePackages."@vue/language-server"
          nodePackages.typescript-language-server
          nodePackages.vscode-langservers-extracted
          nodePackages.prettier
          nodePackages.eslint_d
          vue-language-server
          vtsls
          nodejs_20
        ];
        clipboard.enable = true;
        clipboard.registers = "unnamedplus";
        clipboard.providers.wl-copy.enable = true;

        theme.enable = false;

        languages.nix = {
          enable = true;
          lsp = {
            enable = true;
            server = "nixd";
          };
          extraDiagnostics.enable = true;
        };

        lsp = {
          # Define servers using Neovim 0.11 APIs via NVF
          enable = true;
          trouble.enable = true;
          servers = {
            vtsls = {
              filetypes = ["typescript" "javascript" "typescriptreact" "javascriptreact" "vue"];
              # You can pass arbitrary fields; they'll be forwarded to vim.lsp.config()
              settings = {
                vtsls = {
                  tsserver = {
                    globalPlugins = [
                      {
                        name = "@vue/typescript-plugin";
                        location = "${pkgs.nodePackages_latest."@vue/language-server"}/lib/node_modules/@vue/language-server";
                        languages = ["vue"];
                        configNamespace = "typescript";
                      }
                    ];
                  };
                };
              };
            };

            # vue_ls can be empty if you're on recent versions that don’t need on_init hacks
            vue_ls = {};
          };
        };

        # Turn on Tree-sitter and make sure vue grammar is present
        treesitter = {
          enable = true; # enables nvim-treesitter in NVF
          grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            vue
            typescript
            tsx
            javascript
            html
            css
          ];
        };

        # Tiny Lua stub to actually enable the servers (Neovim 0.11 API)
        # luaConfigRC = ''
        #   vim.lsp.enable({'vtsls','vue_ls'})
        # '';

        # languages.ts = {
        #   enable = true;
        #   lsp.enable = true;
        # };

        languages.html.enable = true;
        languages.css.enable = true;

        # lsp.servers = {
        #   ts_ls.enable = true;
        #   vue_ls = {
        #     # ts_ls = {
        #     enable = true;
        #     filetypes = [
        #       "typescript"
        #       "javascript"
        #       "typescriptreact"
        #       "javascriptreact"
        #       "vue"
        #     ];
        #     initOptions.typescript.tsdk = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib";
        #     # initOptions.plugins = [
        #     #   {
        #     #     name = "@vue/typescript-plugin";
        #     #     location = "${pkgs.nodePackages."@vue/language-server"}/lib/node_modules/@vue/language-server";
        #     #     languages = ["vue"];
        #     #   }
        #     # ];
        #     # preferences = {preferGoToSourceDefinition = true;}; # <-- add this
        #   };
        # };

        formatter.conform-nvim = {
          enable = true;
          setupOpts = {
            format_on_save = {
              lsp_fallback = true;
              timeout_ms = 1000;
            };
            formatters = {
              alejandra = {command = "${pkgs.alejandra}/bin/alejandra";};
              prettier = {command = "${pkgs.nodePackages.prettier}/bin/prettier";};
            };
            formatters_by_ft = {
              nix = ["alejandra"];
              vue = ["prettier"];
              typescript = ["prettier"];
              javascript = ["prettier"];
              html = ["prettier"];
              css = ["prettier"];
              json = ["prettier"];
            };
          };
        };

        mini.ai.enable = true;
        mini.align.enable = true;
        mini.comment.enable = true;
        mini.completion = {
          enable = true;
          setupOpts = {
            lsp_completion = {
              source_func = "omnifunc";
              auto_setup = true;
            };
            mappings = {
              force_twostep = "<c-space>";
              confirm = "<cr>";
            };
          };
        };
        # mini.keymap.enable = true;
        mini.move.enable = true;
        mini.operators.enable = true;
        mini.pairs.enable = true;
        mini.snippets.enable = true;
        mini.splitjoin.enable = true;
        mini.surround.enable = true;
        mini.basics.enable = true;
        mini.bracketed.enable = true;
        mini.bufremove.enable = true;

        mini.clue = {
          enable = true;
          setupOpts = {
            triggers = [
              {
                mode = "n";
                keys = "s";
              }
              {
                mode = "n";
                keys = "<leader>";
              }
              {
                mode = "x";
                keys = "<leader>";
              }
              {
                mode = "i";
                keys = "<c-x>";
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
                keys = "<c-r>";
              }
              {
                mode = "c";
                keys = "<c-r>";
              }
              {
                mode = "n";
                keys = "<c-w>";
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
              # (mkluainline "require('mini.clue').gen_clues.builtin_completion()")
              # (mkluainline "require('mini.clue').gen_clues.g()")
              # (mkluainline "require('mini.clue').gen_clues.marks()")
              # (mkluainline "require('mini.clue').gen_clues.registers()")
              # (mkluainline "require('mini.clue').gen_clues.windows()")
              # (mkluainline "require('mini.clue').gen_clues.z()")
            ];
          };
        };

        # mini.deps.enable = true;
        mini.diff.enable = true;
        mini.extra.enable = true;
        mini.files.enable = true;
        mini.git.enable = true;
        mini.jump.enable = true;
        # mini.jump2d.enable = true;
        mini.misc.enable = true;
        mini.pick.enable = true;
        mini.sessions.enable = true;
        mini.visits.enable = true;
        mini.animate.enable = true;
        # mini.base16.enable = true;
        mini.colors.enable = true;
        mini.cursorword.enable = true;
        mini.hipatterns.enable = true;
        # mini.hues.enable = true;
        mini.icons.enable = true;
        mini.indentscope.enable = true;
        mini.map.enable = true;
        mini.notify = {
          enable = true;
        };
        mini.starter.enable = true;
        mini.statusline.enable = true;
        mini.tabline.enable = true;
        mini.trailspace.enable = true;
        mini.doc.enable = true;
        mini.fuzzy.enable = true;
        mini.test.enable = true;

        extraPlugins = with pkgs.vimPlugins; {
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
                  notify = true,
                  which_key = true,
                  navic = {
                    enabled = true,
                    custom_bg = "none",
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

        maps.normal = {
          "<leader>gd" = {
            action = "<cmd>lua vim.lsp.buf.definition()<cr>";
            desc = "go to definition";
          };
          "<leader>ff" = {
            action = "<cmd>lua require('mini.pick').builtin.files()<cr>";
            desc = "find files";
          };
          "<leader>fg" = {
            action = "<cmd>lua require('mini.pick').builtin.grep_live()<cr>";
            desc = "live grep";
          };
          "<leader>fb" = {
            action = "<cmd>lua require('mini.pick').builtin.buffers()<cr>";
            desc = "buffers";
          };
          "<leader>fh" = {
            action = "<cmd>lua require('mini.pick').builtin.help()<cr>";
            desc = "help tags";
          };
          "<leader>e" = {
            action = "<cmd>lua require('mini.files').open()<cr>";
            desc = "file browser";
          };
        };

        keymaps = [
          {
            key = "<c-h>";
            mode = ["n"];
            action = "<c-w>h";
            desc = "go to left window";
            silent = true;
          }
          {
            key = "<c-j>";
            mode = ["n"];
            action = "<c-w>j";
            desc = "go to lower window";
            silent = true;
          }
          {
            key = "<c-k>";
            mode = ["n"];
            action = "<c-w>k";
            desc = "go to upper window";
            silent = true;
          }
          {
            key = "<c-l>";
            mode = ["n"];
            action = "<c-w>l";
            desc = "go to right window";
            silent = true;
          }
          {
            key = "<c-up>";
            mode = ["n"];
            action = ":resize +2<cr>";
            desc = "increase window height";
            silent = true;
          }
          {
            key = "<c-down>";
            action = ":resize -2<cr>";
            mode = ["n"];
            desc = "decrease window height";
            silent = true;
          }
          {
            key = "<c-left>";
            mode = ["n"];
            action = ":vertical resize -2<cr>";
            desc = "decrease window width";
            silent = true;
          }
          {
            key = "<c-right>";
            mode = ["n"];
            action = ":vertical resize +2<cr>";
            desc = "increase window width";
            silent = true;
          }
          {
            key = "<s-h>";
            mode = ["n"];
            action = ":bprevious<cr>";
            desc = "previous buffer";
            silent = true;
          }
          {
            key = "<s-l>";
            mode = ["n"];
            action = ":bnext<cr>";
            desc = "next buffer";
            silent = true;
          }
          {
            key = "<leader>bd";
            mode = ["n"];
            action = ":bdelete<cr>";
            desc = "delete buffer (preserve windows)";
            silent = true;
          }
          {
            key = "<leader>qq";
            mode = ["n"];
            action = ":qa<cr>";
            desc = "quit all";
            silent = true;
          }
        ];
      };
    };
  };
  # home.packages = [
  #   pkgs.nodePackages_latest.vtsls
  #   pkgs.nodePackages_latest."@vue/language-server"
  # ];
}
