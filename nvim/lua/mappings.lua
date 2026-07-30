require "nvchad.mappings"

-- Override NvChad's tabufline <Tab>/<S-Tab> with the buffer picker
-- (this line must come *after* require "nvchad.mappings")
vim.keymap.set("n", "<Tab>", "<cmd>FzfLua buffers<CR>", { desc = "FZF buffers" })
vim.keymap.set("n", "<S-Tab>", "<cmd>FzfLua buffers<CR>", { desc = "FZF buffers" })

-- `-` = switch to alternate buffer (the file you were just in).
-- Same as vim's built-in <C-^>. Press twice to toggle back.
-- (Oil parent-dir was moved to `_`.)
vim.keymap.set("n", "-", "<C-^>", { silent = true, desc = "Alternate buffer" })

-- Commenting: Neovim's built-in `gc` (since 0.10) replaces nerdcommenter, which
-- was loading eagerly (lazy = false) purely to provide these <Plug> maps — and
-- was unreachable for anything else anyway.
--
-- `gc` toggles, so the old cc/cu/<Space> trio collapses into one binding.
-- Dropped without replacement: cm/cs (minimal/sexy comment styles) and ci
-- (invert) have no builtin equivalent; cy (yank then comment) is `y` then `gc`.
-- NvChad also gives you <leader>/ -> gcc / gc.
-- x-mode only: <leader>cc in NORMAL mode is the AI chat toggle (see the AI
-- block at the end of this file).
vim.keymap.set("x", "<leader>cc", "gc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("x", "<leader>c<Space>", "gc", { remap = true, desc = "Toggle comment" })

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
-- <F6> = format. Was `:Prettier`, a coc command — coc never loads, so this
-- threw. conform handles it, falling back to the LSP formatter where no
-- external formatter is configured.
map({ "n", "v", "o" }, "<F6>", function()
  require("conform").format { async = true, lsp_format = "fallback" }
end, { silent = true, noremap = true, desc = "Format buffer/selection" })
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
map("n", "gl",  ":Git log -15 --<CR>",      { nowait = true, desc = "Git log (last 15)" })
-- `gd` and `gr` deliberately moved to <leader>g*, because both collided with
-- LSP:
--   gd -> NvChad maps it BUFFER-LOCALLY to vim.lsp.buf.definition on LspAttach,
--         and buffer-local beats global, so :Git diff silently disappeared in
--         every code buffer the moment servers started working.
--   gr -> a complete mapping AND the prefix of six nvim 0.12 builtins (grn
--         rename, gra code action, grr references, gri implementation, grt type
--         definition, grx codelens). Every one of them waited out timeoutlen.
--         Freeing the prefix gets all six for nothing.
-- Moving `Git reset HEAD %` off a bare two-key sequence is a bonus: it is
-- destructive.
map("n", "<leader>gd", ":Git diff<CR>",         { nowait = true, desc = "Git diff (text dump)" })
map("n", "<leader>gu", ":Git reset HEAD %<CR>", { nowait = true, desc = "Git unstage buffer" })
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

-- `cd` unmapped. It called user.selecta_command, and `selecta` is not
-- installed — so it was a silent no-op that also hit an E117 in that helper
-- (fn.shell_error() — no such function; it is vim.v.shell_error).
-- Leaving `cd` unmapped restores the `c` + `d` operator-motion, and removes the
-- timeoutlen delay it was adding to every `c` press.
-- For fuzzy directory jumping, `<leader>ff` / `cdw` in the shell cover it.

-- Insert-mode <Tab>: Copilot first, then let nvim-cmp and Neovim's own defaults
-- handle the rest.
--
-- The old chain called coc#_select_confirm / coc#expandableOrJumpable /
-- coc#refresh. coc.nvim never loads (its spec has no trigger under
-- defaults = { lazy = true }), so those threw E117 — specifically whenever the
-- cmp menu was CLOSED and the cursor sat after a non-blank, because nvim-cmp
-- installs its own global <Tab> and stashed this one as its fallback.
--
-- What handles it now, in order:
--   0. sidekick has a Next Edit Suggestion pending -> jump to it / apply it
--   1. Copilot ghost text visible          -> accept it
--   2. cmp menu open                       -> cmp's own <Tab> selects next
--   3. LuaSnip placeholder pending         -> cmp's <Tab> jumps
--   4. otherwise                           -> Neovim's default <Tab>, which
--                                             since 0.12 is vim.snippet.jump
-- Copilot's own Tab binding stays disabled via g:copilot_no_tab_map.
--
-- NES goes FIRST: it is the "next place you need to edit" prediction, so it has
-- to win over accepting inline text at the cursor.
map("i", "<Tab>", function()
  local ok_sk, sk = pcall(require, "sidekick")
  if ok_sk and sk.nes_jump_or_apply() then
    return ""
  end
  local ok, sugg = pcall(vim.fn["copilot#GetDisplayedSuggestion"])
  if ok and sugg and type(sugg) == "table" and sugg.text and sugg.text ~= "" then
    return vim.fn["copilot#Accept"] ""
  end
  return "<Tab>"
end, { expr = true, silent = true, replace_keycodes = false })

