return {
  "nvim-treesitter/nvim-treesitter",
  branch = 'master',
  lazy = false,
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      -- languages
      "lua", "c", "cpp", "c_sharp", "cmake", "glsl", "slang", "matlab", "python", "rust",
      -- git stuff
      "git_config", "gitignore",
      -- data formats
      "json", "yaml", "toml", "css", "doxygen", "xml", "regex",
      -- bash
      "bash",
    },
    sync_install = true,
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    autotage = { enable = true }
  }
}
