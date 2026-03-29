---@type vim.lsp.Config
return {
	---@type lspconfig.settings.rust_analyzer
	settings = {
		['rust-analyzer'] = {
			cargo = {
				buildScripts = {
					enable = true,
				},
				loadOutDirsFromCheck = true,
			},
			procMacro = {
				enable = true,
			},
		},
	},
}