-- Normal-mode <Tab> deliberately stays the buffer picker (set at the top of this
-- file). Making it conditionally jump to a NES would mean a heavily-used key
-- doing two different things depending on invisible state. NES lives on
-- insert-mode <Tab> only; <leader>an jumps to a pending one from normal mode.
map("n", "<leader>an", function()
  local ok_sk, sk = pcall(require, "sidekick")
  if not (ok_sk and sk.nes_jump_or_apply()) then
    vim.notify("No next-edit suggestion pending", vim.log.levels.INFO)
  end
end, { desc = "Jump to next-edit suggestion" })

-- <S-Tab>, <C-l>, <C-j>, <leader>rn and <leader>f were all coc bindings.
-- Removed: cmp handles <S-Tab>; <C-l>/<C-j> go back to NvChad's cursor motions;
-- rename is `grn` (builtin) or <leader>ra (NvChad's NvRenamer), which
-- <leader>rn was shadowing; range formatting is <F6> via conform.

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

-- ─── LSP ───────────────────────────────────────────────────────────────────
-- Most of what you'd reach for already ships with nvim 0.12 and only needed
-- un-shadowing (see the gd/gr note above): grn rename, gra code action,
-- grr references, gri implementation, grt type definition, gO symbols,
-- ]d/[d/]D/[D diagnostics, <C-W>d diagnostic float, <C-S> signature help.
-- Note <Space> is an expr map to <C-w>, so <Space>d opens the diagnostic float.

-- Hover. Cannot live on `K` — that is `10kzz` here, and nvim only claims K when
-- it is unmapped (lsp.lua checks maparg('K') == ''), so hover simply had no key.
map("n", "gK", vim.lsp.buf.hover, { desc = "LSP hover" })

-- Route the builtin gr* list-producers through fzf-lua, which is the picker
-- that is actually configured here. Each still supports send-to-quickfix, so
-- ]q/[q keeps working.
map("n", "grr", "<cmd>FzfLua lsp_references<CR>",       { desc = "LSP references" })
map("n", "gri", "<cmd>FzfLua lsp_implementations<CR>",  { desc = "LSP implementations" })
map("n", "gO",  "<cmd>FzfLua lsp_document_symbols<CR>", { desc = "LSP document symbols" })
map({ "n", "x" }, "gra", "<cmd>FzfLua lsp_code_actions<CR>", { desc = "LSP code actions" })

-- Diagnostics as a list ("issues"). <leader>i / <leader>I were both free.
map("n", "<leader>i", "<cmd>FzfLua diagnostics_document<CR>",  { desc = "Diagnostics (buffer)" })
map("n", "<leader>I", "<cmd>FzfLua diagnostics_workspace<CR>", { desc = "Diagnostics (workspace)" })

-- `gd` -> definition via fzf-lua, and drop NvChad's buffer-local <leader>D so
-- <leader>D stays :tabclose (grt already covers type definition).
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspMaps", { clear = true }),
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions<CR>",
      vim.tbl_extend("force", opts, { desc = "LSP definitions" }))
    pcall(vim.keymap.del, "n", "<leader>D", { buffer = args.buf })
  end,
})

