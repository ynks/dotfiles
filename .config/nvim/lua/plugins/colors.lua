local function enable_transparency()
  vim.api.nvim_set_hl(0, "Normal", {bg = "none"} )
end

return {
  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "github_dark_default"
      enable_transparency()
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  }
}
