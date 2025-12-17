local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local function toggle_telescope(harpoon_list)
  local file_paths = {}

  for _, item in ipairs(harpoon_list.items) do
    table.insert(file_paths, item.value)
  end

  pickers.new({
    prompt_title = "Working List",
  }, {
    finder = finders.new_table({
      results = file_paths,
    }),
    previewer = conf.file_previewer({}),
    sorter = conf.generic_sorter({}),
  }):find()
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, {desc = "Harpoon add"})
    vim.keymap.set("n", "<leader>hd", function() harpoon:list():remove() end, {desc = "Harpoon delete"})
    vim.keymap.set("n", "<leader>.", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, {desc = "Quick harpoon"})
    vim.keymap.set("n", "<leader>hh", function() toggle_telescope(harpoon:list()) end, {desc = "Open harpoon window"})
    vim.keymap.set("n", "<C-h>", function() harpoon:list():prev() end)
    vim.keymap.set("n", "<C-l>", function() harpoon:list():next() end)
  end
}
