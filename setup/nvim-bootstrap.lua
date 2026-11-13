-- Headless second stage of ./install.sh, run after `Lazy! sync`:
--   nvim --headless -c "luafile setup/nvim-bootstrap.lua"
-- Installs every Mason package from chadrc (what :MasonInstallAll does, but
-- blocking) and every treesitter parser from the nvim-treesitter spec, then quits.
local function say(msg)
  io.stdout:write(msg .. "\n")
end

local lazy = require "lazy"

-- ---------------------------------------------------------------- mason
lazy.load { plugins = { "mason.nvim" } }
local registry = require "mason-registry"
local refreshed = false
registry.refresh(function()
  refreshed = true
end)
vim.wait(120000, function()
  return refreshed
end, 200)

local pkgs = require("chadrc").mason.pkgs
local installing = {}
for _, name in ipairs(pkgs) do
  local ok, pkg = pcall(registry.get_package, name)
  if not ok then
    say("mason: unknown package " .. name)
  elseif pkg:is_installed() then
    say("mason: " .. name .. " already installed")
  else
    say("mason: installing " .. name)
    installing[#installing + 1] = pkg
    pkg:install()
  end
end
vim.wait(30 * 60 * 1000, function()
  for _, pkg in ipairs(installing) do
    if pkg:is_installing() then
      return false
    end
  end
  return true
end, 500)
local failed = 0
for _, pkg in ipairs(installing) do
  if pkg:is_installed() then
    say("mason: ✓ " .. pkg.name)
  else
    failed = failed + 1
    say("mason: ✗ " .. pkg.name .. " (retry with :MasonInstall " .. pkg.name .. ")")
  end
end

-- ----------------------------------------------------------- treesitter
lazy.load { plugins = { "nvim-treesitter" } }
local spec = require("lazy.core.config").plugins["nvim-treesitter"]
local opts = require("lazy.core.plugin").values(spec, "opts", false)
local parsers = opts.ensure_installed or {}
say("treesitter: installing " .. #parsers .. " parsers (compiles locally, takes a while)")
local ok, err = pcall(function()
  require("nvim-treesitter").install(parsers, { summary = true }):wait(30 * 60 * 1000)
end)
if not ok then
  failed = failed + 1
  say("treesitter: " .. tostring(err))
end
local installed = require("nvim-treesitter").get_installed "parsers"
local missing = vim.tbl_filter(function(p)
  return not vim.tbl_contains(installed, p)
end, parsers)
if #missing > 0 then
  failed = failed + 1
  say("treesitter: missing " .. table.concat(missing, ", ") .. " (retry with :TSInstall)")
else
  say("treesitter: ✓ all parsers installed")
end

vim.cmd(failed > 0 and "cquit 1" or "qall!")
