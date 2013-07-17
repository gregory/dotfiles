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
Bundle 'jamescarr/snipmate-nodejs'
Bundle 'ZenCoding.vim'
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"
Bundle "garbas/vim-snipmate"
Bundle 'majutsushi/tagbar'
Bundle 'scrooloose/syntastic'
Bundle 'ack.vim'
Bundle 'thoughtbot/vim-rspec'
Bundle "Chiel92/vim-autoformat"
Bundle "ddollar/nerdcommenter"
Bundle "slim-template/vim-slim"
Bundle "nathanaelkane/vim-indent-guides"
Bundle "ervandew/supertab"
Bundle "mattn/gist-vim"
Bundle 'mattn/webapi-vim'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'pangloss/vim-javascript'
Bundle 'digitaltoad/vim-jade'
Bundle 'wavded/vim-stylus'

" Colorschemes
Bundle 'altercation/vim-colors-solarized'
Bundle 'jpo/vim-railscasts-theme'
Bundle 'croaker/mustang-vim'
Bundle '29decibel/codeschool-vim-theme'
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
set fileencoding=utf-8
set history=1000
set mouse=a
set nobackup  " Don't make a backup before overwriting a file.
set noswapfile  " Don't create swap file
set nowritebackup " And again
set secure  " Allow to write files without permissions?
set smartindent
" Removes trailing spaces
function TrimWhiteSpace()
  %s/\s*$//
  ''
:endfunction

set guioptions-=T " Removes top toolbar
set guioptions-=r " Removes right hand scroll bar
set go-=L " Removes left hand scroll bar
" Search

set hlsearch    " highlight matches
set incsearch   " incremental searching
set ignorecase  " searches are case insensitive...
set smartcase   " ... unless they contain at least one capital letter

" List chars
set nowrap                        " Don't wrap line when too long
set listchars=""                  " Reset the listchars
set listchars=tab:\ \             " a tab should display as "  ", trailing whitespace as "."
set listchars+=trail:.            " show trailing spaces as dots
set listchars+=extends:>          " The character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=precedes:<         " The character to show in the last column when wrap is
                                  " off and the line continues beyond the left of the screen

autocmd FileWritePre * :call TrimWhiteSpace()
autocmd FileAppendPre * :call TrimWhiteSpace()
autocmd FilterWritePre * :call TrimWhiteSpace()
autocmd BufWritePre * :call TrimWhiteSpace()

"
" View
"
set cursorline
set laststatus=2    " Show the status line all the time
set nonumber      " Show line numbers
set showtabline=2    " Show tabs bar

set showcmd      " Display incomplete commands
set showmode      " Display the mode

set visualbell     " No beeping

