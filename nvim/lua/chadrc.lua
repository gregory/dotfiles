-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",
}

-- Language servers and formatters, installed with :MasonInstallAll.
--
-- Mason rather than `npm install -g`: npm globals live under the active node
-- version's prefix, so switching node makes every server vanish. That exact
-- failure was already in this config as g.coc_node_path pointing at a v16.12.0
-- that no longer exists. Mason installs into its own prefix and only needs
-- *some* node on PATH, so it survives version switches (and the nvm -> fnm move).
-- NvChad prepends mason/bin to vim.env.PATH unconditionally, so no extra wiring.
M.mason = {
  pkgs = {
    -- TypeScript / JavaScript. vtsls over ts_ls: Vue 3 hybrid mode requires it
    -- (takeover mode was removed in vue-language-server 3.0), and it exposes
    -- the tsserver commands ts_ls does not (organize imports, add missing).
    "vtsls",
    "eslint-lsp",           -- highest-value server across 27 JS projects
    "vue-language-server",  -- 268 .vue files
    "json-lsp",
    "html-lsp",
    "css-lsp",
    "yaml-language-server",
    "bash-language-server", -- 288 .sh files
    "lua-language-server",  -- NvChad enables lua_ls but never installed it

    -- formatters for conform.nvim
    "prettier",
    "stylua",
    "shfmt",
  },
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
      indent     = user_stl.indent,
      unsaved    = user_stl.unsaved,
    },
  },
}

return M
