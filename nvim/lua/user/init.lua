local M = {}

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.uv or vim.loop

-- ============================================================
-- iTerm profile names triggered by F1 / F2 / F3. Edit these to
-- match profiles that actually exist in iTerm (Preferences ->
-- Profiles). Set to nil to skip the iTerm switch for a key.
-- ============================================================
local ITERM_PROFILE_F1 = "Miasma"          -- dark, matches miasma.nvim
local ITERM_PROFILE_F2 = "Solarized Light" -- paired with gruvbox light in nvim
local ITERM_PROFILE_F3 = "Solarized Dark"  -- paired with solarized dark in nvim

-- Returns true when macOS is in dark mode. Any failure (non-macOS,
-- `defaults` not on PATH, unexpected output) is treated as dark, which
-- is the safe fallback for an unknown terminal.
function M.is_macos_dark_mode()
  if vim.fn.has("mac") ~= 1 and vim.fn.has("macunix") ~= 1 then
    return true
  end
  -- `defaults read -g AppleInterfaceStyle` prints "Dark\n" in dark mode
  -- and exits non-zero (key missing) in light mode. jobstart avoids the
  -- stderr noise that plain vim.fn.system would print.
  local out = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
  if vim.v.shell_error ~= 0 then
    return false -- key absent -> light mode
  end
  return out:match("Dark") ~= nil
end

-- Switch iTerm2's current-tab profile via OSC 50. No-op outside iTerm.
local function set_iterm_profile(name)
  if not name or name == "" then return end
  if not (vim.env.LC_TERMINAL == "iTerm2" or vim.env.TERM_PROGRAM == "iTerm.app") then
    return
  end
  -- When running inside tmux, wrap in the DCS passthrough so the sequence
  -- reaches iTerm instead of being swallowed by tmux.
  local seq = "\027]50;SetProfile=" .. name .. "\007"
  if vim.env.TMUX then
    seq = "\027Ptmux;\027" .. seq:gsub("\027", "\027\027") .. "\027\\"
  end
  io.stdout:write(seq)
end
M.set_iterm_profile = set_iterm_profile
local loader_ok, loader = pcall(require, "lazy.core.loader")
local config = loader_ok and require "lazy.core.config" or nil

local function ensure_plugin(name)
  if not loader_ok or not config then
    return false
  end

  local plugin = config.plugins[name]
  if not plugin then
    return false
  end

  if plugin._.loaded then
    return true
  end

  loader.load(plugin, { source = "user.ensure_plugin" })
  return plugin._.loaded
end

function M.ensure_plugin(name)
  if ensure_plugin(name) then
    return true
  end
  vim.notify(string.format("%s is not available", name), vim.log.levels.WARN, { title = "plugins" })
  return false
end

local function trim(str)
  return (str or ""):gsub("%s+$", "")
end

function M.toggle_curline()
  local win = api.nvim_get_current_win()
  if vim.wo[win].cursorline and vim.wo[win].cursorcolumn then
    vim.wo[win].cursorcolumn = false
  else
    vim.wo[win].cursorcolumn = true
  end
end

function M.follow_symlink()
  local current = fn.expand "%:p"
  if current ~= "" and fn.getftype(current) == "link" then
    local resolved = fn.resolve(current)
    cmd("file " .. fn.fnameescape(resolved))
  end
end

function M.set_project_root()
  local buf = api.nvim_get_current_buf()
  local buftype = vim.bo[buf].buftype
  if buftype ~= "" then
    return
  end

  local name = api.nvim_buf_get_name(buf)
  if name == "" or name:match "^%a+://" then
    return
  end

  local buf_dir = fn.fnamemodify(name, ":p:h")
  if buf_dir ~= "" and fn.isdirectory(buf_dir) == 1 then
    pcall(cmd, "silent! lcd " .. fn.fnameescape(buf_dir))
  end

  local git_dir = trim(fn.system "git rev-parse --show-toplevel")
  if vim.v.shell_error ~= 0 then
    return
  end

  if git_dir ~= "" and not git_dir:match "^fatal:" and fn.isdirectory(git_dir) == 1 then
    pcall(cmd, "silent! lcd " .. fn.fnameescape(git_dir))
  end
end

