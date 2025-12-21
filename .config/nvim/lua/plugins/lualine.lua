return {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	config = function()
		require('lualine').setup {
			options = {
				icons_enabled = true,
				theme = 'auto',
				component_separators = { left = '', right = ''},
				section_separators = { left = '', right = ''},
				always_divide_middle = true,
				always_show_tabline = true,
				globalstatus = false,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
					refresh_time = 16, -- ~60fps
					events = {
						'WinEnter',
						'BufEnter',
						'BufWritePost',
						'SessionLoadPost',
						'FileChangedShellPost',
						'VimResized',
						'Filetype',
						'CursorMoved',
						'CursorMovedI',
						'ModeChanged',
					}
				}
			},
			sections = {
				lualine_a = {{
					'mode',
					fmt = function(str)
						local map = {
							['NORMAL']  = 'N', ['O-PENDING'] = 'Op', ['INSERT']  = 'I',
							['VISUAL']  = 'V', ['V-BLOCK'] = 'VB', ['V-LINE']    = 'VL',
							['SELECT']  = 'S', ['S-LINE']  = 'SL', ['S-BLOCK']   = 'SB',
							['REPLACE'] = 'R', ['V-REPLACE'] = 'VR', ['COMMAND'] = 'C',
							['EX'] = 'X', ['MORE'] = 'M', ['CONFIRM'] = 'OK?',
							['SHELL'] = 'SH', ['TERMINAL'] = 'T',
						}
						return map[str] or str
					end,
				}},
				lualine_b = {{
					'filename',
					path = 1,
					use_mode_colors = false,
					color = { fg = 'gray', bg = 'NvimDarkGray2' }
				}},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {
					{
						'diagnostics',
						color = { bg = 'NvimDarkGray2'},
					},
					{
						'lsp_status',
						color = { fg = 'gray', bg = 'NvimDarkGray2' },
					},
				},
				lualine_z = { 'location' }
			}
		}

		vim.opt.showmode = false
		vim.opt.laststatus = 3

	end,
}
