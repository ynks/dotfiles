return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<C-y>"] = {},
        ["<Tab>"] = { "select_and_accept", "fallback" },
      },
    },
  },
}