function M.selecta_command(choice_command, selecta_args, vim_command)
  if fn.executable "selecta" == 0 then
    return
  end
  local original = fn.getcwd()
  local buf_dir = fn.expand "%:p:h"
  if buf_dir ~= "" then
    cmd("lcd " .. fn.fnameescape(buf_dir))
  end
  local git_dir = trim(fn.system "git rev-parse --show-toplevel")
  if git_dir ~= "" and not git_dir:match "^fatal:" then
    cmd("lcd " .. fn.fnameescape(git_dir))
  end
  local selection = fn.system(choice_command .. " | selecta " .. (selecta_args or ""))
  cmd "redraw!"
  cmd("lcd " .. fn.fnameescape(original))
  if fn.shell_error() ~= 0 then
    return
  end
  selection = trim(selection)
  if selection == "" then
    return
  end
  cmd(vim_command .. " " .. fn.fnameescape(selection))
end

function M.selecta_file(path)
  M.selecta_command("find " .. path .. "/* -type f", "", ":e")
end

function M.selecta_identifier()
  fn.setreg("z", fn.expand "<cword>")
  M.selecta_command("find * -type f", "-s " .. fn.getreg "z", ":e")
end

local terminal_close_group = api.nvim_create_augroup("user_terminal_close", { clear = false })

function M.open_terminal(opts)
  opts = opts or {}

  local orientation = opts.orientation or "horizontal"

  if orientation == "vertical" then
    cmd "vsplit"
  elseif orientation == "horizontal" then
    cmd "split"
  elseif orientation == "tab" then
    cmd "tabnew"
  end

  local win = api.nvim_get_current_win()

  local command
  if type(opts.command) == "table" then
    if #opts.command > 0 then
      command = table.concat(opts.command, " ")
    end
  elseif type(opts.command) == "string" and opts.command ~= "" then
    command = opts.command
  end

  if command then
    cmd("terminal " .. command)
  else
    cmd "terminal"
  end

  local buf = api.nvim_get_current_buf()

  if opts.kill then
    local ok = pcall(api.nvim_buf_set_option, buf, "term_kill", opts.kill)
    if not ok then
      vim.b[buf].term_kill = opts.kill
    end
  end

  if opts.close ~= false then
    api.nvim_create_autocmd("TermClose", {
      group = terminal_close_group,
      buffer = buf,
      once = true,
      callback = function()
        local target_win = win
        vim.schedule(function()
          if api.nvim_win_is_valid(target_win) then
            local ok, is_terminal = pcall(function()
              return vim.bo[api.nvim_win_get_buf(target_win)].buftype == "terminal"
            end)
            if ok and is_terminal then
              pcall(api.nvim_win_close, target_win, true)
            end
          end
        end)
      end,
    })
  end

  if opts.rows then
    api.nvim_win_set_height(win, opts.rows)
  end
end

local function quickfix_filenames()
  local items = fn.getloclist(0)
  if #items == 0 then
    items = fn.getqflist()
  end
  local buffers = {}
  for _, item in ipairs(items) do
    if item.bufnr and item.bufnr > 0 then
      buffers[item.bufnr] = fn.bufname(item.bufnr)
    end
  end
  local result = {}
  for _, name in pairs(buffers) do
    table.insert(result, fn.fnameescape(name))
  end
  return table.concat(result, " ")
end

function M.qargs()
  local args = quickfix_filenames()
  if args ~= "" then
    cmd("args " .. args)
  end
end

function M.qdo(bang, command)
  local in_quickfix = fn.exists("w:quickfix_title") == 1
  if in_quickfix then
    cmd "cclose"
  end
  cmd "arglocal"
  local args = quickfix_filenames()
  if args ~= "" then
    cmd("args " .. args)
    cmd("argdo" .. (bang and "!" or "") .. " " .. command)
  end
  cmd "argglobal"
  if in_quickfix then
    cmd "copen"
  end
end

-- Filetypes where trailing whitespace is meaningful and must be preserved:
-- two trailing spaces are a hard line break in markdown, and touching the
-- whitespace of a diff/patch invalidates it.
local trim_skip_filetypes = {
  markdown = true,
  text = true,
  gitcommit = true,
  diff = true,
  patch = true,
  mail = true,
  make = true,
  snippets = true,
}

