require "nvchad.mappings"

local map = vim.keymap.set
local user = require "user"
local fn = vim.fn
local api = vim.api
local echo = api.nvim_echo
local deepcopy = vim.deepcopy

local function feedkeys(keys)
  api.nvim_feedkeys(api.nvim_replace_termcodes(keys, true, false, true), "n", true)
end

local function terminal_opener(opts)
  return function()
    feedkeys "<C-\\><C-n>"
    local args = deepcopy(opts or {})
    vim.schedule(function()
      user.open_terminal(args)
    end)
  end
end

map("n", "zo", "zO", { remap = true })
map("n", "bm", "<Plug>BookmarkToggle")
map("n", "bi", "<Plug>BookmarkAnnotate")
map("n", "bn", "<Plug>BookmarkNext")
map("n", "bp", "<Plug>BookmarkPrev")
map("n", "ba", "<Plug>BookmarkShowAll")
map("n", "bC", "<Plug>BookmarkClearAll")
map("n", "bx", "<Plug>BookmarkClear")
map("n", "<C-z>", "<nop>")
map("n", "zz", "zi", { noremap = true })
map("n", "z+", "zr", { noremap = true })
map("n", "z-", "zm", { noremap = true })
map("n", "z1", "zR", { noremap = true })
map("n", "z0", "zM", { noremap = true })
map("c", "$t", "<CR>:t''<CR>", { noremap = true })
map("c", "$T", "<CR>:T''<CR>", { noremap = true })
map("c", "$m", "<CR>:m''<CR>", { noremap = true })
map("c", "$M", "<CR>:M''<CR>", { noremap = true })
map("c", "$d", "<CR>:d<CR>``", { noremap = true })
map("n", "%", "v%", { noremap = true })
map("n", "vib", "viB")
map("n", "cib", "ciB")
map("n", "yib", "yiB")
map("t", "<F9>", [[<C-\><C-n><cmd>tabnext<CR>]], { silent = true })
map("t", "<F7>", [[<C-\><C-n><cmd>tabprevious<CR>]], { silent = true })
map("t", "<F8>", [[<C-\><C-n><cmd>tabnew<CR>]], { silent = true })
map("n", "<F9>", "<cmd>tabnext<CR>", { silent = true })
map("n", "<F7>", "<cmd>tabprevious<CR>", { silent = true })
map("n", "<F8>", "<cmd>tabnew<CR>", { silent = true })
map("n", "<S-Tab>", "<C-w>: CtrlSpace List", { silent = true })
map("n", "dir", ":CtrlSpace E<CR>", { noremap = true, nowait = true })
map("n", "Q", ":CtrlSpace Q<CR>", { silent = true, nowait = true })
map("n", "<Tab>", ":CtrlSpace a<CR>", { silent = true, nowait = true })
map("n", "<leader>f", function()
  local buffers = {}
  for buf = 0, fn.bufnr "$" do
    if fn.bufwinnr(buf) >= 0 then
      table.insert(buffers, fn.fnamemodify(fn.bufname(buf), ":t"))
    end
  end
  table.sort(buffers)
  echo({ { table.concat(buffers, "\n"), "Normal" } }, true, {})
end, { noremap = true, nowait = true })
map("n", "<Space>", function()
  if vim.v.count > 0 then
    return string.format(":<C-u>%d wincmd w<CR>", vim.v.count)
  end
  return "<C-w>"
end, { expr = true, silent = true, noremap = true })
map("n", "T", ":CtrlSpace l<CR>", { silent = true, nowait = true })
map("n", "W", ":CtrlSpace w<CR>", { silent = true, nowait = true })
map("n", "<CR>", ":GFiles -cmo --exclude-standard<CR>", { nowait = true })
map("n", "ge", ":Ggrep<CR>", { nowait = true })
map("n", "cl", function()
  user.toggle_curline()
end, { silent = true, nowait = true })
map({ "n", "v", "o" }, "<F6>", "<cmd>Prettier<CR>", { silent = true, noremap = true })
map("n", "<C-o>", function()
  user.zoom_toggle()
end, { silent = true, noremap = true })
map("t", "<C-o>", [[<C-\><C-n><cmd>lua require('user').zoom_toggle()<CR>]], { silent = true })
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
map("n", "a", "hea", { noremap = true })
map("n", "<leader>m", ":NERDTreeToggle<CR>", { nowait = true })
map("n", "<leader>n", ":NERDTreeFind<CR>", { nowait = true })
map("v", "<CR>", "<Plug>(EasyAlign)")
map("n", "s", ":<C-u>call EasyMotion#OverwinF(2)<CR>", { noremap = true, silent = true })
map("n", "<leader>p", function()
  vim.cmd "silent! r! pbpaste"
end, { silent = true })
map("t", "<leader>p", [[<C-\><C-n><cmd>set paste<CR>"*p<cmd>set nopaste<CR>a]], { silent = true })
map("n", "S", ":set hlsearch!<CR>", { noremap = true })
map("n", "-", ":e#<CR>")
map({ "n", "v", "o" }, "<leader>l", "<Plug>(easymotion-lineforward)")
map({ "n", "v", "o" }, "<leader>j", "<Plug>(easymotion-j)")
map({ "n", "v", "o" }, "<leader>k", "<Plug>(easymotion-k)")
map({ "n", "v", "o" }, "<leader>h", "<Plug>(easymotion-linebackward)")
map("n", "<F10>", function()
  vim.cmd([[echo "hi<" . synIDattr(synID(line('.'),col('.'),1),'name') . "> trans<" . synIDattr(synID(line('.'),col('.'),0),'name') . "> lo<" . synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name') . ">"]])
end, { silent = true })
map("n", "g/", function()
  if not user.hop_patterns { current_line_only = true } then
    feedkeys "g/"
  end
end, { silent = true, noremap = true })
map("n", "/", function()
  if not user.hop_patterns() then
    feedkeys "/"
  end
end, { silent = true, noremap = true })
map("n", "f", function()
  if not user.hop_char1 { current_line_only = true } then
    feedkeys "f"
  end
end, { silent = true, noremap = true })
map("n", "i", ":noh<CR>i", { noremap = true, silent = true })
map("n", "<BS>", "mzJ`z", { noremap = true })
map("n", "gj", "<Plug>(signify-next-hunk)")
map("n", "gk", "<Plug>(signify-prev-hunk)")
map({ "n", "v", "o" }, "<F1>", function()
  user.dark_background()
end, { silent = true })
map({ "n", "v", "o" }, "<F2>", function()
  user.light_background()
end, { silent = true })
map({ "n", "v", "o" }, "<F3>", function()
  user.transparent_background()
end, { silent = true })
map("n", "<C-u>", function()
  if user.ensure_plugin "undotree" then
    vim.cmd.UndotreeToggle()
  end
end, { silent = true, noremap = true })
map("n", "U", "<C-r>", { noremap = true })
map("n", "cd", function()
  user.selecta_command("find * -type d" .. (vim.g.excludes or ""), "", "lcd")
end, { noremap = true })
map("n", "gs", "<cmd>GFiles?<CR>", { noremap = true })
map("n", "?", "<cmd>BLines<CR>", { noremap = true })
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
map("n", "mru", function()
  fn["fzf#run"] {
    source = vim.v.oldfiles,
    sink = "e",
    options = "-m -x +s --exact",
    down = "20%",
  }
end, { noremap = true })
map("n", "<C-g>", "<cmd>Rg<CR>", { noremap = true })
map("n", "mv", function()
  user.rename_file()
end, { noremap = true })
map("i", "<C-x><C-j>", "<Plug>(fzf-complete-file-ag)")
map("i", "<C-x><C-l>", "<Plug>(fzf-complete-line)")
map("i", "<C-x><C-k>", "<Plug>(fzf-complete-word)")
map("i", "<C-x><C-f>", "<Plug>(fzf-complete-path)")
map("n", "<leader><Tab>", "<Plug>(fzf-maps-n)")
map("x", "<leader><Tab>", "<Plug>(fzf-maps-x)")
map("o", "<leader><Tab>", "<Plug>(fzf-maps-o)")
map("n", "<leader>ev", "<cmd>edit $MYVIMRC<CR>", { silent = true })
map("i", "fd", "<ESC>:update<CR>", { silent = true, noremap = true })
map("n", "fd", "<cmd>w<CR>", { silent = true, noremap = true })
map("v", "fd", "<cmd>w<CR>gv", { silent = true, noremap = true })
map("n", "<C-f>v", function()
  user.open_terminal { orientation = "vertical", kill = "kill" }
end, { silent = true })
map("n", "<C-g>v", function()
  user.open_terminal { orientation = "vertical", kill = "kill" }
end, { silent = true })
map("n", "<C-f>s", function()
  user.open_terminal { kill = "kill" }
end, { silent = true })
map("n", "<C-f>t", function()
  user.open_terminal { kill = "kill", rows = 25 }
end, { silent = true })
map("n", "<C-f>=", function()
  user.open_terminal { kill = "kill", rows = 25 }
end, { silent = true })
map("n", "<C-k>", "<cmd>wincmd k<CR>", { silent = true })
map("n", "<C-h>", "<cmd>wincmd h<CR>", { silent = true })
map("n", "<C-l>", "<cmd>wincmd l<CR>", { silent = true })
map("n", "<C-j>", "<cmd>wincmd j<CR>", { silent = true })
map("n", "<S-Up>", "<cmd>resize +5<CR>", { silent = true })
map("n", "<S-Down>", "<cmd>resize -5<CR>", { silent = true })
map("n", "<S-Left>", "<cmd>vertical resize -5<CR>", { silent = true })
map("n", "<S-Right>", "<cmd>vertical resize +5<CR>", { silent = true })
map("t", "<leader>f", [[<C-\><C-n>:set nomore<CR>:ls<CR>:set more<CR>:b ]], { silent = true })
map("t", "<C-f>:", [[<C-\><C-n>:]], { nowait = true })
map("t", "<C-g>v", terminal_opener { orientation = "vertical", kill = "int" }, { silent = true })
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
map("n", "M", "<cmd>MarksWithPreview<CR>", { silent = true, noremap = true })
map("n", "j", "jzz", { noremap = true })
map("n", "k", "kzz", { noremap = true })
map("n", "l", "e", { noremap = true })
map("n", "h", "b", { noremap = true })
map("n", "J", "10jzz", { noremap = true })
map("n", "K", "10kzz", { noremap = true })
map("n", "H", "5b", { noremap = true })
map("n", "L", "5e", { noremap = true })
map("n", "<Down>", "<cmd>cn<CR>", { silent = true })
map("n", "<Up>", "<cmd>cp<CR>", { silent = true })
map("n", "<Right>", "<cmd>copen<CR>", { silent = true })
map("n", "<Left>", "<cmd>cclose<CR>", { silent = true })
map("n", "<C-Down>", "<cmd>lne<CR>", { silent = true })
map("n", "<C-Up>", "<cmd>lpr<CR>", { silent = true })
map("n", "<C-Right>", "<cmd>lop<CR>", { silent = true })
map("n", "<C-Left>", "<cmd>lcl<CR>", { silent = true })
map("n", "<leader>S", "<cmd>aboveleft split<CR>")
map("n", "<leader>V", "<cmd>aboveleft vsplit<CR>")
map("n", "<leader>s", "<cmd>split<CR>")
map("n", "<leader>v", "<cmd>vsplit<CR>")
