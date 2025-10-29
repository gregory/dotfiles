-- Neovim 0.11.2 configuration migrated from legacy Vim setup
-- Leader keys must be defined before any plugin loads or mappings run.
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Bootstrap lazy.nvim if it is not already installed.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Preserve legacy plugin behaviour.
vim.g.polyglot_disabled = { "javascript" }
vim.g.coc_global_extensions = {
  "coc-css",
  "coc-html",
  "coc-json",
  "coc-yaml",
  "coc-eslint",
  "coc-prettier",
}

require("plugins").setup()

-- Tell the legacy Vimscript that plugins are managed by lazy.nvim so it can
-- skip running vim-plug directives that would otherwise break and block the
-- rest of the configuration from loading.
vim.g.lazy_port_skip_plug = 1

-- Load the legacy Vimscript configuration directly from the user's ~/.vimrc so
-- new keymaps and tweaks automatically flow into Neovim. Fall back to the
-- bundled legacy.vim snapshot if ~/.vimrc cannot be found.
local config_dir = vim.fn.stdpath("config")
local init_source = debug.getinfo(1, "S").source
if init_source:sub(1, 1) == "@" then
  config_dir = vim.fn.fnamemodify(init_source:sub(2), ":h")
end

local legacy_targets = {
  vim.fn.expand("~/.vimrc"),
  config_dir .. "/legacy.vim",
}

local sourced_legacy = false
for _, target in ipairs(legacy_targets) do
  if vim.fn.filereadable(target) == 1 then
    vim.cmd.source(vim.fn.fnameescape(target))
    sourced_legacy = true
    break
  end
end

if not sourced_legacy then
  vim.notify(
    string.format(
      "Legacy configuration file not found. Looked for: %s",
      table.concat(legacy_targets, ", ")
    ),
    vim.log.levels.WARN
  )
end
