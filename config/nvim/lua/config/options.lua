-- https://github.com/DanteDogDev/ToastVim/blob/main/lua/toastvim/config/options.lua
vim.opt.swapfile = false

-- Configure tabs
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

-- Display spaces and tabs
vim.opt.list = true
vim.opt.listchars = {
	tab = "→ ",
	trail = "•",
	lead = "·",
	multispace = "·",
	nbsp = "␣",
}

