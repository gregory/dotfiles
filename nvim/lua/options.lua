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
-- encoding and fileencoding removed: nvim is always utf-8 and setting
-- fileencoding on a non-modifiable buffer (NvChad splash) throws E21.
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
-- Enable mouse in all modes so the wheel scrolls fzf-lua's builtin
-- previewer and, critically, so drag-selection stays scoped to the nvim
-- window where the drag started (otherwise iTerm's native terminal
-- selection bleeds across vertical/horizontal splits). Hold Option/Alt
-- in iTerm if you ever need to force native terminal selection.
opt.mouse = "a"

-- Share yank register with the macOS system clipboard. Without this,
-- visually selecting with the mouse + pressing `y` copies to vim's
-- unnamed register only — Cmd+V in other apps stays empty. With it,
-- any yank (including the `y` after a mouse drag) lands in pbpaste.
opt.clipboard = "unnamedplus"

-- Make the vertical split separator a blank space instead of │ / |.
-- When you drag-select across a split with iTerm-native selection
-- (Option+drag, or simply when mouse mode isn't capturing), the copied
-- text won't include a stray separator character. The column is still
-- visually distinguishable via the WinSeparator highlight.
opt.fillchars:append({ vert = " ", vertleft = " ", vertright = " ",
                       horiz = " ", horizup = " ", horizdown = " ",
                       verthoriz = " " })
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

-- ~70 lines of plugin globals were removed from here. Every one configured a
-- plugin that is either not installed at all, or was installed but unreachable
-- (no trigger under defaults = { lazy = true }):
--
--   polyglot_disabled           -> vim-polyglot removed; treesitter now
--   AutoPairs*                  -> auto-pairs removed; nvim-autopairs is active
--   ale_*                       -> ALE was never installed; eslint-lsp now
--   EasyMotion_*                -> replaced by flash.nvim
--   smartpairs_uber_mode        -> not installed
--   CtrlSpace*                  -> removed (harpoon covers pinned buffers)
--   NERDTree*                   -> removed (neo-tree + oil)
--   acp_enableAtStartup         -> not installed
--   terraform_*                 -> vim-terraform removed; terraformls now
--   tcd_blacklist               -> not installed
--   signify_*                   -> replaced by gitsigns
--   prettier#*                  -> vim-prettier not installed; conform now
--   html_no_rendering, javascript_enable_domhtmlcss -> polyglot-era
--   indent_guides_*             -> indent-blankline is enabled = false
--   fzf_action                  -> for junegunn/fzf.vim, which is gone;
--                                  fzf-lua uses its own `actions` table
--   Choosewin_overlay_enable    -> not installed
--
-- Kept below: bookmark_* (vim-bookmarks is live), undotree_*, and g.ignore /
-- g.excludes (g.ignore is consumed by autocmds.lua).

g.bookmark_save_per_working_dir = 1
g.bookmark_auto_save = 1

-- coc globals removed along with coc.nvim. Note coc_node_path pointed at
-- ~/.nvm/versions/node/v16.12.0/bin/node — a version that is not installed
-- (only 18/22/24 were, and nvm itself is gone now in favour of fnm). That is
-- exactly why language servers are installed through mason rather than pinned
-- to a node path: see chadrc.lua.
--
-- g.AutoPairs removed too: jiangmiao/auto-pairs is gone, and nvim-autopairs
-- (which NvChad ships as an nvim-cmp dependency) is what is actually running.

g.undotree_SetFocusWhenToggle = 1

-- lightline removed — using NvChad's built-in statusline.

g.ignore ={ ".git", "node_modules/", "packages", "vendor", ".svg", ".eot", "log/", ".jpg", [[\/\.]], [[^\..*]] }
local joined = {}
for _, pattern in ipairs(g.ignore) do
  table.insert(joined, pattern)
end
g.excludes = " \\| GREP_OPTIONS='' egrep -v -e '" .. table.concat(joined, "\\|") .. "'"

-- lightline_theme removed with lightline.

