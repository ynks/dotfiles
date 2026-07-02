-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader><leader>", function()
  Snacks.picker("smart")
end, { desc = "Search Everywhere" })

vim.keymap.set("n", "<leader>/", function()
  Snacks.picker("grep")
end, { desc = "Search in files (grep)" })
