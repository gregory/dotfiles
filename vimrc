"
" Vundle setup
"
set nocompatible                  "We run vim not VI

filetype off                       " required by Vundler

set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

"Plugin 'gmarik/Vundle.vim'

" Plugins
"-------------------------------------------

"Frameworks/languages
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-fugitive'
Plugin 'thoughtbot/vim-rspec'
Plugin 'tpope/vim-dispatch'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'

Plugin 'junegunn/vim-easy-align'
Plugin 'szw/vim-ctrlspace'

Plugin 'ervandew/snipmate.vim'
Plugin 'ervandew/supertab'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'

Plugin 'mattn/emmet-vim'
Plugin 'scrooloose/syntastic'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-endwise'
Plugin 'vim-scripts/EasyGrep'
Plugin 'gorkunov/smartpairs.vim'

"Doc
Plugin 'rizzatti/funcoo.vim'
Plugin 'rizzatti/dash.vim'

"Syntaxes
Plugin 'nathanaelkane/vim-indent-guides'
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
" Don't make backups at all
set nobackup
set noswapfile  " Don't create swap file
set nowritebackup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set secure  " Allow to write files without permissions?
set smartindent
set scrolloff=3
set shell=bash

"" Search
set hlsearch    " highlight matches
set incsearch   " incremental searching
set ignorecase  " searches are case insensitive...
set smartcase   " ... unless they contain at least one capital letter

" Run a given vim command on the results of fuzzy selecting from a given shell
" command. See usage below.
" Note: I'm using Iterm2 and remapped ^[ to "Send Hex Codes: 0x03" which is == ^C
function! SelectaCommand(choice_command, selecta_args, vim_command)
  try
    let selection = system(a:choice_command . " | selecta " . a:selecta_args)
  catch /Vim:Interrupt/
    " Swallow the ^C so that the redraw below happens; otherwise there will be
    " leftovers from selecta on the screen
    redraw!
    return ''
  endtry
  redraw!
  exec a:vim_command . " " . selection
endfunction

let ignore = [".git", "vendor", ".svg", ".eot", "log/", ".jpg", '\/\.', '^\..*'] " ignore hidden files
let excludes= " \| GREP_OPTIONS=\'\' egrep -v -e \'" . join(map(ignore, 'v:val'), "\|") . "\'"

" Find all files in all non-dot directories starting in the working directory.
" Fuzzy select one of those. Open the selected file with :e.
nnoremap <space> :call SelectaCommand("find * -type f" .g:excludes, "", ":e")<cr>
"nnoremap <space> :call SelectaCommand("git ls-files -cmo --exclude-standard" .g:excludes, "", ":e")<cr>

function! SelectaFile(path)
  call SelectaCommand("find " . a:path . "/* -type f", "", ":e")
endfunction

nnoremap fiv :call SelectaFile("app/views")<cr>
nnoremap fic :call SelectaFile("app/controllers")<cr>
nnoremap fim :call SelectaFile("app/models")<cr>
nnoremap fih :call SelectaFile("app/helpers")<cr>
nnoremap fil :call SelectaFile("lib")<cr>
nnoremap fip :call SelectaFile("public")<cr>
nnoremap fis :call SelectaFile("public/stylesheets")<cr>
nnoremap fif :call SelectaFile("features")<cr>

"Fuzzy select
function! SelectaIdentifier()
  " Yank the word under the cursor into the z register
  normal "zyiw
  " Fuzzy match files in the current directory, starting with the word under
  " the cursor
  call SelectaCommand("find * -type f", "-s " . @z, ":e")
endfunction
nnoremap <c-g> :call SelectaIdentifier()<cr>

"set grepprg=git\ grep\ --exclude-standard\ -n\ $*

function! Grep()
  let params = input('search for: ', expand('<cword>'))
  exec ':silent Ggrep! -I' . params
  cw
  redraw!
endfunction
nmap <Leader>g :call Grep()<cr>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Diff tab management: open the current git diff in a tab
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! GdiffInTab tabedit %|vsplit|Gdiff
nnoremap diff :GdiffInTab<cr>
nnoremap <leader>D :tabclose<cr>

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
function! TrimWhiteSpace()
 let _s=@/
 let l = line(".")
 let c = col(".")
 :%s/\s\+$//e
 :silent! g/^\n\{2,}/d
 let @/=_s
 call cursor(l, c)
endfunction

nmap mm `

" Use ii to escape
noremap jk <ESC>:w<CR>

autocmd FileWritePre * :silent! keepjumps call TrimWhiteSpace()
autocmd FileAppendPre * :silent! keepjump scall TrimWhiteSpace()
autocmd FilterWritePre * :silent! keepjump call TrimWhiteSpace()
autocmd BufWritePre * :silent! keepjump call TrimWhiteSpace()

" rename current file and new file path
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'))
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction

nmap mv :call RenameFile()<cr>

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

""
"" Colors/ Highlights
""
set t_Co=256
"set term=screen-256color
"let g:solarized_termcolors=256
set background=dark
silent! colorscheme solarized

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
    "hi CursorLine cterm=bold,underline ctermbg=235 guibg=darkred guifg=white
    "hi Folded ctermfg=black ctermbg=137 cterm=NONE
    "hi Search cterm=underline ctermbg=59
    hi IndentGuidesEven ctermbg=235
    hi IndentGuidesOdd  ctermbg=NONE
  else
    se bg=light
    "hi NonText ctermfg=NONE ctermbg=235
    "hi CursorLine cterm=bold,underline ctermbg=235 guibg=white guifg=darkered
    "hi Folded ctermfg=black ctermbg=137 cterm=NONE
    "hi Search cterm=underline ctermbg=59
    "hi IndentGuidesEven ctermbg=222
    hi IndentGuidesEven ctermbg=280
    hi IndentGuidesOdd  ctermbg=NONE
  endif
  exe "set syntax=" . Mysyn
  echo "now syntax is "&syntax
endfunction
command! Invbg call ReverseBackground()
noremap <F11> :Invbg<CR>

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

" easy align
vmap <Enter> <Plug>(EasyAlign)

" easy motion
map // <Plug>(easymotion-sn)
omap // <Plug>(easymotion-tn)
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)
let g:EasyMotion_startofline = 0

" faster split navigation
set splitbelow
set splitright

map <Leader>w <C-w>
" save the buffer before switching from insert mode
imap <C-j> <ESC>:w<CR><C-j>
imap <C-k> <ESC>:w<CR><C-k>
imap <C-h> <ESC>:w<CR><C-h>
imap <C-l> <ESC>:w<CR><C-l>

nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

"map <S-right> <ESC>

imap <down> <nop>
imap <up>   <nop>
imap <right> <nop>
imap <left> <nop>

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

nnoremap d :set hlsearch! <CR>
nnoremap ,cd :cd %:p:h<CR>:pwd<CR>

function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <expr> <tab> InsertTabWrapper()
inoremap <s-tab> <c-n>

"remap the ] ctrl
"noremap <C-j> <C-]> "j for jump

"
" Plugin settings
"

"
" vim -ruby
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1

" ctrl-space
"
let g:ctrlspace_default_mapping_key ='<tab>'

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
