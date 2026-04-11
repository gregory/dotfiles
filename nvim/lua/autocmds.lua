
require "nvchad.autocmds"

local api = vim.api
local fn = vim.fn
local optl = vim.opt_local
local cmd = vim.cmd
local user = require "user"

local function compile_ignore_patterns()
  local patterns = {}
  local ignore = vim.g.ignore or {}
  for _, pattern in ipairs(ignore) do
    local ok, regex = pcall(vim.regex, pattern)
    if ok then
      table.insert(patterns, regex)
    end
  end
  return patterns
end

local ignore_patterns = compile_ignore_patterns()

local function should_change_directory(path)
  if path == "" then
    return false
  end
  for _, regex in ipairs(ignore_patterns) do
    if regex:match_str(path) then
      return false
    end
  end
  return true
end

local custom_group = api.nvim_create_augroup("custom_augroup", { clear = true })

api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = { "ruby", "eruby" },
  callback = function()
    vim.g.rubycomplete_buffer_loading = 1
    vim.g.rubycomplete_classes_in_global = 1
    vim.g.rubycomplete_rails = 1
    optl.tabstop = 2
    optl.shiftwidth = 2
    optl.softtabstop = 2
    optl.commentstring = "# %s"
    local map_opts = { buffer = true, silent = true, noremap = true }
    vim.keymap.set("n", "view", ":Eview<CR>", map_opts)
    vim.keymap.set("n", "cont", ":Econtroller<CR>", map_opts)
    vim.keymap.set("n", "test", ":A<CR>", map_opts)
  end,
})

api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = "slim",
  callback = function()
    optl.formatoptions:remove "t"
    optl.list = false
  end,
})

api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = { "html", "xml", "json" },
  callback = function()
    optl.colorcolumn = "0"
    if vim.bo.filetype == "json" then
      cmd([[syntax match Comment +\/\/.*$+]])
    end
  end,
})

api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = { "html", "javascript" },
  callback = function()
    optl.shiftwidth = 2
    optl.tabstop = 2
    optl.softtabstop = 2
    optl.wrap = false
    optl.list = true
    vim.g.indent_guides_start_level = 2
    vim.g.indent_guides_guide_size = 2
  end,
})

api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = "css",
  callback = function()
    vim.bo.omnifunc = "csscomplete#CompleteCSS"
  end,
})

api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = { "html", "markdown" },
  callback = function()
    vim.bo.omnifunc = "htmlcomplete#CompleteTags"
  end,
})

api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = "javascript",
  callback = function()
    vim.bo.omnifunc = "javascriptcomplete#CompleteJS"
  end,
})

api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = "python",
  callback = function()
    vim.bo.omnifunc = "pythoncomplete#Complete"
  end,
})

api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = "xml",
  callback = function()
    vim.bo.omnifunc = "xmlcomplete#CompleteTags"
  end,
})

api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = "less",
  callback = function()
    vim.bo.omnifunc = "csscomplete#CompleteCSS"
  end,
})

api.nvim_create_autocmd({ "CursorHold", "FocusLost" }, {
  group = custom_group,
  command = "checktime",
})

api.nvim_create_autocmd("BufEnter", {
  group = custom_group,
  callback = function()
    local dir = fn.expand "%:p:h"
    if should_change_directory(dir) then
      pcall(cmd, "silent! lcd " .. fn.fnameescape(dir))
    end
  end,
})

-- Resolve symlinks so `%` is the real path. Directory tracking is handled
-- by the BufEnter autocmd above, which lcds to the current file's folder
-- (so `:e <Tab>` completes from the file's directory, not the git root).
api.nvim_create_autocmd("BufRead", {
  group = custom_group,
  callback = function()
    user.follow_symlink()
  end,
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = custom_group,
  pattern = { ".env", ".envrc" },
  callback = function()
    vim.bo.filetype = "config"
  end,
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = custom_group,
  pattern = { "*.haml" },
  callback = function()
    vim.bo.filetype = "haml"
  end,
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = custom_group,
  pattern = { "*.slim" },
  callback = function()
    vim.bo.filetype = "slim"
  end,
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = custom_group,
  pattern = { "*.styl", "*.stylus" },
  callback = function()
    vim.bo.filetype = "stylus"
  end,
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = custom_group,
  pattern = { "*.builder", "*.voxml" },
  callback = function()
    vim.bo.filetype = "ruby"
  end,
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = custom_group,
  pattern = { "*.ex", "*.exs" },
  callback = function()
    vim.bo.filetype = "elixir"
  end,
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = custom_group,
  pattern = { "*.less" },
  callback = function()
    vim.bo.filetype = "less"
  end,
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = custom_group,
  callback = function()
    vim.o.updatetime = 2000
  end,
})

api.nvim_create_autocmd("BufReadPost", {
  group = custom_group,
  pattern = "fugitive://*",
  callback = function()
    vim.bo.bufhidden = "delete"
  end,
})

api.nvim_create_autocmd("User", {
  group = custom_group,
  pattern = "fugitive",
  callback = function()
    if (vim.b.fugitive_type or ""):match "^(tree|blob)$" then
      vim.keymap.set("n", "..", ":edit %:h<CR>", { buffer = true, silent = true, noremap = true })
    end
  end,
})

api.nvim_create_autocmd("User", {
  group = custom_group,
  pattern = "Rails",
  callback = function()
    vim.b["surround_" .. string.byte("-")] = "<% \\r %>"
  end,
})

api.nvim_create_autocmd({ "FileWritePre", "FileAppendPre", "FilterWritePre", "BufWritePre" }, {
  group = custom_group,
  callback = function()
    user.trim_trailing_whitespace()
  end,
})

if vim.env.TERM then
  api.nvim_create_autocmd("VimEnter", {
    group = custom_group,
    callback = function()
      user.set_tmux_key_label("Format")
    end,
  })
  api.nvim_create_autocmd("VimLeave", {
    group = custom_group,
    callback = function()
      user.set_tmux_key_label("F6")
    end,
  })
end

local vcenter = api.nvim_create_augroup("VCenterCursor", { clear = true })
api.nvim_create_autocmd({ "BufEnter", "WinEnter", "WinNew", "VimResized" }, {
  group = vcenter,
  callback = function(args)
    local win = args.win or api.nvim_get_current_win()
    local height = api.nvim_win_get_height(win)
    vim.wo[win].scrolloff = math.floor(height / 2)
  end,
})

api.nvim_create_autocmd("CursorHold", {
  group = custom_group,
  callback = function()
    pcall(fn.CocActionAsync, "highlight")
  end,
})

api.nvim_create_autocmd("User", {
  group = custom_group,
  pattern = "CocJumpPlaceholder",
  callback = function()
    pcall(fn.CocActionAsync, "showSignatureHelp")
  end,
})

api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = { "typescript", "json" },
  callback = function()
    vim.bo.formatexpr = "CocAction('formatSelected')"
  end,
})

