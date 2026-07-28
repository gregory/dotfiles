
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

-- The css / html+markdown / javascript omnifunc autocmds are gone: vim.lsp sets
-- omnifunc on attach ONLY when it is empty or default, so setting the old
-- vimscript completers here BLOCKED LSP omni-completion for exactly the
-- filetypes that now have real servers (cssls, html, vtsls).
-- The python/xml/less ones below are kept — no server covers those here.

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

-- Detect files modified outside of nvim and reload them.
-- `autoread` is set in options.lua, but vim only consults it on certain
-- events. Triggering `:checktime` here forces the check on:
--   FocusGained — coming back to nvim from another app
--   BufEnter    — switching buffers
--   TermClose   — after a terminal command exits, in case it touched files
--
-- CursorHold and CursorHoldI were dropped. Together with updatetime restored to
-- NvChad's 250 (see below), they would stat() the file four times a second, and
-- CursorHoldI did it while typing. The two cases the old comment described —
-- coming back from another app, and a formatter running in a split — are already
-- covered by FocusGained and TermClose.
api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermClose" }, {
  group = custom_group,
  callback = function()
    if vim.bo.buftype == "" and vim.fn.mode() ~= "c" then
      pcall(vim.cmd, "checktime")
    end
  end,
})

-- Surface the reload as a notification so you know something happened
-- (otherwise vim silently swaps in the new content under the cursor).
api.nvim_create_autocmd("FileChangedShellPost", {
  group = custom_group,
  callback = function()
    vim.notify("File changed on disk — buffer reloaded", vim.log.levels.INFO)
  end,
})

-- Always lcd to the directory of the current file so `:e <Tab>` completes
-- from the file's folder. We deliberately ignore vim.g.ignore here because
-- those patterns (e.g. `\/\.`) were designed for grep/fzf exclusion and
-- wrongly block any path under a dot-directory like ~/.config/....
api.nvim_create_autocmd("BufEnter", {
  group = custom_group,
  callback = function()
    -- Skip special buffers (terminals, help, quickfix, neo-tree, fzf, ...).
    if vim.bo.buftype ~= "" then
      return
    end
    local name = api.nvim_buf_get_name(0)
    if name == "" or name:match "^%a+://" then
      return
    end
    local dir = fn.fnamemodify(name, ":p:h")
    if dir ~= "" and fn.isdirectory(dir) == 1 then
      pcall(cmd, "silent! lcd " .. fn.fnameescape(dir))
    end
  end,
})

-- Start terminals in insert/terminal mode so `:term`, `:split | term`,
-- and the custom terminal_opener (mappings.lua) drop you straight into
-- the shell instead of n-terminal-normal mode. BufEnter re-applies it
-- when you hop back into an existing terminal buffer.
api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
  group = custom_group,
  callback = function()
    if vim.bo.buftype == "terminal" then
      cmd "startinsert"
    end
  end,
})

-- Inside fzf-lua's terminal prompt, neutralize the global terminal-mode
-- window-nav / resize mappings (mappings.lua:220-227) so they don't kick us
-- out of the picker. We buffer-locally remap each one back to its raw key,
-- letting fzf receive <C-h/j/k/l> and <S-Up/Down/Left/Right> for its own
-- actions (window nav still works from non-fzf terminals).
api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = "fzf",
  callback = function()
    -- <C-x> is critical: NvChad maps it in terminal mode to escape
    -- terminal mode, which swallows fzf-lua's ctrl-x action (e.g.
    -- buf_del in the buffers picker). Passing it through here lets
    -- the fzf binary receive it and trigger the Lua callback.
    local keys = { "<C-h>", "<C-j>", "<C-k>", "<C-l>", "<C-x>", "<S-Up>", "<S-Down>", "<S-Left>", "<S-Right>" }
    for _, k in ipairs(keys) do
      vim.keymap.set("t", k, k, { buffer = true, nowait = true })
    end
  end,
})

-- Hide line numbers + signcolumn in the neo-tree sidebar. NvChad's defaults
-- turn them on globally, which makes the tree noisy.
api.nvim_create_autocmd("FileType", {
  group = custom_group,
  pattern = "neo-tree",
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    vim.wo.cursorline = true
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

-- Removed: a pattern-less BufRead/BufNewFile autocmd that re-set the GLOBAL
-- `updatetime = 2000` on every file opened. It silently overrode NvChad's 250,
-- which gitsigns relies on for responsive blame and hunk updates. Nothing here
-- needed the slower value; the CursorHold consumers that did (see the checktime
-- autocmd above) have been narrowed instead.

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

-- BufWritePre only. `FilterWritePre` fires when a range is piped through an
-- external command (`!sort`, `!fmt`), where rewriting the whole buffer is both
-- wrong and can target a non-modifiable buffer — that was the source of
-- `E21: Cannot make changes, 'modifiable' is off`.
api.nvim_create_autocmd("BufWritePre", {
  group = custom_group,
  callback = function()
    user.trim_trailing_whitespace()
  end,
})

-- Lint-fix then format, on every write.
--
-- One explicit hook rather than conform's own `format_on_save`, so the ORDER is
-- guaranteed: eslint's auto-fixes first (they can leave odd spacing), prettier
-- second to normalise the result. Two competing BufWritePre hooks would leave
-- that order up to registration timing.
--
-- Heads-up on the cost: insert-mode <Esc> is mapped to save_if_real(), so this
-- runs on every <Esc>, not just on an explicit :w. That is deliberate (chosen
-- over gating it to real :w only), but it means every <Esc> spawns prettier.
-- If it ever feels laggy, the gate is one flag in user.save_if_real().
api.nvim_create_autocmd("BufWritePre", {
  group = custom_group,
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].buftype ~= "" then return end
    if not vim.bo[buf].modifiable or vim.bo[buf].readonly then return end

    -- 1. eslint --fix, only where an eslint server is actually attached. The
    --    LspEslintFixAll command is created buffer-locally by eslint's on_attach
    --    and uses request_sync, so it completes before we move on.
    local eslint = vim.lsp.get_clients { bufnr = buf, name = "eslint" }
    if #eslint > 0 then
      pcall(vim.api.nvim_buf_call, buf, function()
        vim.cmd "LspEslintFixAll"
      end)
    end

    -- 2. prettier / shfmt / stylua / terraform_fmt per filetype, falling back to
    --    the LSP formatter where conform has no entry. Must be synchronous so
    --    the changes land in this write.
    pcall(function()
      require("conform").format {
        bufnr = buf,
        async = false,
        lsp_format = "fallback",
        timeout_ms = 3000,
      }
    end)
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

-- Three coc.nvim autocmds removed here. coc never loaded (its spec has no
-- event/cmd/keys/ft trigger under defaults = { lazy = true }), so all three were
-- either no-ops or actively harmful:
--
--   CursorHold -> CocActionAsync("highlight")     — a pcall that failed on every
--     idle tick. The LSP equivalent is vim.lsp.document_highlight.
--   User CocJumpPlaceholder -> showSignatureHelp  — never fired.
--   FileType typescript,json -> formatexpr = "CocAction('formatSelected')"
--     — actively harmful. vim.lsp sets formatexpr on attach ONLY if it is empty
--     or default, so this blocked LSP range formatting for the two filetypes
--     most used here, and made `gq` throw E117 in them.

