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

        lsp.enable = true;

        treesitter = {
          enable = true;
          grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            vue
            typescript
            tsx
            javascript
            html
            css
          ];
        };

        pluginRC."vue-vtsls" = ''
          local function vue_ls_path()
            local exe = vim.fn.exepath('vue-language-server')
            if exe == "" then return nil end
            local root = vim.fn.fnamemodify(exe, ':h:h')
            local p1 = root .. '/lib/node_modules/@vue/language-server'
            if vim.uv.fs_stat(p1) then return p1 end
            local p2 = root .. '/lib/node_modules/vue-language-server/node_modules/@vue/language-server'
            if vim.uv.fs_stat(p2) then return p2 end
            return nil
          end

          local vue_language_server_path = vue_ls_path() or '/dev/null'
          local tsserver_filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' }
          local vue_plugin = {
            name = '@vue/typescript-plugin',
            location = vue_language_server_path,
            languages = { 'vue' },
            configNamespace = 'typescript',
          }

          local vtsls_config = {
            settings = {
              vtsls = {
                tsserver = {
                  globalPlugins = { vue_plugin },
                },
              },
            },
            filetypes = tsserver_filetypes,
          }

          local ts_ls_config = {
            init_options = { plugins = { vue_plugin } },
            filetypes = tsserver_filetypes,
          }

          local vue_ls_config = {
            on_init = function(client)
              client.handlers['tsserver/request'] = function(_, result, context)
                local ts_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = 'ts_ls' })
                local vtsls_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = 'vtsls' })
                local clients = {}
                vim.list_extend(clients, ts_clients)
                vim.list_extend(clients, vtsls_clients)
                if #clients == 0 then
                  vim.notify('Could not find `vtsls` or `ts_ls` lsp client, `vue_ls` would not work without it.', vim.log.levels.ERROR)
                  return
                end
                local ts_client = clients[1]
                local param = unpack(result)
                local id, command, payload = unpack(param)
                ts_client:exec_cmd({
                  title = 'vue_request_forward',
                  command = 'typescript.tsserverRequest',
                  arguments = { command, payload },
                }, { bufnr = context.bufnr }, function(_, r)
                  local response = r and r.body
                  local response_data = { { id, response } }
                  client:notify('tsserver/response', response_data)
                end)
              end
            end,
          }

          vim.lsp.config('vtsls', vtsls_config)
          vim.lsp.config('vue_ls', vue_ls_config)
          vim.lsp.config('ts_ls', ts_ls_config)
          vim.lsp.enable({ 'vtsls', 'vue_ls' })
        '';
        # languages.nix = {
        #   enable = true;
        #   lsp = {
        #     enable = true;
        #     server = "nixd";
        #   };
        #   extraDiagnostics.enable = true;
        # };
        # lsp = {
        #   lspconfig = {
        #     enable = true;
        #     sources = {
        #       vue_ls = ''
        #         vim.lsp.enable('vue_ls')
        #         vim.lsp.config('vue_ls', {})
        #       '';
        #       eslint = ''
        #         vim.lsp.enable('eslint')
        #         vim.lsp.config('eslint', {})
        #       '';
        #       ts_ls = ''
        #         vim.lsp.enable('ts_ls')
        #         vim.lsp.config('ts_ls', {
        #           ini:_options = {
        #             plugins = {
        #               {
        #                 name = "@vue/typescript-plugin",
        #                 location = "${pkgs.vue-language-server}/lib/node_modules/@vue/language-server",
        #                 languages = {"vue"},
        #               },
        #             },
        #           },
        #           filetypes = {
        #             "javascript",
        #             "typescript",
        #             "vue",
        #           },
        #         })
        #       '';
        #     };
        #   };
        # };
        # lsp = {
        #   # Define servers using Neovim 0.11 APIs via NVF
        #   enable = true;
        #   trouble.enable = true;
        #   servers = {
        #     vtsls = {
        #       filetypes = ["typescript" "javascript" "typescriptreact" "javascriptreact" "vue"];
        #       # You can pass arbitrary fields; they'll be forwarded to vim.lsp.config()
        #       settings = {
        #         vtsls = {
        #           tsserver = {
        #             globalPlugins = [
        #               {
        #                 name = "@vue/typescript-plugin";
        #                 location = "${pkgs.nodePackages_latest."@vue/language-server"}/lib/node_modules/@vue/language-server";
        #                 languages = ["vue"];
        #                 configNamespace = "typescript";
        #               }
        #             ];
        #           };
        #         };
        #       };
        #       # Mute vtsls diagnostics on *.vue (keep it attached for TS features)
        #       on_init = mkLuaInline ''
        #         function(client)
        #           client.handlers['tsserver/request'] = function(_, result, context)
        #             local vts = vim.lsp.get_clients({ bufnr = context.bufnr, name = 'vtsls' })
        #             if #vts == 0 then
        #               vim.notify('No vtsls client found; vue_ls TS features disabled', vim.log.levels.ERROR)
        #               return
        #             end
        #             local ts_client = vts[1]
        #             local param = unpack(result)
        #             local id, command, payload = unpack(param)
        #             ts_client:exec_cmd({
        #               title = 'vue_request_forward',
        #               command = 'typescript.tsserverRequest',
        #               arguments = { command, payload },
        #             }, { bufnr = context.bufnr }, function(_, r)
        #               local response = r and r.body
        #               local response_data = { { id, response } }
        #               client:notify('tsserver/response', response_data)
        #             end)
        #           end
        #         end
        #       '';
        #       on_attach = mkLuaInline ''
        #         function(client, bufnr)
        #           if vim.bo[bufnr].filetype == 'vue' then
        #             client.handlers['textDocument/publishDiagnostics'] = function() end
        #           end
        #         end
        #       '';
        #     };
        #
        #     # vue_ls can be empty if you're on recent versions that don’t need on_init hacks
        #     vue_ls = {
        #       filetypes = ["vue"];
        #       on_attach = mkLuaInline ''
        #         function(client, bufnr)
        #           if vim.bo[bufnr].filetype == 'vue' and client.server_capabilities.semanticTokensProvider then
        #             client.server_capabilities.semanticTokensProvider.full = true
        #           end
        #         end
        #       '';
        #     };
        #   };
        # };

        # Turn on Tree-sitter and make sure vue grammar is present
        # treesitter = {
        #   enable = true; # enables nvim-treesitter in NVF
        #   grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        #     vue
        #     typescript
        #     tsx
        #     javascript
        #     html
        #     css
        #   ];
        # };
        #
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
          # "<leader>gd" = {
          #   action = "<cmd>lua vim.lsp.buf.definition()<cr>";
          #   desc = "go to definition";
          # };
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