-- Strip trailing whitespace on write.
--
-- Guards mirror save_if_real() below — without them this threw
-- `E21: Cannot make changes, 'modifiable' is off` on non-modifiable buffers
-- (reproducible with :checkhealth).
--
-- Deliberately does NOT collapse blank lines. This used to also run
-- `g/^\n\{2,}/d`, which merged every run of 2+ blank lines in the whole file
-- on every write — and since insert-mode <Esc> is mapped to save_if_real(),
-- that reformatted the entire buffer on every <Esc>. Blank-line layout is
-- meaningful in JS/TS section breaks and in markdown; that is a reformat, not
-- a whitespace trim.
--
-- Uses the buffer API rather than `:%s` so it never moves the cursor, never
-- clobbers the search register, and never triggers 'formatoptions'.
function M.trim_trailing_whitespace()
  if vim.bo.buftype ~= "" then return end
  if not vim.bo.modifiable or vim.bo.readonly then return end
  if api.nvim_buf_get_name(0) == "" then return end
  if trim_skip_filetypes[vim.bo.filetype] then return end

  local lines = api.nvim_buf_get_lines(0, 0, -1, false)
  for i, line in ipairs(lines) do
    local trimmed = line:gsub("[ \t]+$", "")
    if trimmed ~= line then
      api.nvim_buf_set_lines(0, i - 1, i, false, { trimmed })
    end
  end
end

-- Called by the insert-mode `<Esc>` and `fd` mappings (mappings.lua):
-- write the current buffer to disk only when it makes sense to.
-- Bails out for paste mode (auto-save would mangle a paste flow), special
-- buffers (terminal/quickfix/help/oil/neo-tree), read-only buffers, and
-- unnamed buffers (where `:write!` would E32 anyway).
function M.save_if_real()
  if vim.o.paste then return end
  if vim.bo.buftype ~= "" then return end
  if not vim.bo.modifiable then return end
  if api.nvim_buf_get_name(0) == "" then return end
  pcall(cmd, "silent! write!")
end

function M.rename_file()
  local old_name = fn.expand "%"
  local new_name = fn.input("New file name: ", old_name)
  cmd "redraw"
  if new_name ~= "" and new_name ~= old_name then
    if M.ensure_plugin "vim-fugitive" then
      cmd("Gmove " .. fn.fnameescape(new_name))
    end
  end
end

function M.set_transparency()
  cmd "hi Normal     guibg=NONE ctermbg=NONE"
  cmd "hi NormalNC   guibg=NONE ctermbg=NONE"
  cmd "hi SignColumn guibg=NONE ctermbg=NONE"
  cmd "hi LineNr     guibg=NONE ctermbg=NONE"
  cmd "hi EndOfBuffer guibg=NONE ctermbg=NONE"
  cmd "hi Terminal   guibg=NONE ctermbg=NONE"
end

-- Helper: load gruvbox with the requested background, fall back gracefully.
-- F2 (light) uses vanilla gruvbox-light + a few targeted overrides so
-- it matches what bat's `gruvbox-light` theme renders in the fzf-lua
-- preview pane (notably: imports in green, not red).
local function load_theme(bg)
  vim.opt.termguicolors = true
  vim.opt.background = bg
  vim.g.gruvbox_contrast_light = "soft"
  vim.g.gruvbox_contrast_dark = "hard"
  vim.g.gruvbox_italic = 1
  vim.g.gruvbox_bold = 1
  local ok = pcall(cmd, "colorscheme gruvbox")
  if not ok then
    pcall(cmd, "colorscheme habamax") -- builtin nvim fallback
  end
  if bg == "light" then
    -- Hard, synchronous override right after colorscheme loads.
    -- `hi!` forces the definition even if the group already exists as a
    -- link. We repeat for every concrete group we know about; whichever
    -- is actually in use will take the color.
    local green_cmd = "guifg=#79740e gui=bold cterm=bold ctermfg=100"
    local groups = {
      "javaScriptReserved", "javaScriptImport", "javaScriptStatement",
      "javaScriptModule", "javaScriptMessage",
      "jsImport", "jsExport", "jsFrom", "jsAs", "jsModuleKeyword",
      "jsStorageClass",
      "typescriptImport", "typescriptExport", "typescriptFrom",
      "typescriptAs", "typescriptModule",
      "Include", "PreProc",
    }
    for _, g in ipairs(groups) do
      pcall(cmd, "hi! " .. g .. " " .. green_cmd)
    end
    -- Treesitter captures need nvim_set_hl with namespace 0.
    for _, g in ipairs({
      "@keyword.import", "@keyword.export", "@include",
      "@keyword.import.javascript", "@keyword.export.javascript",
      "@keyword.import.typescript", "@keyword.export.typescript",
      "@keyword.import.tsx", "@keyword.export.tsx",
      "@keyword.import.jsx", "@keyword.export.jsx",
    }) do
      pcall(api.nvim_set_hl, 0, g, { fg = "#79740e", bold = true })
    end
    M.paint_imports_green()
  end
