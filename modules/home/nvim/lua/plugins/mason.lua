return {
  "williamboman/mason.nvim",
  opts = {
    -- Put Mason’s shims at the END of PATH:
    -- so system/Nix tools (stylua, shfmt, etc.) win,
    -- while Mason LSP scripts are still found if not provided by Nix.
    PATH = "append",
  },
}