set wildmenu     " Enhanced command line completion
set wildmode=list:longest    " Complete files like a shell
set wildignore+=*/.git/*,*/tmp/*,*/log/*,*/app/assets/images/*,*/vendor/assets/images/*,*/coverage/*,*/node_modules/*
let g:syntastic_error_symbol='✗'
let g:syntastic_style_error_symbol='>'
let g:syntastic_warning_symbol='⚠'
let g:syntastic_style_warning_symbol='>'


au BufNewFile,BufReadPost *.rb normal zi "default to unfolded
set foldmethod=syntax
set foldlevel=1


set t_Co=256
"set term=screen-256color
let g:solarized_termcolors=256
"colorscheme codeschool
set background=dark
colorscheme solarized

set ts=2 sw=2 et
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 2
let g:indent_guides_color_change_percent = 80

"autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=NONE
"autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=136
hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
"hi IndentGuidesEven ctermbg=222
hi IndentGuidesEven ctermbg=235
hi IndentGuidesOdd  ctermbg=NONE
"
"Highlights
"
function! ReverseBackground()
  let Mysyn=&syntax
  if &bg=="light"
    se bg=dark
    "highlight Normal guibg=black guifg=white
    hi NonText ctermfg=NONE ctermbg=235
    hi CursorLine cterm=bold,underline ctermbg=235 guibg=darkred guifg=white
    hi Folded ctermfg=black ctermbg=137 cterm=NONE
    hi Search cterm=underline ctermbg=59
    hi IndentGuidesEven ctermbg=235
    hi IndentGuidesOdd  ctermbg=black
  else
    se bg=light
    hi NonText ctermfg=NONE ctermbg=235
    hi CursorLine cterm=bold,underline ctermbg=235 guibg=darkred guifg=white
    hi Folded ctermfg=black ctermbg=137 cterm=NONE
    hi Search cterm=underline ctermbg=59
    hi IndentGuidesEven ctermbg=280
    hi IndentGuidesOdd  ctermbg=NONE
  endif
  syn on
  colorscheme solarized
  exe "set syntax=" . Mysyn
  echo "now syntax is "&syntax
endfunction
command! Invbg call ReverseBackground()
noremap <F11> :Invbg<CR>

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

" faster split navigation
map <Leader>w <C-w>
map <leader>j <C-w>j
map <leader>k <C-w>k
map <leader>h <C-w>h
map <leader>l <C-w>l
map <S-right> <ESC>

" Forcing myself to stop using arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

map <leader>s :split <CR>
map <leader>v :vsplit <CR>
map <leader>t :tabe <CR>
map <Leader>p :set paste!<CR>
map zo zO "open full level all the time

"always center the screen
nnoremap <space> <nop>
map <space> zz
nmap n n zz
nmap N N zz

" resize current buffer by +/- 5
nnoremap <C-left> :vertical resize -3<cr>
nnoremap <C-down> :resize +3<cr>
nnoremap <C-up> :resize -3<cr>
nnoremap <C-right> :vertical resize +3<cr>
"nnoremap <Leader>hc :set cursorline! <CR>
"nnoremap <Leader>hn :set nu! <CR>
nnoremap <Leader>d :set hlsearch! <CR>
" autocmd BufEnter * if expand("%:p:h") !~ '^/tmp' | silent! lcd %:p:h | endif " changes the cd to the directory of the current file except for /tmp/*
nnoremap ,cd :cd %:p:h<CR>:pwd<CR>

"remap the ] ctrl
noremap <C-j> <C-]> "j for jump

"
" Plugin settings
"

" Zen coding
let g:user_zen_expandabbr_key = '<c-e>'
let g:use_zen_complete_tag = 1

" NERDTree
let g:NERDTreeMinimalUI = 0
let g:NERDTreeChDirMode=1 "2 would update the cwd anytime i change the root
let g:NERDTreeWinSize = 20
let g:NERDTreeDirArrows = 0
let g:NERDTreeQuitOnOpen = 0
"let g:NERDTreeWinPos = "right"
augroup AuNERDTreeCmd
autocmd AuNERDTreeCmd VimEnter * call s:CdIfDirectory(expand("<amatch>"))
autocmd AuNERDTreeCmd FocusGained * call s:UpdateNERDTree()
augroup AuNERDTreeCmd
autocmd!
augroup end
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
map <Leader>rl :call RunLastSpec()<CR>
map <Leader>ra :call RunAllSpecs()<CR>

" rails.vim
autocmd User Rails let b:surround_{char2nr('-')} = "<% \r %>" " displays <% %> correctly
:set cpoptions+=$ " puts a $ marker for the end of words/lines in cw/c$ commands

" coffeescript.vim
au BufNewFile,BufReadPost *.coffee setl foldmethod=indent nofoldenable

" bufkill.vim
cnoreabbrev bd BD

" splitjoin
nmap sjj :SplitjoinJoin<CR>
nmap sjs :SplitjoinSplit<CR>

" vim-powerline.vim
 "let g:Powerline_symbols='skwp'

" Ack
set grepprg=ack
nnoremap <leader>fw :Ack <c-r><c-w><CR>

" Taglist

set tags=./tags,tags;$HOME
let g:tagbar_ctags_bin='/usr/local/bin/ctags' "Proper Ctags location
let g:tagbar_width=26                         "Default is 40, seems to wide
let g:tagbar_autofocus = 1
let g:tagbar_sort= 0
let g:tagbar_compact= 1
let g:tagbar_indent= 1
let g:tagbar_autoclose= 1

so ~/.vim/tagbar-coffeescript-config
so ~/.vim/tagbar-css-config
noremap <silent> <Leader>y :TagbarToggle<CR>

" Fugitive
nmap <leader>gb :Gblame<CR>
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gl :Glog<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gp :Git push<CR>

" Gist
let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1
let g:gist_post_private = 1
