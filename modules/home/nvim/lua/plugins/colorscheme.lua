return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    priority = 1000,
    -- version = "v1.11.0",
    opts = {
      color_overrides = {
        all = {
          rosewater_original = "#f4dbd6", -- hsl(10deg, 58%, 90%) - Subtle highlights
          rosewater = "#ddc7a1", -- Gruvbox Material (fg1) - Secondary text, subtle highlights

          flamingo_original = "#f0c6c6", -- hsl(0deg, 58%, 86%) - Often used for warnings
          flamingo = "#ea6962", -- Gruvbox Material (red) - Critical symbols, keywords, errors

          pink_original = "#f5bde6", -- hsl(316deg, 74%, 85%) - Escape sequences, Regex
          pink = "#7daea3", -- Gruvbox Material (purple) - Constants, numbers, special symbols

          mauve_original = "#c6a0f6", -- hsl(267deg, 83%, 80%) - Keywords
          mauve = "#e78a4e", -- Gruvbox Material (red) - Keywords, critical text

          red_original = "#ed8796", -- hsl(351deg, 74%, 73%) - Symbols, Atoms, Builtins
          red = "#c14a4a", -- Gruvbox Material (dark red) - Parameters, warnings

          maroon_original = "#ee99a0", -- hsl(355deg, 71%, 77%) - Parameters
          maroon = "#e78a4e", -- Gruvbox Material (orange) - Numbers, constants

          peach_original = "#f5a97f", -- hsl(21deg, 86%, 73%) - Constants, Numbers
          peach = "#d3869b", -- Gruvbox Material (yellow) - Strings, annotations

          yellow_original = "#eed49f", -- hsl(40deg, 70%, 78%) - Classes, Enums, Annotations
          yellow = "#d4be98", -- Gruvbox Material (fg0) - Primary text, classes

          green_original = "#a6da95", -- hsl(105deg, 48%, 72%) - Strings
          green = "#a9b665", -- Gruvbox Material (green) - Tags, attributes, variables

          teal_original = "#8bd5ca", -- hsl(171deg, 47%, 69%) - Enum Variants
          teal = "#89b482", -- Gruvbox Material (aqua) - Enum variants, operators

          sky_original = "#91d7e3", -- hsl(189deg, 59%, 73%) - Operators
          sky = "#a9b665", -- Gruvbox Material (blue) - Methods, functions, operators

          sapphire_original = "#7dc4e4", -- hsl(199deg, 66%, 69%) - Alternative to sky for cooler tones
          sapphire = "#458588", -- Gruvbox Material (dark aqua) - Highlighted operators, accents

          blue_original = "#8aadf4", -- hsl(220deg, 83%, 75%) - Methods, Functions, Properties
          blue = "#7daea3", -- Gruvbox Material (blue) - Methods, properties, classes

          lavender_original = "#b7bdf8", -- hsl(234deg, 82%, 85%) - Highlight for subtle keywords
          lavender = "#7daea3", -- Gruvbox Material (fg2) - Tertiary text, muted elements

          text_original = "#cad3f5", -- hsl(227deg, 68%, 88%) - Primary text color
          text = "#d4be98", -- Gruvbox Material (fg0) - Primary text

          subtext1_original = "#b8c0e0", -- hsl(228deg, 39%, 80%) - Secondary muted text
          subtext1 = "#458588", -- Gruvbox Material (fg3) - Comments, secondary text

          subtext0_original = "#a5adcb", -- hsl(227deg, 27%, 72%) - Tertiary muted text
          subtext0 = "#928374", -- Gruvbox Material (fg4) - Even more muted text

          overlay2_original = "#939ab7", -- hsl(228deg, 20%, 65%) - Comments, Delimiters
          overlay2 = "#928374", -- Gruvbox Material (bg3) - Comments, delimiters

          overlay1_original = "#8087a2", -- hsl(228deg, 15%, 57%) - Slightly dimmer overlay
          -- overlay1 = "#458588", -- Gruvbox Material (fg5) - Dimmer text, UI elements
          overlay1 = "#7c6f64",

          overlay0_original = "#6e738d", -- hsl(230deg, 12%, 49%) - Even dimmer overlay
          -- overlay0 = "#458588", -- Gruvbox Material (bg_current_word) - Background highlights
          overlay0 = "#665c54",

          surface2_original = "#5b6078", -- hsl(230deg, 14%, 41%) - UI elements, line numbers
          -- surface2 = "#458588", -- Gruvbox Material (bg4) - UI elements, line numbers
          surface2 = "#504945",

          surface1_original = "#494d64", -- hsl(231deg, 16%, 34%) - Darker UI elements
          surface1 = "#458588", -- Gruvbox Material (bg_current_word) - Background highlights
          -- surface1 = "#3c3836",

          surface0_original = "#363a4f", -- hsl(230deg, 19%, 26%) - Background highlight
          -- surface0 = "#458588", -- Gruvbox Material (bg0) - Background
          surface0 = "#32302f",

          base_original = "#24273a", -- hsl(232deg, 23%, 18%) - Main background
          base = "#1d2021", -- Gruvbox Material (bg1) - Main background

          mantle_original = "#1e2030", -- hsl(233deg, 23%, 15%) - Secondary background
          mantle = "#141414", -- Gruvbox Material (bg_dim) - Secondary background

          crust_original = "#181926", -- hsl(236deg, 23%, 12%) - Deepest background
          crust = "#141414", -- Gruvbox Material (bg_dim) - Deepest background
        },
      },
      transparent_background = true,
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
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
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
  }, -- and this
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}

-- return {
--   -- add gruvbox
--   {
--     "sainnhe/gruvbox-material",
--     opts = {
--       transparent = true,
--       styles = {
--         sidebars = "transparent",
--         floats = "transparent",
--       },
--     },
--   },
--
--   -- Configure LazyVim to load gruvbox
--   {
--     "LazyVim/LazyVim",
--     opts = {
--       colorscheme = "gruvbox-material",
--     },
--   },
-- }
--
