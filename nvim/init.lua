vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- bootstrap lazy and all plugins
local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "user"
require "autocmds"

vim.schedule(function()
  require "mappings"
  -- Pick dark/light based on $ITERM_PROFILE and load gruvbox + all the
  -- custom highlight overrides (green imports, flash labels, fzf-lua
  -- colors, ...) so the initial state matches what F1/F2/F3 produce.
  pcall(function()
    require("user").set_theme()
  end)
end)
