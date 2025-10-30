return {
  -- Use your config directory as a "local plugin" root so `require("copyfiles")` is found
  dir = vim.fn.stdpath("config") .. "/lua",
  name = "copyfiles-local",
  -- Load on VeryLazy or at startup; change event if you want lazier loading
  lazy = false,
  config = function()
    require("copyfiles").setup()
  end,
}