-- ─── Re-point NvChad's telescope / nvim-tree keys ──────────────────────────
-- telescope.nvim and nvim-tree.lua are disabled (plugins/init.lua) in favour of
-- fzf-lua and neo-tree, but NvChad maps 12 keys to them unconditionally in
-- nvchad/mappings.lua. Without these overrides they'd fail with
-- "Not an editor command: Telescope". This block must stay AFTER
-- `require "nvchad.mappings"` at the top of this file.
map("n", "<leader>ff", "<cmd>FzfLua files<CR>",            { desc = "Find files" })
map("n", "<leader>fa", "<cmd>FzfLua files hidden=true no_ignore=true<CR>", { desc = "Find files (all)" })
map("n", "<leader>fw", "<cmd>FzfLua live_grep<CR>",        { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>",          { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>FzfLua helptags<CR>",         { desc = "Help tags" })
map("n", "<leader>fo", "<cmd>FzfLua oldfiles<CR>",         { desc = "Recent files" })
map("n", "<leader>fz", "<cmd>FzfLua blines<CR>",           { desc = "Find in buffer" })
map("n", "<leader>cm", "<cmd>FzfLua git_commits<CR>",      { desc = "Git commits" })
map("n", "<leader>gt", "<cmd>FzfLua git_status<CR>",       { desc = "Git status" })
map("n", "<C-n>",      "<cmd>Neotree toggle<CR>",          { desc = "Neotree toggle" })
map("n", "<leader>e",  "<cmd>Neotree focus<CR>",           { desc = "Neotree focus" })

-- Deleted rather than re-pointed: both are telescope-only pickers AND both made
-- a shorter mapping ambiguous — <leader>ma delayed <leader>m (neo-tree) and
-- <leader>pt delayed <leader>p* (harpoon) by timeoutlen on every press.
-- Marks are on `M` (FzfLua marks); terminals on <C-f>*/<C-g>*.
pcall(vim.keymap.del, "n", "<leader>ma")
pcall(vim.keymap.del, "n", "<leader>pt")

-- ─── AI: remap the old CopilotChat ,c* keys onto codecompanion ──────────────
-- CopilotChat.nvim is removed (plugins/init.lua). Keeping the muscle memory:
-- ,cc still opens a chat, and the action-oriented ones go through
-- CodeCompanion's inline assistant with an explicit instruction.
map("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI chat toggle" })
map({ "n", "x" }, "<leader>cp", "<cmd>CodeCompanionActions<cr>", { desc = "AI prompt palette" })
map({ "n", "x" }, "<leader>ce", ":CodeCompanion explain this<cr>", { desc = "AI explain" })
map({ "n", "x" }, "<leader>cf", ":CodeCompanion fix the diagnostics here<cr>", { desc = "AI fix" })
map({ "n", "x" }, "<leader>ct", ":CodeCompanion write tests for this<cr>", { desc = "AI tests" })
map({ "n", "x" }, "<leader>cr", ":CodeCompanion review this for bugs and issues<cr>", { desc = "AI review" })
map({ "n", "x" }, "<leader>co", ":CodeCompanion optimise this<cr>", { desc = "AI optimise" })
map({ "n", "x" }, "<leader>cd", ":CodeCompanion add documentation<cr>", { desc = "AI docs" })

-- ─── Quickfix: diagnostics and project lint ─────────────────────────────────
-- `,q` was one of only five free <leader> prefixes (o q u y z), and it is the
-- natural mnemonic. Complements the existing ]q/[q navigation.
--
-- Two DIFFERENT scopes, and the distinction matters:
--   ,qd  every LSP diagnostic Neovim currently knows — which is only the
--        buffers it has LOADED. With one file open you get that file and
--        nothing else. This is where messages like "'env' is declared but its
--        value is never read" (source: ts, from vtsls) show up.
--   ,ql  the project's own eslint over the nearest package — covers files you
--        have never opened. This is the real "all lint errors" answer.
map("n", "<leader>qd", function() require("user").diagnostics_to_qf() end,
  { desc = "Diagnostics (loaded buffers) → quickfix" })
map("n", "<leader>qe", function() require("user").diagnostics_to_qf "ERROR" end,
  { desc = "Diagnostics, errors only → quickfix" })
map("n", "<leader>ql", function() require("user").lint_project() end,
  { desc = "eslint on this package → quickfix" })
map("n", "<leader>qq", function()
  local open = false
  for _, w in ipairs(vim.fn.getwininfo()) do
    if w.quickfix == 1 then open = true end
  end
  vim.cmd(open and "cclose" or "copen")
end, { desc = "Toggle quickfix" })

-- ─── Tab / Shift-Tab step through matches while searching ───────────────────
-- Vim already has this during an incremental search: <C-g> is the next match,
-- <C-t> the previous. These just put it on Tab / Shift-Tab, which is what the
-- fingers expect when several matches are on screen.
--
-- Scoped to SEARCH cmdlines only (getcmdtype() is "/" or "?"). Tab is 'wildchar'
-- (9), so mapping it unconditionally would kill filename and command completion
-- on the `:` cmdline; search patterns have no completion, so there Tab is free.
--
-- Needs 'incsearch' (on here). Note <C-g>/<C-t> move the match without changing
-- the cmdline text, so flash's CmdlineChanged hook does not re-run — the labels
-- stay on the matches they were assigned to, which is what you want: Tab walks
-- the matches, a label jumps straight to one.
map("c", "<Tab>", function()
  return vim.fn.getcmdtype():match "[/?]" and "<C-g>" or "<Tab>"
end, { expr = true, replace_keycodes = true, desc = "Search: next match" })

map("c", "<S-Tab>", function()
  return vim.fn.getcmdtype():match "[/?]" and "<C-t>" or "<S-Tab>"
end, { expr = true, replace_keycodes = true, desc = "Search: previous match" })
