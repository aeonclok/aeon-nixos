-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Clipboard follows whoever is at the keyboard (clip-copy/clip-paste from
-- modules/home/tmux.nix): the Wayland clipboard when sitting at this machine,
-- the remote terminal's clipboard via OSC 52 when attached over SSH/tmux.
-- Overrides LazyVim's default of turning the clipboard off under SSH.
if vim.fn.executable("clip-copy") == 1 and vim.fn.executable("clip-paste") == 1 then
  vim.g.clipboard = {
    name = "clip",
    copy = { ["+"] = { "clip-copy" }, ["*"] = { "clip-copy" } },
    paste = { ["+"] = { "clip-paste" }, ["*"] = { "clip-paste" } },
    cache_enabled = 0,
  }
  vim.opt.clipboard = "unnamedplus"
end
