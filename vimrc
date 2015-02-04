"
" Vundle setup
"
set nocompatible                  "We run vim not VI

filetype off                       " required by Vundler

set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

Plugin 'gmarik/Vundle.vim'

" Plugins
"-------------------------------------------

"Frameworks/languages
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-bundler'
Plugin 'tpope/vim-fugitive'
" follow instructions here => https://github.com/skwp/vim-rspec
Plugin 'thoughtbot/vim-rspec'
Plugin 'tpope/vim-dispatch'

"Coding
Plugin 'Lokaltog/vim-easymotion'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'kien/ctrlp.vim'
Plugin 'jc00ke/vim-tomdoc'
Plugin 'mattn/emmet-vim'
Plugin 'scrooloose/syntastic'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'
Plugin 'ervandew/supertab'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-endwise'
Plugin 'junegunn/vim-easy-align'
Plugin 'vim-scripts/EasyGrep'
Plugin 'gorkunov/smartpairs.vim'

"Doc
Plugin 'rizzatti/funcoo.vim'
Plugin 'rizzatti/dash.vim'

"Syntaxes
Plugin 'tpope/vim-haml'
Plugin 'slim-template/vim-slim'
Plugin 'vim-ruby/vim-ruby'
Plugin 'pangloss/vim-javascript'
Plugin 'tpope/vim-markdown'
Plugin 'wavded/vim-stylus'
Plugin 'digitaltoad/vim-jade'
Plugin 'kchmck/vim-coffee-script'
Plugin 'Chiel92/vim-autoformat'

"Theme
Plugin 'altercation/vim-colors-solarized'

call vundle#end()            " required
""
"" General settings
""
syntax enable                     " Turn on syntax highlighting.
filetype plugin indent on         " Turn on file type detection.
let mapleader = ","
nnoremap \ ,

" Use jk to escape
inoremap jk <ESC>

" close
nnoremap <leader>cl :close<CR>
" Buffer hotkey
nnoremap <Leader>b :buffer

"au FocusLost * :wa " Autosave everything
set autowriteall "save file when buffer switched
set ttyfast
set lazyredraw
set backspace=indent,eol,start    " Intuitive backspacing

if $TMUX == ''
  set clipboard+=unnamed
endif
set encoding=utf-8
set fileencoding=utf-8
set history=1000
set nobackup  " Don't make a backup before overwriting a file.
set noswapfile  " Don't create swap file
set nowritebackup " And again
set secure  " Allow to write files without permissions?
set smartindent

"" Search
set hlsearch    " highlight matches
set incsearch   " incremental searching
set ignorecase  " searches are case insensitive...
set smartcase   " ... unless they contain at least one capital letter
set grepprg=git\ grep\ -nHI\ --exclude-standard\ --heading\ --color\ --no-index\ -e\ $* "\ --\ --\ `git\ ls-files\ \\\|\ egrep\ -v\ -e\ 'vendor\\\|vcr_casettes'`

"" List chars
set wrap                          " wrap line when too long
set linebreak                     " tells Vim to only wrap at a character in the breakat option
set listchars=""                  " Reset the listchars
set listchars=tab:\ \             " a tab should display as "  ", trailing whitespace as "."
set listchars+=trail:.            " show trailing spaces as dots
set listchars+=extends:>          " The character to show in the last column when wrap is
                                 "" off and the line continues beyond the right of the screen
set listchars+=precedes:<         " The character to show in the last column when wrap is
                                  "" off and the line continues beyond the left of the screen

"
"Tabs Indentations
"
set ts=2 sw=2 et
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 2
let g:indent_guides_color_change_percent = 80

"
" Removes trailing spaces
"
function TrimWhiteSpace()
 %s/\s*$//
 ''
:endfunction
autocmd FileWritePre * :call TrimWhiteSpace()
autocmd FileAppendPre * :call TrimWhiteSpace()
autocmd FilterWritePre * :call TrimWhiteSpace()
autocmd BufWritePre * :call TrimWhiteSpace()

"
" View
"
set cursorline
set colorcolumn=90
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


"set nofoldenable
"set foldmethod=syntax " Pretty slow
"set foldlevel=1
"au BufRead * normal zR
"au BufNewFile,BufReadPost *.rb setl nofoldenable
"au BufNewFile,BufReadPost *.rb normal zi "default to unfolded
"autocmd InsertEnter * let w:last_fdm=&foldmethod | setlocal foldmethod=manual
"autocmd InsertLeave * let &l:foldmethod=w:last_fdm

""
"" Colors/ Highlights
""
set t_Co=256
set term=screen-256color
"let g:solarized_termcolors=256
set background=dark
colorscheme solarized

"autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=NONE
"autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=136
hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
hi IndentGuidesEven ctermbg=235
hi IndentGuidesOdd  ctermbg=NONE
"
"
"highlight Normal guibg=black guifg=white
function! ReverseBackground()
  let Mysyn=&syntax
  if &bg=="light"
    se bg=dark
    "highlight Normal guibg=black guifg=white
    "hi NonText ctermfg=NONE ctermbg=235
    hi CursorLine cterm=bold,underline ctermbg=235 guibg=darkred guifg=white
    hi Folded ctermfg=black ctermbg=137 cterm=NONE
    hi Search cterm=underline ctermbg=59
    hi IndentGuidesEven ctermbg=235
    hi IndentGuidesOdd  ctermbg=NONE
  else
    se bg=light
    "hi NonText ctermfg=NONE ctermbg=235
    hi CursorLine cterm=bold,underline ctermbg=235 guibg=white guifg=darkered
    hi Folded ctermfg=black ctermbg=137 cterm=NONE
    hi Search cterm=underline ctermbg=59
    hi IndentGuidesEven ctermbg=222
    "hi IndentGuidesEven ctermbg=280
    hi IndentGuidesOdd  ctermbg=NONE
  endif
  exe "set syntax=" . Mysyn
  echo "now syntax is "&syntax
endfunction
command! Invbg call ReverseBackground()
noremap <F11> :Invbg<CR>

function! s:RunShellCommand(cmdline)
  let isfirst = 1
  let words = []
  for word in split(a:cmdline)
    if isfirst
      let isfirst = 0  " don't change first word (shell command)
    else
      if word[0] =~ '\v[%#<]'
        let word = expand(word)
      endif
      let word = shellescape(word, 1)
    endif
    call add(words, word)
  endfor
  let expanded_cmdline = join(words)
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1, 'You entered:  ' . a:cmdline)
  call setline(2, 'Expanded to:  ' . expanded_cmdline)
  call append(line('$'), substitute(getline(2), '.', '=', 'g'))
  silent execute '$read !'. expanded_cmdline
  1
endfunction
command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)

"
"Text formatting
"

"" text wrap
"set tw=80 fo=cqt wm=0
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

" easy align
vmap <Enter> <Plug>(EasyAlign)

" faster split navigation
set splitbelow
set splitright

map <Leader>w <C-w>
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
map <S-right> <ESC>

imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

nnoremap <down> :cn<CR>
nnoremap <up> :cp<CR>
nnoremap <right> :copen<CR>
nnoremap <left> :cclose<CR>

map <leader>s :split <CR>
map <leader>v :vsplit <CR>
map <leader>t :tabe <CR>
map <Leader>p :set paste!<CR>

"remap the page up/down and disable the mouse
set mouse=a
set ttymouse=xterm2

"always center the screen
nnoremap <space> <nop>
map <space> zz
nmap n n zz
nmap N N zz
map zo zO "open full level all the time

" resize current buffer by +/- 5
nnoremap <C-left> :vertical resize +3<cr>
nnoremap <C-down> :resize +3<cr>
nnoremap <C-up> :resize -3<cr>
nnoremap <C-right> :vertical resize -3<cr>
"nnoremap <Leader>hc :set cursorline! <CR>
"nnoremap <Leader>hn :set nu! <CR>
nnoremap <Leader>d :set hlsearch! <CR>
" autocmd BufEnter * if expand("%:p:h") !~ '^/tmp' | silent! lcd %:p:h | endif " changes the cd to the directory of the current file except for /tmp/*
nnoremap ,cd :cd %:p:h<CR>:pwd<CR>
inoremap <tab> <c-r>=InsertTabWrapper()<cr>

"remap the ] ctrl
"noremap <C-j> <C-]> "j for jump

"
" Plugin settings
"

" NERDTree
let g:NERDTreeMinimalUI = 1
let g:NERDTreeChDirMode=1 "2 would update the cwd anytime i change the root
let g:NERDTreeWinSize = 20
let g:NERDTreeDirArrows = 0
let g:NERDTreeQuitOnOpen = 1
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
let g:ctrlp_map = '<C-g>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_extensions = ['tag']
let g:ctrlp_custom_ignore = '\.git$'
map <C-T> :CtrlPBuffer<CR>

" vim-rspec
"let g:rspec_command = "!zeus rspec {spec}"
"let g:rspec_command = "!zeus rescue rspec -f d -c {spec}"
let g:rspec_command = "Dispatch rspec -f -d -c {spec}"
"let g:rspec_command = "!rspec {spec}"

map <Leader>rr :Dispatch rake rubocop<CR>
map <Leader>rs :call RunCurrentSpecFile()<CR>
map <Leader>rn :call RunNearestSpec()<CR>
map <Leader>rl :call RunLastSpec()<CR>
map <Leader>ra :call RunAllSpecs()<CR>

let g:netrw_banner       = 0
let g:netrw_liststyle    = 3
let g:netrw_sort_options = 'i'

" rails.vim
autocmd User Rails let b:surround_{char2nr('-')} = "<% \r %>" " displays <% %> correctly
:set cpoptions+=$ " puts a $ marker for the end of words/lines in cw/c$ commands

" coffeescript.vim
"au BufNewFile,BufReadPost *.coffee setl foldmethod=indent nofoldenable


" vim-powerline.vim
let g:Powerline_symbols='skwp'

" Fugitive
nmap <leader>gb :Gblame<CR>
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gl :Glog<CR>
nmap <leader>gc :Gcommit<CR>
nmap <leader>gp :Git push<CR>

"vim-javascript
let javascript_enable_domhtmlcss=1

" Gist
let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1
let g:gist_post_private = 1

"Vim autoformat
noremap <F3> :Autoformat<CR><CR>

