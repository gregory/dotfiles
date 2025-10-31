local M = {}

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local uv = vim.uv or vim.loop
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
  local buf_dir = fn.expand "%:p:h"
  if buf_dir ~= "" then
    cmd("lcd " .. fn.fnameescape(buf_dir))
  end
  local git_dir = trim(fn.system "git rev-parse --show-toplevel")
  if git_dir ~= "" and not git_dir:match "^fatal:" then
    cmd("lcd " .. fn.fnameescape(git_dir))
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

function M.trim_trailing_whitespace()
  local view = fn.winsaveview()
  local search = fn.getreg "/"
  cmd [[%s/\s\+$//e]]
  cmd [[silent! g/^\n\{2,}/d]]
  fn.setreg("/", search)
  fn.winrestview(view)
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
  cmd "hi Normal ctermbg=none"
  cmd "hi Terminal ctermbg=none"
end

function M.light_background()
  cmd "set notermguicolors"
  if vim.go.t_Co ~= nil then
    vim.go.t_Co = 256
  end
  cmd "set background=light"
  vim.g.one_allow_italics = 1
  cmd "hi Comment cterm=italic"
  cmd "hi! link javascriptOperator Identifier"
  cmd "hi Terminal ctermfg=23 ctermbg=255"
  cmd "hi! link IndentGuidesEven CursorLine"
  cmd "hi! link IndentGuidesOdd Noise"
  vim.g.indent_guides_guide_size = 2
end

function M.dark_background()
  cmd "set notermguicolors"
  if vim.go.t_Co ~= nil then
    vim.go.t_Co = 256
  end
  cmd "set background=dark"
  if fn.empty(fn.globpath(vim.o.runtimepath, "colors/gruvbox.vim")) == 0 then
    cmd "colorscheme gruvbox"
  end
  cmd "hi Comment cterm=italic"
  vim.g.indent_guides_guide_size = 2
  cmd "hi! link IndentGuidesEven CursorLine"
  cmd "hi! link IndentGuidesOdd Noise"
  cmd "hi Terminal ctermfg=145 ctermbg=235"
  vim.g.lightline.colorscheme = "Greg"
  M.set_transparency()
end

function M.transparent_background()
  cmd "set notermguicolors"
  if vim.go.t_Co ~= nil then
    vim.go.t_Co = 256
  end
  cmd "set background=dark"
  if fn.empty(fn.globpath(vim.o.runtimepath, "colors/onedark.vim")) == 0 then
    cmd "colorscheme onedark"
  end
  cmd "hi Comment cterm=italic"
  cmd "hi! link javascriptOperator Identifier"
  vim.g.indent_guides_guide_size = 2
  cmd "hi! link IndentGuidesEven CursorLine"
  cmd "hi! link IndentGuidesOdd Noise"
  cmd "hi Terminal ctermfg=145 ctermbg=235"
  vim.g.lightline.colorscheme = "Greg"
  M.set_transparency()
end

function M.set_theme()
  local profile = uv.os_getenv("ITERM_PROFILE")
  if profile == "Dark" then
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

local function lightline_should_suppress()
  local ft = vim.bo.filetype or ""
  return ft ~= "" and ft:match(vim.g.tcd_blacklist or "") ~= nil
end

function M.lightline_filename()
  local git_dir = fn.fnamemodify(fn.getbufvar(0, "git_dir", ""), ":h")
  local path = fn.expand "%:p"
  if git_dir ~= "" and path:sub(1, #git_dir) == git_dir then
    local file = path:sub(#git_dir + 2)
    if not lightline_should_suppress() or fn.winwidth(0) > #file then
      return file
    end
    return ""
  end
  if not lightline_should_suppress() and fn.winwidth(0) > 70 then
    return fn.expand "%"
  end
  if vim.bo.filetype ~= "" then
    return "[" .. vim.bo.filetype .. "]"
  end
  return ""
end

function M.lightline_mode()
  local name = fn.expand "%:t"
  if name == "__Tagbar__" then
    return "Tagbar"
  end
  if name == "ControlP" then
    return "CtrlP"
  end
  local ft = vim.bo.filetype
  if ft == "vimfiler" then
    return "VimFiler"
  end
  if ft == "javascript.jsx" or ft == "javascript" then
    return "[JS]"
  end
  if ft == "" then
    return fn["lightline#mode"]()
  end
  return "[" .. ft .. "]"
end

function M.lightline_fileencoding()
  if fn.winwidth(0) > 100 then
    return vim.bo.fileencoding ~= "" and vim.bo.fileencoding or ""
  end
  return ""
end

function M.lightline_filetype()
  if fn.winwidth(0) > 100 then
    return vim.bo.filetype ~= "" and vim.bo.filetype or "<>"
  end
  return ""
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
  cmd "tabedit %"
  cmd "vsplit"
  cmd "Gdiff"
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
_G.LightlineFilename = M.lightline_filename
_G.LightlineMode = M.lightline_mode
_G.LightlineFileEncoding = M.lightline_fileencoding
_G.LightlineFiletype = M.lightline_filetype
_G.CocCurrentFunction = M.coc_current_function

cmd [[cabbrev grep Ggrep]]
cmd [[cabbrev git Git]]
cmd [[abbrev requrie require]]

return M
