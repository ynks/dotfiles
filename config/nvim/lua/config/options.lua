-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.expandtab = false  -- use real tabs, not spaces
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.softtabstop = 3

vim.opt.list = true
vim.opt.listchars = {
  tab = "→ ",
  space = "·",   -- middle dot for regular spaces
  trail = "●",   -- filled circle (larger) for trailing spaces
  nbsp = "␣",
}
