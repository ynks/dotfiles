-- Sets line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = false

-- Line colors
vim.api.nvim_set_hl(0, "LineNr", { fg = "black", bg = "NvimLightGray4", bold = true})
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "NvimDarkGray4", bg = "NONE", bold = false})
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "NvimDarkGray4", bg = "NONE", bold = false})

-- Configure tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = false

-- Display spaces and tabs
vim.opt.list = true
vim.opt.listchars = {
	tab = "->",
	trail = "•",
	lead = "·",
	multispace = "·",
	nbsp = "␣",
}

-- Clipboard
vim.opt.clipboard = "unnamedplus"

