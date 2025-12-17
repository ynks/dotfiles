return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
    { "<leader> ",  function() require("telescope.builtin").find_files() end, desc = "Quick files" },
    { "<leader>/",  function() require("telescope.builtin").find_files() end, desc = "Quick grep" },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end,  desc = "Live grep" },
    { "<leader>fb", function() require("telescope.builtin").buffers() end,    desc = "Buffers" },
    { "<leader>fh", function() require("telescope.builtin").help_tags() end,  desc = "Help tags" },
    { "<leader>fc", function() require("telescope.builtin").commands() end,   desc = "Commands" },
    { "<leader>fm", function() require("telescope.builtin").marks() end,      desc = "Markers" },
    { "<leader>f/", function() require("telescope.builtin").colorscheme() end,desc = "Colorschemes" },
    { "<leader>fq", function() require("telescope.builtin").quickfix() end,   desc = "Quick fixes" },
    { "<leader>ft", function() require("telescope.builtin").treesitter() end, desc = "Treesitter" },
  },
  config = function()
    local ok, telescope = pcall(require, "telescope")
    if not ok then
      vim.notify("telescope.nvim failed to load", vim.log.levels.ERROR)
      return
    end
    telescope.setup({
      defaults = {
	mappings = {
	  i = {
	    ["<esc>"] = "close",
	  },
	},
      },
    })
  end,
}
