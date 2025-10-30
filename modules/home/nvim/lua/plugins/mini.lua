return {
  -- Add mini.nvim
  {
    "nvim-mini/mini.nvim",
    version = false, -- Use the latest version (or set to "stable" if preferred)
    config = function()
      -- Configure the mini.nvim modules you want to use
      require("mini.operators").setup()
      })
    end,
  },

  -- Disable the LazyVim equivalents
  -- { "folke/flash.nvim", enabled = false },
  -- { "echasnovski/mini.surround", enabled = false }, -- If LazyVim already uses mini.surround
  { "numToStr/Comment.nvim", enabled = false }, -- To disable LazyVim's default comment plugin
}
