require "nvchad.options"

local opt = vim.opt
local g = vim.g
local fn = vim.fn

opt.autoindent = true
opt.autowrite = true
opt.backspace = { "indent", "eol", "start" }
opt.colorcolumn = "100"
opt.copyindent = true
opt.cursorline = false
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.expandtab = true
opt.hidden = true
opt.hlsearch = true
opt.incsearch = true
opt.laststatus = 2
-- lazyredraw breaks flash.nvim label rendering (labels flicker / don't
-- appear). Disable it; modern nvim doesn't benefit from it much anyway.
opt.lazyredraw = false
opt.linebreak = true
opt.list = false
opt.listchars = { tab = ">.", trail = ".", extends = "#", nbsp = "." }
opt.mouse = ""
opt.backup = false
opt.errorbells = false
opt.eadirection = "ver"
opt.number = false
opt.swapfile = false
opt.writebackup = false
opt.shortmess:append "c"
opt.signcolumn = "yes"
opt.scrolloff = 3
opt.shell = "/bin/zsh"
opt.shiftround = true
opt.shiftwidth = 2
opt.showmatch = false
opt.showmode = false
opt.showtabline = 2
opt.smartcase = true
opt.ignorecase = true
opt.smartindent = true
opt.smarttab = true
opt.softtabstop = 2
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 2
opt.textwidth = 100
opt.title = true
opt.undolevels = 1000
opt.visualbell = true
opt.viminfo = "'100,f1"
opt.wildignore = { "*.swp", "*.bak", "*.pyc", "*.class" }
opt.wildmenu = true
opt.wildmode = "longest:full:full"
opt.formatoptions = "l"
opt.autoread = true
opt.path:append "**"
pcall(function()
  opt.ttymouse = "xterm2"
end)
opt.cpoptions:append "$"

vim.cmd "syntax enable"
vim.cmd "filetype plugin indent on"

if fn.has "persistent_undo" == 1 then
  local undo_dir = fn.stdpath("state") .. "/undo"
  fn.mkdir(undo_dir, "p")
  opt.undofile = true
  opt.undodir = undo_dir
end

g.polyglot_disabled = { "javascript" }
g.AutoPairsFlyMode = 1
g.AutoPairsMapCR = 0
g.AutoPairsShortcutBackInsert = "<c-b>"
g.ale_fixers = { ["*"] = { "remove_trailing_lines", "trim_whitespace" }, javascript = { "eslint" } }
g.ale_fix_on_save = 1
g.ale_lint_on_text_changed = "never"
g.ale_keep_list_window_open = 1
g.ale_set_loclist = 1

g.EasyMotion_smartcase = 1
g.smartpairs_uber_mode = 1

g.bookmark_save_per_working_dir = 1
g.bookmark_auto_save = 1
g.CtrlSpaceDefaultMappingKey = "<x>"
g.CtrlSpaceSaveWorkspaceOnSwitch = 1
g.CtrlSpaceKeys = { Buffer = { b = "PrintFooBar" } }

g.NERDTreeMinimalUI = 1
g.NERDTreeWinSize = 40
g.NERDTreeDirArrows = 0
g.NERDTreeQuitOnOpen = 1
g.NERDTreeAutoDeleteBuffer = 1
g.NERDTreeIgnore = { "^node_modules$[[dir]]", "^coverage$[[dir]]" }

g.acp_enableAtStartup = 0
g.terraform_completion_keys = 1
g.terraform_registry_module_completion = 0

g.EasyMotion_do_mapping = 0
g.EasyMotion_startofline = 0

g.tcd_blacklist = [[\v(cheat40|denite|gundo|help|nerdtree|netrw|peekaboo|quickmenu|startify|tagbar|undotree|unite|vimfiler|vimshell|fzf)]]

g.signify_vcs_list = { "git" }
g.signify_sign_change = "~"

g["prettier#autoformat"] = 1
g["prettier#config#trailing_comma"] = "none"
g["prettier#config#bracket_spacing"] = "true"
g["prettier#config#print_width"] = 100

g["asterisk#keeppos"] = 1
g.coc_snippet_next = "<c-j>"
g.coc_snippet_prev = "<c-k>"
g.coc_node_path = fn.expand "~/.nvm/versions/node/v16.12.0/bin/node"

g.AutoPairs = g.AutoPairs or {}

g.undotree_SetFocusWhenToggle = 1

g.html_no_rendering = 1

g.lightline = {
  active = {
    left = {
      { "mode", "paste" },
      { "filename", "modified" },
    },
    right = {
      { "position", "modified" },
      { "percent", "filetype", "fileencoding" },
      { "syntastic", "cocstatus" },
    },
  },
  inactive = {
    left = {
      { "filename", "modified" },
    },
    right = {
      { "position" },
    },
  },
  component_function = {
    gitbranch = "fugitive#head",
    filename = "LightlineFilename",
    fileencoding = "LightlineFileEncoding",
    filetype = "LightlineFiletype",
    mode = "LightlineMode",
    cocstatus = "coc#status",
    currentfunction = "CocCurrentFunction",
  },
  component = { charvaluehex = "0x%B", position = "%{winnr()}: %n %2l:%-1v" },
  component_expand = { syntastic = "SyntasticStatuslineFlag" },
  component_type = { syntastic = "error" },
  subseparator = { left = ">", right = ">" },
  separator = { left = "", right = "" },
}

g.lightline.tab = {
  active = { "tabnum", "filename", "modified" },
  inactive = { "tabnum", "filename", "modified" },
}

g.javascript_enable_domhtmlcss = 1

g.indent_guides_enable_on_vim_startup = 1
g.indent_guides_auto_colors = 0
g.indent_guides_start_level = 1
g.indent_guides_guide_size = 1
g.indent_guides_color_change_percent = 100

g.ignore = { ".git", "node_modules/", "packages", "vendor", ".svg", ".eot", "log/", ".jpg", [[\/\.]], [[^\..*]] }
local joined = {}
for _, pattern in ipairs(g.ignore) do
  table.insert(joined, pattern)
end
g.excludes = " \\| GREP_OPTIONS='' egrep -v -e '" .. table.concat(joined, "\\|") .. "'"

g.fzf_action = {
  ["ctrl-o"] = "tab split",
  ["ctrl-s"] = "split",
  ["ctrl-v"] = "vsplit",
  ["ctrl-q"] = function(lines)
    local items = {}
    for _, line in ipairs(lines) do
      table.insert(items, { filename = line })
    end
    vim.fn.setqflist(items)
    vim.cmd "copen"
    vim.cmd "cc"
  end,
}

g.lightline_theme = "Greg"

g.Choosewin_overlay_enable = 1

