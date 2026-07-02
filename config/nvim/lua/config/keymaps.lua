local symbols = " .,(){}<>[]\"'"
local pattern = symbols:gsub("([%%%^%]%-%]])", "%%%1")

local tab_forward = function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  if col == nil then
    return
  end
  line = line:sub(col + 1)
  local char = line:match("^.")
  for c in symbols:gmatch(".") do
    if char == c then
      return "<C-o>a"
    end
  end
  local result = line:match("[" .. pattern .. "]")
  if result ~= nil then
    return "<C-o>f" .. result:sub(1, 1)
  end
  if col == vim.fn.col("$") - 1 then
    return "\t"
  end
  return "<C-o>A"
end

vim.keymap.set("i", "<S-Tab>", "<Tab>")
vim.keymap.set("i", "<Tab>", tab_forward, { expr = true })

pcall(vim.keymap.del, "n", "gra")
pcall(vim.keymap.del, "n", "gri")
pcall(vim.keymap.del, "n", "grn")
pcall(vim.keymap.del, "n", "grr")
pcall(vim.keymap.del, "n", "grt")
pcall(vim.keymap.del, "n", "grx")
