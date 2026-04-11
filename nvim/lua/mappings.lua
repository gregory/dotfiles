require "nvchad.mappings"

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
--   harpoon2       :  <Tab>, <S-Tab>, <leader>1..4
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

-- fugitive
map("n", "<leader>d", "<cmd>GdiffInTab<CR>", { silent = true, noremap = true })
map("n", "<leader>D", "<cmd>tabclose<CR>", { silent = true, noremap = true })
map("n", "gb", ":Git blame<CR>", { nowait = true })
map("n", "gd", ":Git diff<CR>", { nowait = true })
map("n", "gl", ":Git log -15 --<CR>", { nowait = true })
map("n", "gr", ":Git reset HEAD %<CR>", { nowait = true })
map("n", "gck", ":Git checkout --  %<CR>", { nowait = true })
map("n", "gc", ":Git commit<CR>", { nowait = true })
map("n", "gp", ":Git push -f<CR>", { nowait = true })
map("n", "rm", ":Git rm %<CR>", { nowait = true })

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
end, { expr = true, silent = true })
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
-- `fd` in insert mode = Escape (no save). Quicker than reaching for ESC.
-- Not mapped in normal/visual mode because it collides with the `f` motion.
map("i", "fd", "<Esc>", { silent = true, noremap = true })

-- terminal splits (opened via user helper)
map("n", "<C-f>v", function() user.open_terminal { orientation = "vertical", kill = "kill" } end, { silent = true })
map("n", "<C-g>v", function() user.open_terminal { orientation = "vertical", kill = "kill" } end, { silent = true })
map("n", "<C-g>s", function() user.open_terminal { orientation = "horizontal", kill = "kill" } end, { silent = true })
map("n", "<C-f>s", function() user.open_terminal { orientation = "horizontal", kill = "kill" } end, { silent = true })
map("n", "<C-f>t", function() user.open_terminal { orientation = "horizontal", kill = "kill", rows = 25 } end, { silent = true })
map("n", "<C-f>=", function() user.open_terminal { orientation = "horizontal", kill = "kill", rows = 25 } end, { silent = true })

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
map("t", "<C-f>v", terminal_opener { orientation = "vertical", kill = "int" }, { silent = true })
map("t", "<C-f>s", terminal_opener { kill = "int" }, { silent = true })
map("t", "<C-f>t", terminal_opener { kill = "int", rows = 25 }, { silent = true })
map("t", "<C-f>=", [[<C-\><C-n><C-w>=]])

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
