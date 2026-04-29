require "nvchad.mappings"

-- Override NvChad's tabufline <Tab>/<S-Tab> with the buffer picker
-- (this line must come *after* require "nvchad.mappings")
vim.keymap.set("n", "<Tab>", "<cmd>FzfLua buffers<CR>", { desc = "FZF buffers" })
vim.keymap.set("n", "<S-Tab>", "<cmd>FzfLua buffers<CR>", { desc = "FZF buffers" })

-- `-` = switch to alternate buffer (the file you were just in).
-- Same as vim's built-in <C-^>. Press twice to toggle back.
-- (Oil parent-dir was moved to `_`.)
vim.keymap.set("n", "-", "<C-^>", { silent = true, desc = "Alternate buffer" })

-- Nerdcommenter visual-mode mappings: force them explicitly so CopilotChat's
-- lazy.nvim keys spec (which claims ,cc in normal mode for chat toggle)
-- can't interfere with nerdcommenter's hasmapto() detection.
vim.keymap.set("x", "<leader>cc", "<Plug>NERDCommenterComment", { desc = "Comment" })
vim.keymap.set("x", "<leader>cu", "<Plug>NERDCommenterUncomment", { desc = "Uncomment" })
vim.keymap.set("x", "<leader>c<Space>", "<Plug>NERDCommenterToggle", { desc = "Toggle comment" })
vim.keymap.set("x", "<leader>cm", "<Plug>NERDCommenterMinimal", { desc = "Minimal comment" })
vim.keymap.set("x", "<leader>cs", "<Plug>NERDCommenterSexy", { desc = "Sexy comment" })
vim.keymap.set("x", "<leader>ci", "<Plug>NERDCommenterInvert", { desc = "Invert comment" })
vim.keymap.set("x", "<leader>cy", "<Plug>NERDCommenterYank", { desc = "Yank then comment" })

local map = vim.keymap.set
local user = require "user"
local fn = vim.fn
local api = vim.api
local deepcopy = vim.deepcopy

local function feedkeys(keys)
  api.nvim_feedkeys(api.nvim_replace_termcodes(keys, true, false, true), "n", true)
end

local function terminal_opener(opts)
  return function()
    feedkeys "<C-\\><C-n>"
    local args = deepcopy(opts or {})
    if args.orientation == nil then
      args.orientation = "horizontal"
    end
    vim.schedule(function()
      user.open_terminal(args)
    end)
  end
end

-- ============================================================
-- NOTE on plugin-managed mappings
-- ============================================================
-- The following are now declared via `keys = {}` in plugins/init.lua
-- to leverage lazy.nvim lazy-loading:
--
--   fzf-lua        :  <CR>, <C-g>, ?, mru, ge, gs, M
--   flash.nvim     :  s, S
--   oil.nvim       :  <leader>m, <leader>n, -
--   harpoon2       :  <leader>p*, <leader>1..4
--
-- gitsigns hunk nav (gj/gk) is set in the gitsigns on_attach callback.
-- ============================================================

-- folds / zoom
map("n", "zo", "zO", { remap = true })
map("n", "<C-z>", "<nop>")
map("n", "zz", "zi", { noremap = true })
map("n", "z+", "zr", { noremap = true })
map("n", "z-", "zm", { noremap = true })
map("n", "z1", "zR", { noremap = true })
map("n", "z0", "zM", { noremap = true })

-- bookmarks
map("n", "bm", "<Plug>BookmarkToggle")
map("n", "bi", "<Plug>BookmarkAnnotate")
map("n", "bn", "<Plug>BookmarkNext")
map("n", "bp", "<Plug>BookmarkPrev")
map("n", "ba", "<Plug>BookmarkShowAll")
map("n", "bC", "<Plug>BookmarkClearAll")
map("n", "bx", "<Plug>BookmarkClear")

-- small command-line shortcuts (move to/from marks)
map("c", "$t", "<CR>:t''<CR>", { noremap = true })
map("c", "$T", "<CR>:T''<CR>", { noremap = true })
map("c", "$m", "<CR>:m''<CR>", { noremap = true })
map("c", "$M", "<CR>:M''<CR>", { noremap = true })
map("c", "$d", "<CR>:d<CR>``", { noremap = true })

