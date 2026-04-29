-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",
}

-- Custom statusline modules layered on top of NvChad's default theme.
-- See lua/user/statusline.lua for the module implementations.
local user_stl = require "user.statusline"
user_stl.setup()

M.ui = {
  statusline = {
    theme = "default",
    -- Thin vertical bar instead of the built-in round/arrow/block shapes.
    -- NvChad's generator accepts a {left,right} table here (see utils.lua).
    separator_style = { left = "│", right = "│" },
    order = {
      "mode",
      "file",
      "git",
      "%=",
      "context",
      "coc_status",
      "lsp_msg",
      "%=",
      "macro",
      "search",
      "vsel",
      "warnings",
      "unsaved",
      "diagnostics",
      "lsp",
      "indent",
      "cursor",
    },
    modules = {
      context    = user_stl.context,
      search     = user_stl.search,
      macro      = user_stl.macro,
      vsel       = user_stl.vsel,
      warnings   = user_stl.warnings,
      coc_status = user_stl.coc_status,
      indent     = user_stl.indent,
      unsaved    = user_stl.unsaved,
    },
  },
}

return M