end

-- Force import / export / from groups to GruvboxGreen, matching bat's
-- gruvbox-light preview. Called from load_theme and from an autocmd on
-- FileType / Syntax so it catches whatever concrete group vim/polyglot/
-- treesitter ends up using for the current buffer.
local IMPORT_GREEN = "#79740e"

function M.paint_imports_green()
  if vim.o.background ~= "light" then
    return
  end
  local hl = { fg = IMPORT_GREEN, bold = true }
  -- Known groups from every syntax engine we might hit.
  local targets = {
    "Include", "PreProc",
    "jsImport", "jsExport", "jsFrom", "jsAs", "jsModuleKeyword",
    "jsStorageClass",
    "javaScriptImport", "javaScriptReserved", "javaScriptStatement",
    "javaScriptModule", "javaScriptIdentifier",
    "typescriptImport", "typescriptExport", "typescriptFrom", "typescriptAs",
    "typescriptModule",
    "@keyword.import", "@keyword.export", "@include",
    "@keyword.import.javascript", "@keyword.export.javascript",
    "@keyword.import.typescript", "@keyword.export.typescript",
    "@keyword.import.tsx", "@keyword.import.jsx",
  }
  -- Auto-discover: any existing hl group whose name mentions import/from/
  -- export/include gets the same treatment.
  for _, name in ipairs(fn.getcompletion("", "highlight")) do
    local l = name:lower()
    if l:find("import", 1, true)
       or l:find("export", 1, true)
       or l:find("from", 1, true)
       or l:find("include", 1, true) then
      table.insert(targets, name)
    end
  end
  for _, g in ipairs(targets) do
    pcall(api.nvim_set_hl, 0, g, hl)
  end
end

-- Reapply the green import override every time a colorscheme loads or a
-- JS/TS buffer enters, so the concrete syntax groups that only exist once
-- the filetype is attached also get patched.
local import_group = api.nvim_create_augroup("user_import_colors", { clear = true })
api.nvim_create_autocmd({ "ColorScheme", "FileType", "Syntax" }, {
  group = import_group,
  callback = function()
    M.paint_imports_green()
  end,
})