-- shortcuts
map("n", "%", "v%", { noremap = true })
map("n", "vib", "viB")
map("n", "cib", "ciB")
map("n", "yib", "yiB")
map("n", "a", "hea", { noremap = true })

-- tabs
map("t", "<F9>", [[<C-\><C-n><cmd>tabnext<CR>]], { silent = true })
map("t", "<F7>", [[<C-\><C-n><cmd>tabprevious<CR>]], { silent = true })
map("t", "<F8>", [[<C-\><C-n><cmd>tabnew<CR>]], { silent = true })
map("n", "<F9>", "<cmd>tabnext<CR>", { silent = true })
map("n", "<F7>", "<cmd>tabprevious<CR>", { silent = true })
map("n", "<F8>", "<cmd>tabnew<CR>", { silent = true })

-- IDE-style Ctrl+Tab cycling ---------------------------------------------
--   <C-Tab>    / <C-S-Tab>    -> next / prev buffer  (MRU-less, :bnext / :bprev)
--   <C-PageDown> / <C-PageUp> -> next / prev tab     (mirror F9 / F7)
--   <C-w><C-w>                -> next window (native; just a reminder)
--
-- iTerm caveat: iTerm2 swallows <C-Tab> by default for its own tab nav. To
-- forward it to nvim, add in iTerm Prefs → Keys → Key Bindings → [+]:
--   Keyboard Shortcut  : ^⇥        Action: Send Escape Sequence  [27;5;9~
--   Keyboard Shortcut  : ^⇧⇥       Action: Send Escape Sequence  [27;6;9~
-- (nvim ≥0.10 decodes these via libtermkey/CSI-u.)
map("n", "<C-Tab>",   "<cmd>bnext<CR>", { silent = true, desc = "Next buffer" })
map("n", "<C-S-Tab>", "<cmd>bprev<CR>", { silent = true, desc = "Prev buffer" })
map("t", "<C-Tab>",   [[<C-\><C-n><cmd>bnext<CR>]], { silent = true })
map("t", "<C-S-Tab>", [[<C-\><C-n><cmd>bprev<CR>]], { silent = true })

map("n", "<C-PageDown>", "<cmd>tabnext<CR>",     { silent = true, desc = "Next tab" })
map("n", "<C-PageUp>",   "<cmd>tabprevious<CR>", { silent = true, desc = "Prev tab" })
map("t", "<C-PageDown>", [[<C-\><C-n><cmd>tabnext<CR>]],     { silent = true })
map("t", "<C-PageUp>",   [[<C-\><C-n><cmd>tabprevious<CR>]], { silent = true })

-- Terminal-safe fallbacks that always work, no iTerm tweak required:
--   ]b / [b  -> next / prev buffer
--   ]t / [t  -> next / prev tab
map("n", "]b", "<cmd>bnext<CR>",     { silent = true, desc = "Next buffer" })
map("n", "[b", "<cmd>bprev<CR>",     { silent = true, desc = "Prev buffer" })
map("n", "]t", "<cmd>tabnext<CR>",   { silent = true, desc = "Next tab" })
map("n", "[t", "<cmd>tabprevious<CR>", { silent = true, desc = "Prev tab" })

-- <Space> = smart wincmd (count prefix picks window N)
map("n", "<Space>", function()
  if vim.v.count > 0 then
    return string.format(":<C-u>%d wincmd w<CR>", vim.v.count)
  end
  return "<C-w>"
end, { expr = true, silent = true, noremap = true })

-- misc
map("n", "cl", function()
  user.toggle_curline()
end, { silent = true, nowait = true })
map({ "n", "v", "o" }, "<F6>", "<cmd>Prettier<CR>", { silent = true, noremap = true })
map("n", "<C-o>", function()
  user.zoom_toggle()
end, { silent = true, noremap = true })
map("t", "<C-o>", [[<C-\><C-n><cmd>lua require('user').zoom_toggle()<CR>]], { silent = true })

-- ============================================================
-- Git layer — three complementary pickers, all live in one mental model:
--
--   bare `g*`     : fugitive one-shot commands (blame, diff, log, commit…)
--   `<leader>g*`  : fzf-lua pickers + fugitive status + GBrowse
--   `<leader>G*`  : gitsigns hunk ops (mnemonic: G = git hunks)
--
--   <leader>d  = "diff" (quickfix, project-wide, every hunk)
--   <leader>dt = "diff tab" (fugitive side-by-side in a new tab)
--   <leader>D  stays as :tabclose — don't clobber
--
-- Quickfix nav lives below under `]q/[q` so stepping through hunks
-- after <leader>d is one keystroke at a time.
-- ============================================================
map("n", "<leader>d",  "<cmd>GdiffQF<CR>",     { silent = true, noremap = true, desc = "Git diff → quickfix" })
map("n", "<leader>dt", "<cmd>GdiffInTab<CR>",  { silent = true, noremap = true, desc = "Git diff in new tab" })
map("n", "<leader>D",  "<cmd>tabclose<CR>",    { silent = true, noremap = true })

-- Bare `g*` — fugitive one-shots (keep the muscle memory)
map("n", "gb",  ":Git blame<CR>",           { nowait = true, desc = "Git blame (fugitive)" })
map("n", "gd",  ":Git diff<CR>",            { nowait = true, desc = "Git diff (text dump)" })
map("n", "gl",  ":Git log -15 --<CR>",      { nowait = true, desc = "Git log (last 15)" })
map("n", "gr",  ":Git reset HEAD %<CR>",    { nowait = true, desc = "Git reset HEAD (buffer)" })
map("n", "gck", ":Git checkout -- %<CR>",   { nowait = true, desc = "Git checkout -- (buffer)" })
map("n", "gc",  ":Git commit<CR>",          { nowait = true, desc = "Git commit" })
map("n", "gp",  ":Git push -f<CR>",         { nowait = true, desc = "Git push -f" })
map("n", "rm",  ":Git rm %<CR>",            { nowait = true, desc = "Git rm (buffer)" })
-- Buffer history into quickfix (step through every commit that touched
-- this file with ]q/[q).
map("n", "gh",  ":Gclog -- %<CR>",          { nowait = true, desc = "Git log for this buffer → quickfix" })

-- <leader>g* — fzf-lua pickers + fugitive status + GitHub permalink
map("n", "<leader>gs", "<cmd>Git<CR>",                  { silent = true, desc = "Fugitive :Git status (stage/commit)" })
-- Pass cwd = git root so fzf-lua git pickers work even when lcd'd away
map("n", "<leader>gl", function()
  require("fzf-lua").git_commits({ cwd = git_root_cwd() })
end, { silent = true, desc = "FZF git log (project)" })
map("n", "<leader>gL", function()
  require("fzf-lua").git_bcommits({ cwd = git_root_cwd() })
end, { silent = true, desc = "FZF git log (this buffer)" })
map("n", "<leader>gb", function()
  require("fzf-lua").git_branches({ cwd = git_root_cwd() })
end, { silent = true, desc = "FZF git branches" })
map("n", "<leader>gl", "<cmd>FzfLua git_commits<CR>",   { silent = true, desc = "FZF git log (project)" })
map("n", "<leader>gL", "<cmd>FzfLua git_bcommits<CR>",  { silent = true, desc = "FZF git log (this buffer)" })
map("n", "<leader>gb", "<cmd>FzfLua git_branches<CR>",  { silent = true, desc = "FZF git branches" })
map("n", "<leader>gf", "<cmd>FzfLua git_status<CR>",    { silent = true, desc = "FZF git status (files)" })
-- GBrowse (vim-rhubarb) — copy a GitHub permalink for the current line
-- (or visual selection). Works in the browser and in Slack/PRs.
map({ "n", "v" }, "<leader>gy", ":GBrowse!<CR>",        { silent = true, desc = "Copy GitHub permalink" })
map({ "n", "v" }, "<leader>gY", ":GBrowse<CR>",         { silent = true, desc = "Open in GitHub" })

-- Quickfix navigation — needed for the diff-to-qf workflow above but
-- useful for every quickfix producer (grep, Gclog, LSP references, …).
map("n", "]q", "<cmd>cnext<CR>",  { silent = true, desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<CR>",  { silent = true, desc = "Prev quickfix" })
map("n", "]Q", "<cmd>clast<CR>",  { silent = true, desc = "Last quickfix" })
map("n", "[Q", "<cmd>cfirst<CR>", { silent = true, desc = "First quickfix" })

-- easy-align
map("v", "<CR>", "<Plug>(EasyAlign)")

-- clipboard
map("n", "<leader>p", function()
  vim.cmd "silent! r! pbpaste"
end, { silent = true })
map("t", "<leader>p", [[<C-\><C-n><cmd>set paste<CR>"*p<cmd>set nopaste<CR>a]], { silent = true })

-- search toggles
map("n", "S", ":set hlsearch!<CR>", { noremap = true })
map("n", "i", ":noh<CR>i", { noremap = true, silent = true })

-- keep cursor centered on search / *
map("n", "n", "nzzzv", { noremap = true })
map("n", "N", "Nzzzv", { noremap = true })
map("n", "*", "*zzzv", { noremap = true })
map("n", "#", "#zzzv", { noremap = true })

-- join without moving cursor
map("n", "<BS>", "mzJ`z", { noremap = true })

-- syntax debug
map("n", "<F10>", function()
  vim.cmd([[echo "hi<" . synIDattr(synID(line('.'),col('.'),1),'name') . "> trans<" . synIDattr(synID(line('.'),col('.'),0),'name') . "> lo<" . synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name') . ">"]])
end, { silent = true })

-- themes
map({ "n", "v", "o" }, "<F1>", function() user.dark_background() end, { silent = true })
map({ "n", "v", "o" }, "<F2>", function() user.light_background() end, { silent = true })
map({ "n", "v", "o" }, "<F3>", function() user.transparent_background() end, { silent = true })

-- undotree
map("n", "<C-u>", function()
  if user.ensure_plugin "undotree" then
    vim.cmd.UndotreeToggle()
  end
end, { silent = true, noremap = true })
map("n", "U", "<C-r>", { noremap = true })

-- cd via selecta
map("n", "cd", function()
  user.selecta_command("find * -type d" .. (vim.g.excludes or ""), "", "lcd")
end, { noremap = true })

-- coc
map("i", "<C-l>", "<Plug>(coc-snippets-expand)")
map("v", "<C-j>", "<Plug>(coc-snippets-select)")
map("i", "<C-j>", "<Plug>(coc-snippets-expand-jump)")
map("i", "<Tab>", function()
  -- Priority order in insert mode:
  --   1. Copilot ghost-text suggestion visible → accept it
  --   2. coc completion menu open            → confirm selection
  --   3. coc snippet placeholder pending     → expand / jump
  --   4. cursor right after whitespace       → literal Tab (indent)
  --   5. otherwise                           → trigger coc refresh
  --
  -- Copilot.vim's own Tab binding is disabled via g:copilot_no_tab_map
  -- (plugins/init.lua), so we drive it ourselves here.
  local ok, sugg = pcall(vim.fn["copilot#GetDisplayedSuggestion"])
  if ok and sugg and type(sugg) == "table" and sugg.text and sugg.text ~= "" then
    return vim.fn["copilot#Accept"]("")
  end
  if fn.pumvisible() == 1 then
    return fn["coc#_select_confirm"]()
  elseif fn["coc#expandableOrJumpable"]() == 1 then
    return fn["coc#rpc#request"]("doKeymap", { "snippets-expand-jump", "" })
  elseif user.check_backspace() then
    return "\t"
  else
    fn["coc#refresh"]()
    return ""
  end
end, { expr = true, silent = true, replace_keycodes = false })
map("i", "<S-Tab>", function()
  if fn.pumvisible() == 1 then
    return vim.api.nvim_replace_termcodes("<C-p>", true, true, true)
  end
  return vim.api.nvim_replace_termcodes("<C-h>", true, true, true)
end, { expr = true, silent = true })
map("n", "<leader>rn", "<Plug>(coc-rename)")
map("x", "<leader>f", "<Plug>(coc-format-selected)")

-- rename current file (helper lives in user module)
map("n", "mv", function() user.rename_file() end, { noremap = true })

-- quick edit/save
map("n", "<leader>ev", "<cmd>edit $MYVIMRC<CR>", { silent = true })

-- Q in normal mode = quit everything, discard unsaved changes.
-- Overrides vim's default Q (enter Ex mode), which is almost never wanted.
-- Use :wqa if you want to save before quitting.
map("n", "Q", "<cmd>qa!<CR>", { silent = true, noremap = true, desc = "Quit all (no save)" })
-- `fd` in insert mode = Escape (no save). Quicker than reaching for ESC.
-- Not mapped in normal/visual mode because it collides with the `f` motion.
-- Exit insert mode AND write the buffer (if it makes sense to — see
-- user.save_if_real). `<Cmd>` runs the ex-command without leaving insert,
-- then the trailing `<Esc>` performs the actual mode change. Skips the
-- save during `:set paste`, on unnamed/non-modifiable/special buffers.
map("i", "<Esc>", "<Cmd>lua require('user').save_if_real()<CR><Esc>",
    { silent = true, desc = "Esc + save" })
map("i", "fd",    "<Cmd>lua require('user').save_if_real()<CR><Esc>",
    { silent = true, noremap = true, desc = "fd = Esc + save" })

-- Helper: find git root for the current buffer (falls back to file's dir).
-- Used by fzf-lua git pickers + live_grep so search runs from the repo
-- root instead of the lcd'd buffer dir.
local function git_root_cwd()
  local f = api.nvim_buf_get_name(0)
  local dir = (f ~= "" and fn.fnamemodify(f, ":p:h")) or fn.getcwd()
  local root = vim.fn.systemlist("git -C " .. fn.shellescape(dir) .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error == 0 and root and root ~= "" then
    return root
  end
  return dir
end

-- terminal splits (opened via user helper)
-- Both <C-f>* and <C-g>* work — historical muscle memory preserved.
map("n", "<C-f>v", function() user.open_terminal { orientation = "vertical", kill = "kill" } end, { silent = true })
map("n", "<C-f>s", function() user.open_terminal { orientation = "horizontal", kill = "kill" } end, { silent = true })
map("n", "<C-f>t", function() user.open_terminal { orientation = "horizontal", kill = "kill", rows = 25 } end, { silent = true })
map("n", "<C-f>=", function() user.open_terminal { orientation = "horizontal", kill = "kill", rows = 25 } end, { silent = true })
map("n", "<C-g>v", function() user.open_terminal { orientation = "vertical", kill = "kill" } end, { silent = true })
map("n", "<C-g>s", function() user.open_terminal { orientation = "horizontal", kill = "kill" } end, { silent = true })
map("n", "<C-g>t", function() user.open_terminal { orientation = "horizontal", kill = "kill", rows = 25 } end, { silent = true })
map("n", "<C-g>=", function() user.open_terminal { orientation = "horizontal", kill = "kill", rows = 25 } end, { silent = true })

-- window nav (normal + terminal)
map("n", "<C-k>", "<cmd>wincmd k<CR>", { silent = true })
map("n", "<C-h>", "<cmd>wincmd h<CR>", { silent = true })
map("n", "<C-l>", "<cmd>wincmd l<CR>", { silent = true })
map("n", "<C-j>", "<cmd>wincmd j<CR>", { silent = true })
map("n", "<S-Up>", "<cmd>resize +5<CR>", { silent = true })
map("n", "<S-Down>", "<cmd>resize -5<CR>", { silent = true })
map("n", "<S-Left>", "<cmd>vertical resize -5<CR>", { silent = true })
map("n", "<S-Right>", "<cmd>vertical resize +5<CR>", { silent = true })

-- terminal mode
map("t", "<leader>f", [[<C-\><C-n>:set nomore<CR>:ls<CR>:set more<CR>:b ]], { silent = true })
map("t", "<C-f>:", [[<C-\><C-n>:]], { nowait = true })
map("t", "<C-g>v", terminal_opener { orientation = "vertical", kill = "int" }, { silent = true })
map("t", "<C-g>s", terminal_opener { kill = "int" }, { silent = true })
map("t", "fd", [[<C-\><C-n>]], { nowait = true })
map("t", "gt", [[<C-\><C-n><cmd>tabnext<CR>]], { nowait = true })
map("t", ":q", [[<C-\><C-n><cmd>q!<CR>]], { nowait = true })
map("t", "<C-k>", [[<C-\><C-n><cmd>wincmd k<CR>]], { silent = true })
map("t", "<C-h>", [[<C-\><C-n><cmd>wincmd h<CR>]], { silent = true })
map("t", "<C-l>", [[<C-\><C-n><cmd>wincmd l<CR>]], { silent = true })
map("t", "<C-j>", [[<C-\><C-n><cmd>wincmd j<CR>]], { silent = true })
map("t", "<S-Up>", [[<C-\><C-n><cmd>resize +5<CR>]], { silent = true })
map("t", "<S-Down>", [[<C-\><C-n><cmd>resize -5<CR>]], { silent = true })
map("t", "<S-Left>", [[<C-\><C-n><cmd>vertical resize +5<CR>]], { silent = true })
map("t", "<S-Right>", [[<C-\><C-n><cmd>vertical resize -5<CR>]], { silent = true })
map("t", "<leader>S", [[<C-\><C-n><cmd>aboveleft new<CR>]], { silent = true })
map("t", "<leader>V", [[<C-\><C-n><cmd>aboveleft vert new<CR>]], { silent = true })
map("t", "<leader>s", [[<C-\><C-n><cmd>new<CR>]], { silent = true })
map("t", "<leader>v", [[<C-\><C-n><cmd>vert new<CR>]], { silent = true })
-- <C-f>* and <C-g>* terminal openers (mirror the normal-mode ones above)
map("t", "<C-f>v", terminal_opener { orientation = "vertical", kill = "int" }, { silent = true })
map("t", "<C-f>s", terminal_opener { kill = "int" }, { silent = true })
map("t", "<C-f>t", terminal_opener { kill = "int", rows = 25 }, { silent = true })
map("t", "<C-f>=", [[<C-\><C-n><C-w>=]])
map("t", "<C-g>t", terminal_opener { kill = "int", rows = 25 }, { silent = true })
map("t", "<C-g>=", [[<C-\><C-n><C-w>=]])

-- motion (kept)
map("n", "j", "jzz", { noremap = true })
map("n", "k", "kzz", { noremap = true })
map("n", "l", "e", { noremap = true })
map("n", "h", "b", { noremap = true })
map("n", "J", "10jzz", { noremap = true })
map("n", "K", "10kzz", { noremap = true })
map("n", "H", "5b", { noremap = true })
map("n", "L", "5e", { noremap = true })

-- quickfix / loclist via arrows
map("n", "<Down>", "<cmd>cn<CR>", { silent = true })
map("n", "<Up>", "<cmd>cp<CR>", { silent = true })
map("n", "<Right>", "<cmd>copen<CR>", { silent = true })
map("n", "<Left>", "<cmd>cclose<CR>", { silent = true })
map("n", "<C-Down>", "<cmd>lne<CR>", { silent = true })
map("n", "<C-Up>", "<cmd>lpr<CR>", { silent = true })
map("n", "<C-Right>", "<cmd>lop<CR>", { silent = true })
map("n", "<C-Left>", "<cmd>lcl<CR>", { silent = true })

-- splits
map("n", "<leader>S", "<cmd>aboveleft split<CR>")
map("n", "<leader>V", "<cmd>aboveleft vsplit<CR>")
map("n", "<leader>s", "<cmd>split<CR>")
map("n", "<leader>v", "<cmd>vsplit<CR>")
