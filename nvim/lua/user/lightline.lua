local M = {}

function M.setup()
  local fn = vim.fn
  local fill = fn["lightline#colorscheme#fill"]
  local palette = fill(fn["lightline#colorscheme#one#palette"]())
  palette.inactive.right[1] = { "#fafafa", "#98c379", 255, 35, "bold" }
  palette.inactive.left[1] = palette.normal.left[2]
  vim.g["lightline#colorscheme#Greg#palette"] = palette
  vim.g.lightline.colorscheme = "Greg"
end

return M
