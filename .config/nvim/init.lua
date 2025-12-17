require("config.options")
require("config.keybinds")
require("config.lsp")
require("config.lazy")

vim.lsp.enable({"lua_ls", "clangd", "rust_analyzer"})