local function tweak_common()
  vim.g.one_allow_italics = 1
  vim.g.indent_guides_guide_size = 2
  cmd "hi Comment gui=italic cterm=italic"
  cmd "hi! link javascriptOperator Identifier"
  cmd "hi! link IndentGuidesEven CursorLine"
  cmd "hi! link IndentGuidesOdd Noise"
  -- "Floating windows" split look — buffers opaque, gaps transparent.
  --
  -- How it works with iTerm2's profile transparency (bin/iterm-setup-
  -- transparency.sh, ~12% transparency + blur):
  --
  --   • Buffer cells  → Normal has the theme's solid guibg. iTerm still
  --                     composites with transparency, but because the
  --                     cell is painted with a near-opaque theme color,
  --                     wallpaper only hints through — buffers stay readable.
  --   • Separator col → WinSeparator has bg=NONE. A cell with no explicit
  --                     bg uses the terminal's default, which iTerm2
  --                     transparentizes fully → wallpaper + blur visibly
  --                     show in that column. Reads as a real gap between
  --                     two opaque "windows".
  --   • fillchar stays space (copy-selection fix preserved — dragging a
  --     visual selection across the gap doesn't pick up a `│` char).
  --
  -- Everything runs inside tweak_common(), which fires after every F1/F2/F3
  -- theme switch (light/dark/transparent_background each call it), so the
  -- effect persists across theme flips.
  do
    local is_dark_win = vim.o.background == "dark"
    -- Gap glyph color: only used if you ever switch fillchars back to `│`.
    -- With space fillchar, fg doesn't render — but keep it sensible for
    -- the hypothetical case. bg=NONE is the load-bearing part.
    local sep_fg = is_dark_win and "#5c6370" or "#bdae93"
    api.nvim_set_hl(0, "WinSeparator", { fg = sep_fg, bg = "NONE" })
    api.nvim_set_hl(0, "VertSplit",    { fg = sep_fg, bg = "NONE" })
    -- EndOfBuffer (the `~` lines past EOF) also defaults to transparent
    -- so the bottom of a short buffer matches its surrounding gap.
    api.nvim_set_hl(0, "EndOfBuffer",  { bg = "NONE" })
  end
  -- flash.nvim labels: gruvbox doesn't define these loudly enough, so we
  -- paint the jump labels in a high-contrast magenta/yellow combo.
  api.nvim_set_hl(0, "FlashLabel",    { fg = "#1d2021", bg = "#fb4934", bold = true })
  api.nvim_set_hl(0, "FlashMatch",    { fg = "#1d2021", bg = "#fabd2f", bold = true })
  api.nvim_set_hl(0, "FlashCurrent",  { fg = "#1d2021", bg = "#fe8019", bold = true })
  api.nvim_set_hl(0, "FlashBackdrop", { fg = "#665c54" })
  -- fzf-lua: react to vim.o.background so the picker + bat preview match
  -- the active gruvbox palette.
  local is_dark = vim.o.background == "dark"
  local fzf_bg       = is_dark and "#1d2021" or "#f2e5bc"
  local fzf_fg       = is_dark and "#ebdbb2" or "#3c3836"
  local fzf_border   = is_dark and "#504945" or "#bdae93"
  local fzf_cursor   = is_dark and "#3c3836" or "#ebdbb2"
  local fzf_accent   = is_dark and "#fabd2f" or "#b57614"
  local fzf_bind     = is_dark and "#83a598" or "#076678"
  local fzf_text     = is_dark and "#fb4934" or "#9d0006"
  api.nvim_set_hl(0, "FzfLuaNormal",        { bg = fzf_bg, fg = fzf_fg })
  api.nvim_set_hl(0, "FzfLuaBorder",        { bg = fzf_bg, fg = fzf_border })
  api.nvim_set_hl(0, "FzfLuaTitle",         { bg = fzf_bg, fg = fzf_accent, bold = true })
  api.nvim_set_hl(0, "FzfLuaPreviewNormal", { bg = fzf_bg, fg = fzf_fg })
  api.nvim_set_hl(0, "FzfLuaPreviewBorder", { bg = fzf_bg, fg = fzf_border })
  api.nvim_set_hl(0, "FzfLuaPreviewTitle",  { bg = fzf_bg, fg = fzf_accent, bold = true })
  api.nvim_set_hl(0, "FzfLuaCursor",        { bg = fzf_cursor, fg = fzf_fg })
  api.nvim_set_hl(0, "FzfLuaCursorLine",    { bg = fzf_cursor })
  api.nvim_set_hl(0, "FzfLuaCursorLineNr",  { bg = fzf_cursor, fg = fzf_accent })
  api.nvim_set_hl(0, "FzfLuaSearch",        { bg = fzf_accent, fg = fzf_bg, bold = true })
  api.nvim_set_hl(0, "FzfLuaHeaderBind",    { bg = fzf_bg, fg = fzf_bind })
  api.nvim_set_hl(0, "FzfLuaHeaderText",    { bg = fzf_bg, fg = fzf_text })
  -- Tell bat (spawned by fzf-lua for previews) which theme to use. fzf-lua
  -- inherits env vars when it spawns the previewer, so updating BAT_THEME
  -- here takes effect on the next picker invocation — no reload needed.
  vim.env.BAT_THEME = is_dark and "gruvbox-dark" or "gruvbox-light"
end

function M.light_background()
  load_theme "light"
  tweak_common()
  set_iterm_profile(ITERM_PROFILE_F2)
end

function M.dark_background()
  -- F1: miasma.nvim — dark, desaturated olive/green palette.
  vim.opt.termguicolors = true
  vim.opt.background = "dark"
  local ok = pcall(cmd, "colorscheme miasma")
  if not ok then
    pcall(cmd, "colorscheme gruvbox") -- graceful fallback
  end
  tweak_common()
  set_iterm_profile(ITERM_PROFILE_F1)
end

function M.transparent_background()
  -- F3: solarized dark (via maxmx03/solarized.nvim).
  vim.opt.termguicolors = true
  vim.opt.background = "dark"
  local ok_cfg = pcall(function()
    require("solarized").setup({ transparent = { enabled = false } })
  end)
  local ok = pcall(cmd, "colorscheme solarized")
  if not ok then
    pcall(cmd, "colorscheme gruvbox")
  end
  tweak_common()
  set_iterm_profile(ITERM_PROFILE_F3)
end

-- Auto-pick theme on startup from macOS Appearance (System Settings ->
-- Appearance). Dark -> F1 (miasma), Light -> F2 (gruvbox light). If
-- detection fails (non-macOS, `defaults` missing, etc.), default to F1.
-- F1/F2/F3 keys still override at any time.
function M.set_theme()
  if M.is_macos_dark_mode() then
    M.dark_background()
  else
    M.light_background()
  end
  cmd "set visualbell"
end

function M.zoom_toggle()
  if vim.t.zoomed then
    if vim.t.zoom_winrestcmd then
      cmd(vim.t.zoom_winrestcmd)
    end
    vim.t.zoomed = false
    return
  end
  vim.t.zoom_winrestcmd = fn.winrestcmd()
  cmd "resize"
  cmd "vertical resize"
  vim.t.zoomed = true
end

local hop_warning_shown = false

local function load_hop()
  local ok, hop = pcall(require, "hop")
  if ok then
    return hop
  end

  if not hop_warning_shown then
    hop_warning_shown = true
    vim.schedule(function()
      vim.notify("hop.nvim is not available; search mappings will fall back to their defaults", vim.log.levels.WARN, {
        title = "hop",
      })
    end)
  end

  return nil
end

function M.hop_patterns(opts)
  local hop = load_hop()
  if hop then
    hop.hint_patterns(opts or {})
    return true
  end
  return false
end

function M.hop_char1(opts)
  local hop = load_hop()
  if hop then
    hop.hint_char1(opts or {})
    return true
  end
  return false
end


function M.print_foobar()
  vim.notify("Foo Bar!", vim.log.levels.INFO, { title = "CtrlSpace" })
end

function M.check_backspace()
  local col = fn.col "." - 1
  if col <= 0 then
    return true
  end
  local line = fn.getline "."
  return line:sub(col, col):match "%s" ~= nil
end


function M.coc_current_function()
  return vim.b.coc_current_function or ""
end

function M.set_tmux_key_label(label)
  local term = uv.os_getenv("TERM")
  local sequence
  if term == "screen-256color" then
    sequence = string.format("\027Ptmux;\027\027]1337;SetKeyLabel=F6=%s\a\027\\", label)
  else
    sequence = string.format("\027]1337;SetKeyLabel=F6=%s\a", label)
  end
  fn.jobstart({ "bash", "-lc", string.format("printf '%s'", sequence) }, { detach = true })
end

api.nvim_create_user_command("Qargs", function()
  M.qargs()
end, {})

api.nvim_create_user_command("Qdo", function(opts)
  M.qdo(opts.bang, opts.args)
end, { bang = true, nargs = 1, complete = "command" })

api.nvim_create_user_command("GdiffInTab", function()
  -- Fugitive deprecated `:Gdiff` in favor of `:Gdiffsplit` (and it now
  -- collides with `Gdiffsplit!`, producing E464). Gdiffsplit does its own
  -- vertical split + loads the index/HEAD version in diff mode, so we no
  -- longer need the manual `:vsplit` that used to precede it.
  cmd "tabedit %"
  cmd "Gdiffsplit"
end, {})

-- :GdiffQF — project-wide "what changed" into the quickfix list.
--
-- Uses gitsigns' setqflist("all") which walks every tracked+dirty buffer
-- in the repo and emits one quickfix entry per hunk. Result: `:cnext` /
-- `:cprev` (bound to ]q/[q in mappings.lua) stepping through every change
-- in the working tree, each landing at the exact line of the hunk.
--
-- This is the "default diff UX" — it replaces the habit of `:Git diff`
-- (which dumps unparsable text in a scratch buffer) with a navigable list.
-- For the old tab-based side-by-side view, use :GdiffInTab.
api.nvim_create_user_command("GdiffQF", function()
  local ok, gs = pcall(require, "gitsigns")
  if not ok then
    vim.notify("gitsigns not available", vim.log.levels.ERROR)
    return
  end
  -- setqflist is async; open + jump to first entry from its callback so
  -- we don't race against an empty list.
  gs.setqflist("all", {
    use_location_list = false,
    open = false,
    callback = function()
      if #fn.getqflist() == 0 then
        vim.notify("No git hunks in the working tree", vim.log.levels.INFO)
        return
      end
      cmd "botright copen"
      cmd "cfirst"
    end,
  })
end, {})

api.nvim_create_user_command("Prettier", function()
  cmd "CocCommand prettier.forceFormatDocument"
end, {})

api.nvim_create_user_command("Format", function()
  fn.CocAction("format")
end, {})

api.nvim_create_user_command("Fold", function(opts)
  fn.CocAction("fold", table.unpack(opts.fargs))
end, { nargs = "?" })

_G.PrintFooBar = M.print_foobar
_G.CocCurrentFunction = M.coc_current_function

cmd [[cabbrev grep Ggrep]]
cmd [[cabbrev git Git]]
cmd [[abbrev requrie require]]

return M
