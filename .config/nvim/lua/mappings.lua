local map = vim.keymap.set

-- Ported keybindings from vimrc for navigation

-- folding
map('n', 'zo', 'zO')
map('n', 'zz', 'zi')
map('n', 'z+', 'zr')
map('n', 'z-', 'zm')
map('n', 'z1', 'zR')
map('n', 'z0', 'zM')

-- bookmarks
map('n', 'bm', '<Plug>BookmarkToggle', { remap = true })
map('n', 'bi', '<Plug>BookmarkAnnotate', { remap = true })
map('n', 'bn', '<Plug>BookmarkNext', { remap = true })
map('n', 'bp', '<Plug>BookmarkPrev', { remap = true })
map('n', 'ba', '<Plug>BookmarkShowAll', { remap = true })
map('n', 'bC', '<Plug>BookmarkClearAll', { remap = true })
map('n', 'bx', '<Plug>BookmarkClear', { remap = true })

map('n', '<C-z>', '<nop>')

-- window and tab navigation
map('n', '<F9>', '<C-w>: tabnext<CR>', { silent = true, remap = true })
map('n', '<F7>', '<C-w>: tabprevious<CR>', { silent = true, remap = true })
map('n', '<F8>', '<C-w>: tabnew<CR>', { silent = true, remap = true })

-- CtrlSpace and FZF helpers
map('n', 'dir', ':CtrlSpace E<CR>', { nowait = true })
map('n', 'Q', ':CtrlSpace Q<CR>', { nowait = true, silent = true })
map('n', '<tab>', ':CtrlSpace a<CR>', { nowait = true, silent = true })
map('n', '<leader>f', ":echo join(sort(map(filter(range(0, bufnr('$')), 'bufwinnr(v:val)>=0'), 'fnamemodify(bufname(v:val), \" :t\")'), 'n'), '\n')<CR>", { nowait = true })
map('n', ' ', 'v:count ? ":\<c-u> " . v:count . " wincmd w\<cr>" : "\<c-w>"', { expr = true, silent = true })
map('n', 'T', ':CtrlSpace l<CR>', { nowait = true, silent = true })
map('n', 'W', ':CtrlSpace w<CR>', { nowait = true, silent = true })
map('n', '<CR>', ':GFiles -cmo --exclude-standard<CR>', { nowait = true })
map('n', 'ge', ':Ggrep<CR>', { nowait = true })

map('n', '<C-g>', ':Rg<CR>')
map('n', 'mv', ':call RenameFile()<CR>')
map('i', '<C-x><C-j>', '<plug>(fzf-complete-file-ag)', { remap = true })
map('i', '<C-x><C-l>', '<plug>(fzf-complete-line)', { remap = true })
map('i', '<C-x><C-k>', '<plug>(fzf-complete-word)', { remap = true })
map('i', '<C-x><C-f>', '<plug>(fzf-complete-path)', { remap = true })
map('n', '<leader><tab>', '<plug>(fzf-maps-n)', { remap = true })
map('x', '<leader><tab>', '<plug>(fzf-maps-x)', { remap = true })
map('o', '<leader><tab>', '<plug>(fzf-maps-o)', { remap = true })

-- quickfix navigation
map('n', '<down>', ':cn<CR>')
map('n', '<up>', ':cp<CR>')
map('n', '<right>', ':copen<CR>')
map('n', '<left>', ':cclose<CR>')
map('n', '<C-down>', ':lne<CR>')
map('n', '<C-up>', ':lpr<CR>')
map('n', '<C-right>', ':lop<CR>')
map('n', '<C-left>', ':lcl<CR>')

-- split helpers
map('n', '<leader>S', ':aboveleft split <CR>')
map('n', '<leader>V', ':aboveleft vsplit <CR>')
map('n', '<leader>s', ':split <CR>')
map('n', '<leader>v', ':vsplit <CR>')

-- window movement and resizing
map('n', '<C-k>', '<C-w>k', { silent = true })
map('n', '<C-h>', '<C-w>h', { silent = true })
map('n', '<C-l>', '<C-w>l', { silent = true })
map('n', '<C-j>', '<C-w>j', { silent = true })
map('n', '<S-Up>', ':resize +5<CR>', { silent = true })
map('n', '<S-Down>', ':resize -5<CR>', { silent = true })
map('n', '<S-Left>', ':vertical resize -5<CR>', { silent = true })
map('n', '<S-Right>', ':vertical resize +5<CR>', { silent = true })

-- terminal mode adjustments
map('t', '<Leader>f', '<C-w>: set nomore<Bar>:ls<Bar>:set more<CR>:b<Space>')
map('t', '<C-f>', ':', { nowait = true })
map('t', 'fd', '<C-w>N', { nowait = true })
map('t', 'gt', '<C-w>: tabnext<CR>', { nowait = true })
map('t', ':q', '<C-w>: q!', { nowait = true })
map('t', '<C-k>', '<C-w>: wincmd k<CR>', { silent = true })
map('t', '<C-h>', '<C-w>: wincmd h<CR>', { silent = true })
map('t', '<C-l>', '<C-w>: wincmd l<CR>', { silent = true })
map('t', '<C-j>', '<C-w>: wincmd j<CR>', { silent = true })
map('t', '<S-Up>', '<C-w>: resize +5<CR>', { silent = true })
map('t', '<S-Down>', '<C-w>: resize -5<CR>', { silent = true })
map('t', '<S-Left>', '<C-w>: vertical resize +5<CR>', { silent = true })
map('t', '<S-Right>', '<C-w>: vertical resize -5<CR>', { silent = true })
map('t', '<leader>S', '<C-w>: aboveleft new<CR>')
map('t', '<leader>V', '<C-w>: aboveleft vert new<CR>')
map('t', '<leader>s', '<C-w>: new<CR>')
map('t', '<leader>v', '<C-w>: vert new<CR>')
map('t', '<C-f>v', '<C-w>: vert term ++close ++kill="int"<CR>', { silent = true })
map('t', '<C-f>s', '<C-w>: term ++close ++kill="int"<CR>', { silent = true })
map('t', '<C-f>t', '<C-w>: term ++close ++kill="int" ++rows=25<CR>', { silent = true })
map('t', '<C-f>=', '<C-w>=', { silent = true })

-- normal mode terminal mappings
map('n', '<C-f>v', ':vert term ++close ++kill="kill"<CR>', { silent = true })
map('n', '<C-f>s', ':term ++close ++kill="kill"<CR>', { silent = true })
map('n', '<C-f>t', ':term ++close ++kill="kill" ++rows=25<CR>', { silent = true })
map('n', '<C-f>=', ':term ++close ++kill="kill" ++rows=25<CR>', { silent = true })
