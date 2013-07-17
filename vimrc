"
" Vundle setup
"
set nocompatible                  " Must come first because it changes other options.

filetype off                       " required by Vundler

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

" Plugins
Bundle 'rails.vim'
Bundle 'scrooloose/nerdtree'
Bundle 'kchmck/vim-coffee-script'
Bundle 'tpope/vim-rails'
Bundle 'vim-ruby/vim-ruby'
Bundle 'tpope/vim-rbenv'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-git'
Bundle 'tpope/vim-bundler'
Bundle 'altercation/vim-colors-solarized'
Bundle 'kien/ctrlp.vim'
Bundle 'vim-scripts/number-marks'
Bundle 'matchit.zip'
Bundle 'ruby-matchit'
Bundle 'AndrewRadev/splitjoin.vim'
Bundle 'tpope/vim-fugitive'
Bundle 'Lokaltog/vim-powerline'
Bundle 'vim-scripts/bufkill.vim'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-unimpaired'
Bundle 'tpope/vim-surround'
Bundle 'ZenCoding.vim'
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"
Bundle "garbas/vim-snipmate"
Bundle 'majutsushi/tagbar'
Bundle 'Syntastic'
Bundle 'ack.vim'
Bundle 'thoughtbot/vim-rspec'
Bundle "Chiel92/vim-autoformat"
Bundle "ddollar/nerdcommenter"
Bundle "slim-template/vim-slim"
Bundle "Yggdroot/indentLine"
Bundle "ervandew/supertab"

" Colorschemes
Bundle 'flazz/vim-colorschemes'
Bundle 'altercation/vim-colors-solarized'
Bundle 'ColorSchemeMenuMaker'
Bundle 'desert-warm-256'
Bundle 'darkspectrum'
Bundle 'tomasr/molokai'
Bundle 'jpo/vim-railscasts-theme'
Bundle 'croaker/mustang-vim'
"
" General settings
"
let mapleader = ","
syntax enable                     " Turn on syntax highlighting.
filetype plugin indent on         " Turn on file type detection.
au FocusLost * :wa " Autosave everything
set autowriteall
set backspace=indent,eol,start    " Intuitive backspacing
set clipboard=unnamed
set colorcolumn=120
set directory=$HOME/.vim/tmp " Keep swap files there
set encoding=utf-8
set expandtab
set fileencoding=utf-8
set history=1000
set ignorecase  " Case-insensitive search
set mouse=a
set nobackup  " Don't make a backup before overwriting a file.
set noswapfile  " Don't create swap file
set nowritebackup " And again
set secure  " Allow to write files without permissions?
set shiftwidth=2
set smartcase  " Case-sensetive search if expression contains a capital letter
set smartindent
set tabstop=2
" Removes trailing spaces
function TrimWhiteSpace()
  %s/\s*$//
  ''
:endfunction

set list listchars=trail:.,extends:>
autocmd FileWritePre * :call TrimWhiteSpace()
autocmd FileAppendPre * :call TrimWhiteSpace()
autocmd FilterWritePre * :call TrimWhiteSpace()
autocmd BufWritePre * :call TrimWhiteSpace()

"
" View
"
set cursorline
set incsearch			  " Highlight matches as you type
set laststatus=2		  " Show the status line all the time
set nohlsearch			  " Highlight matches
set nonumber 			  " Show line numbers
set showtabline=2		  " Show tabs bar

set showcmd 			  " Display incomplete commands
set showmode 			  " Display the mode

set visualbell			  " No beeping

set wildmenu			  " Enhanced command line completion
set wildmode=list:longest 	  " Complete files like a shell
set wildignore+=*/.git/*,*/tmp/*,*/log/*,*/app/assets/images/*,*/vendor/assets/images/*,*/coverage/*


set foldmethod=syntax
set foldlevel=1


set t_Co=256
let g:indentLine_loaded= 1
let g:indentLine_color_term = 239
let g:indentLine_char = '|'
colorscheme mustang

"
"Highlights
"
:hi CursorLine cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
:hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
:hi Folded ctermfg=black ctermbg=137 cterm=NONE
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

"
"Text formatting
"
"" LeanData style
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
"
" Maps
"
inoremap <S-CR> <Esc>
" Map ✠ (U+2720) to <S-CR>, so we have <S-CR> mapped to ✠ in iTerm2 and
" ✠ mapped back to <S-CR> in Vim.
imap ✠ <S-CR>
map <Leader>w <C-w>
map <S-right> <ESC>

" Forcing myself to stop using arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
map <Leader>sp :set paste<CR>
map <Leader>snp :set nopaste<CR>
map zo zO "open full level all the time

"always center the screen
nnoremap <space> <nop>
map <space> zz
nmap n nzz
nmap N Nzz

" resize current buffer by +/- 5
nnoremap <C-left> :vertical resize +3<cr>
nnoremap <C-down> :resize +3<cr>
nnoremap <C-up> :resize -3<cr>
nnoremap <C-right> :vertical resize -3<cr>
nnoremap <Leader>hc :set cursorline! <CR>
nnoremap <Leader>hn :set nu! <CR>
" autocmd BufEnter * if expand("%:p:h") !~ '^/tmp' | silent! lcd %:p:h | endif " changes the cd to the directory of the current file except for /tmp/*
nnoremap ,cd :cd %:p:h<CR>:pwd<CR>

"remap the ] ctrl
noremap <C-j> <C-]> "j for jump
" Plugin settngs
"

" Zen coding
let g:user_zen_expandabbr_key = '<c-e>'
let g:use_zen_complete_tag = 1

" SplitJoin
"nmap sj :SplitjoinSplit<cr>
"nmap sk :SplitjoinJoin<cr>

" NERDTree
let g:NERDTreeMinimalUI = 0
let g:NERDTreeWinSize = 20
let g:NERDTreeDirArrows = 0
augroup AuNERDTreeCmd
autocmd AuNERDTreeCmd VimEnter * call s:CdIfDirectory(expand("<amatch>"))
autocmd AuNERDTreeCmd FocusGained * call s:UpdateNERDTree()
augroup AuNERDTreeCmd
autocmd!
augroup end
let NERDTreeQuitOnOpen = 0
map <Leader>m :NERDTreeToggle<CR>
map <Leader>n :NERDTreeFind<CR>

" CtrlP
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 0
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_extensions = ['tag']
let g:ctrlp_custom_ignore = '\.git$'
map <C-T> :CtrlPBuffer<CR>

" vim-rspec
let g:rspec_command = "!zeus rspec {spec}"
map <Leader>rf :call RunCurrentSpecFile()<CR>
map <Leader>rs :call RunNearestSpec()<CR>
"map <Leader>l :call RunLastSpec()<CR>
"map <Leader>a :call RunAllSpecs()<CR>


" coffeescript.vim
au BufNewFile,BufReadPost *.coffee setl foldmethod=indent nofoldenable

" bufkill.vim
cnoreabbrev bd BD

" splitjoin
nmap sjj :SplitjoinJoin<CR>
nmap sjs :SplitjoinSplit<CR>

" vim-powerline.vim
" let g:Powerline_symbols='skwp'

" Ack
set grepprg=ack
nnoremap <leader>fw :Ack <c-r><c-w><CR>

" Taglist

let g:tagbar_ctags_bin='/usr/local/bin/ctags' "Proper Ctags location
let g:tagbar_width=26                         "Default is 40, seems to wide
noremap <silent> <Leader>y :TagbarToggle<CR>

" Fugitive
nmap <leader>gb :Gblame<CR>
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gl :Glog<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gp :Git push<CR>
