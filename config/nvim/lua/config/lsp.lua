-- https://github.com/neovim/nvim-lspconfig/tree/master/lsp

vim.filetype.add({
  extension = {
    dox = "doxygen",
  },
})

-- prettier,
vim.lsp.enable({ "emmylua_ls" }) -- lua_ls alternative
vim.lsp.enable({ "clangd" }) -- clangd
vim.lsp.enable({ "rust_analyzer"})
vim.lsp.enable({ "nixd" })
vim.lsp.enable({ "roslyn_ls" })
vim.lsp.enable({ "ts_ls" })
vim.lsp.enable({ "html" })
vim.lsp.enable({ "cssls" })
vim.lsp.enable({ "buff_ls" })
