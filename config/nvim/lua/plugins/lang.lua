return {
  -- Lua: lua_ls is already configured by LazyVim core; ensure treesitter + stylua
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "lua", "luadoc" })
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "stylua" } },
  },

  -- Protobuf (buf LSP + treesitter)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        buf_ls = {},
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "proto" })
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "buf" } },
  },

  -- Avalonia (.axaml files treated as XML with lemminx LSP)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lemminx = {
          filetypes = { "xml", "xsd", "xsl", "xslt", "svg", "axaml" },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "lemminx" } },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "xml" })
      vim.filetype.add({ extension = { axaml = "xml" } })
    end,
  },

  -- clang-tidy linter (binary from system LLVM/clang install)
  {
    "mason-org/nvim-lint",
    opts = {
      linters_by_ft = {
        c = { "clangtidy" },
        cpp = { "clangtidy" },
      },
    },
  },

  -- Enable inlay hints for all LSP servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
    },
  },
}
