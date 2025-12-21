vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

-- vim.keymap.set('n', '<S-l>', ':bnext<CR>', { desc = "Next buffer" })
-- vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { desc = "Previous buffer" })
vim.keymap.set('n', '<Leader>bd', ':bd<CR>', { desc = "Delete buffer" })

vim.keymap.set('n', '<Leader>sn', ':vsplit<CR>', { desc = "Create split" })
vim.keymap.set('n', '<C-\\>', ':vsplit<CR>', { desc = "Create split" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Next split" })
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Previous split" })
vim.keymap.set('n', '<Leader>sd', ':q<CR>', { desc = "Delete split" })
