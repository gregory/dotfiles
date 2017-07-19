
set nocompatible                  "We run vim not VI
call plug#begin('~/.vim/plugged')

" Plugins
"-------------------------------------------

" Languages
Plug 'tpope/vim-rails', { 'for': 'ruby' } "Rails tools
Plug 'thoughtbot/vim-rspec', { 'for': 'ruby' } "Rspec tools
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'jbgutierrez/vim-partial', {'for': 'ruby' } " extract file to partial

" Coding Tools
Plug 'ervandew/supertab'
Plug 'mbbill/undotree' " Display your undo history in a graph
Plug 'junegunn/vim-easy-align' " easy align things
Plug 'Chiel92/vim-autoformat' "  code formatting
Plug 'tpope/vim-fugitive' " Git tools
"Plug 'jgdavey/tslime.vim'
Plug 'epeli/slimux'
Plug 'mhinz/vim-signify' " show modified lines in gutter
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-dispatch' " asynchronous build and test dispatche
Plug 'bling/vim-airline' "Bottom bar info
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-endwise' "Add closing arg (end etc)

" Navigation
Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle', 'NERDTreeFind']}
Plug 'Lokaltog/vim-easymotion'
Plug 'gorkunov/smartpairs.vim'
Plug 'szw/vim-ctrlspace'

" Syntax
Plug 'scrooloose/syntastic' " Syntax check for languages
Plug 'nathanaelkane/vim-indent-guides' "display indent guide
Plug 'tpope/vim-haml',          { 'for': 'haml' }
Plug 'slim-template/vim-slim',  { 'for': 'slim' }
Plug 'vim-ruby/vim-ruby',       { 'for': 'ruby' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'tpope/vim-markdown'
Plug 'wavded/vim-stylus',       { 'for': 'stylus'}
Plug 'digitaltoad/vim-jade'
Plug 'kchmck/vim-coffee-script'
Plug 'cmather/vim-meteor-snippets'
Plug 'garbas/vim-snipmate'
Plug 'honza/vim-snippets'
Plug 'vim-addon-mw-utils'
Plug 'marcweber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'Slava/vim-spacebars'

"The Theme
Plug 'altercation/vim-colors-solarized'
Plug 'zeis/vim-kolor'
Plug 't9md/vim-choosewin'
call plug#end()

let mapleader="," " change the mapleader from \ to ,

"
" Pimping vim
"
set autoindent                 " always set autoindenting on
set autowrite
set autoread                   " refresh unchanged file
set backspace=indent,eol,start " allow backspacing over everything in insert mode
set colorcolumn=90
set copyindent                 " copy the previous indentation on autoindenting
set cursorline
set encoding=utf-8
set expandtab
set fileencoding=utf-8
set hidden
set hlsearch                   " highlight matches
set ignorecase                 " ignore case when searching
set incsearch                  " show search matches as you type
set laststatus=2               " Show the status line all the time
set lazyredraw                 " tells Vim not to bother redrawing during these scenarios, leading to faster macros
set linebreak                  " tells Vim to only wrap at a character in the breakat option
set listchars=tab:>.,trail:.,extends:#,nbsp:.
set mouse=a
set nobackup
set noerrorbells               " don't beep
"set nolist
set nonumber                   " hide line numbers
set noswapfile                 " Don't create swap file
set nowritebackup
set scrolloff=3
set shell=zsh
set shiftround                 " use multiple of shiftwidth when indenting with '<' and '>'
set shiftwidth=2               " number of spaces to use for autoindenting
set showcmd                    " Display last commands
set showmatch                  " (set show matching parenthesis)
set showmode                   " Display the mode
set showtabline=2              " Show tabs bar
set smartcase                  " ignore case if search pattern is all lowercase, case-sensitive otherwise
set smartindent
set smarttab                   " insert tabs on the start of a line according to shiftwidth, not tabstop
set softtabstop=2
set splitbelow                 "split below the buffer
set splitright                 "split on the right of the buffer
set tabstop=2                  " a tab is 2 spaces
set textwidth=90
set title                      " change the terminal's title
set ts=2 sw=2 et
set ttyfast                    " fast scrolling
set ttymouse=xterm2
set undolevels=1000            " use many muchos levels of undo
set visualbell                 " don't beep
set wildignore=*.swp,*.bak,*.pyc,*.class
set wildmenu                   " Enhanced command line completion
set wildmode=list:longest      " Complete files like a shell
set wrap                       " wrap line when too long

" rails.vim
:set cpoptions+=$ " puts a $ marker for the end of words/lines in cw/c$ commands

:set runtimepath+=~/dotfiles/vim/plugged/,~/dotfiles/vim/snippets/
" vim-rspec
"let g:rspec_command = "!zeus rspec {spec}"
"let g:rspec_command = "!zeus rescue rspec -f d -c {spec}"
let g:rspec_command = "Dispatch rspec -f -d -c {spec}"
"let g:rspec_command = "!rspec {spec}"

" signify

let g:signify_vcs_list = [ 'git' ]
let g:signify_sign_change = '~'

" ctrl-space
"
let g:CtrlSpaceDefaultMappingKey ='<tab>'
"nnoremap <silent><enter> :CtrlSpace O<CR>

" NERDTree
let g:NERDTreeMinimalUI = 1
let g:NERDTreeChDirMode=1 "2 would update the cwd anytime i change the root
let g:NERDTreeWinSize = 20
let g:NERDTreeDirArrows = 0
let g:NERDTreeQuitOnOpen = 1

" easymotion
let g:EasyMotion_startofline = 0

"vim-airline
let g:airline#extensions#hunks#enabled=0
let g:airline#extensions#tabline#enabled = 1

"vim-javascript
let javascript_enable_domhtmlcss=1

set term=screen-256color
syntax enable
highlight clear SignColumn
let g:kolor_italic=1                    " Enable italic. Default: 1
let g:kolor_bold=1                      " Enable bold. Default: 1
let g:kolor_underlined=0                " Enable underline. Default: 0
let g:kolor_alternative_matchparen=0    " Gray 'MatchParen' color. Default: 0
hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" hlsearch
let hlstate=0

"
"vim-indent-guides  tab
"
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 2
let g:indent_guides_color_change_percent = 80

let g:undotree_SetFocusWhenToggle = 1

" choosewin
"
let g:choosewin_overlay_enable = 1
" Custom Functions

let ignore = [".git", "vendor", ".svg", ".eot", "log/", ".jpg", '\/\.', '^\..*'] " ignore hidden files
let excludes= " \| GREP_OPTIONS=\'\' egrep -v -e \'" . join(map(ignore, 'v:val'), "\|") . "\'"
" Run a given vim command on the results of fuzzy selecting from a given shell
" command. See usage below.
" Note: I'm using Iterm2 and remapped ^[ to "Send Hex Codes: 0x03" which is == ^C

if has("persistent_undo")
    set undodir='~/.undodir/'
    set undofile
endif

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

function! SelectaFile(path)
  call SelectaCommand("find " . a:path . "/* -type f", "", ":e")
endfunction

"Fuzzy select
function! SelectaIdentifier()
  " Yank the word under the cursor into the z register
  normal "zyiw
  " Fuzzy match files in the current directory, starting with the word under
  " the cursor
  call SelectaCommand("find * -type f", "-s " . @z, ":e")
endfunction

command! -nargs=0 -bar Qargs execute 'args ' . s:QuickfixFilenames()

" Contributed by "ib."
" http://stackoverflow.com/questions/5686206/search-replace-using-quickfix-list-in-vim#comment8286582_5686810
command! -nargs=1 -complete=command -bang Qdo call s:Qdo(<q-bang>, <q-args>)

function! s:Qdo(bang, command)
  if exists('w:quickfix_title')
    let in_quickfix_window = 1
    cclose
  else
    let in_quickfix_window = 0
  endif

  arglocal
  exe 'args '.s:QuickfixFilenames()
  exe 'argdo'.a:bang.' '.a:command
  argglobal

  if in_quickfix_window
    copen
  endif
endfunction

function! s:QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}

  " if the current window has a local quickfix list (a location list)
  " then use it, otherwise use the global quickfix list
  let quickfix_items = getloclist(0)
  if len(quickfix_items) == 0
    let quickfix_items = getqflist()
  endif

  for quickfix_item in quickfix_items
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor

  return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction
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

function! LightBackground()
  let Mysyn=&syntax
  set background=light
  silent! colorscheme solarized
  hi Normal ctermfg=black ctermbg=white
  hi IndentGuidesEven ctermbg=280
  hi IndentGuidesOdd  ctermbg=NONE
  exe "set syntax=" . Mysyn
endfunction

function! DarkBackground()
  let Mysyn=&syntax
  set background=dark
  silent! colorscheme solarized
  hi IndentGuidesEven ctermbg=280
  hi IndentGuidesOdd  ctermbg=NONE
  exe "set syntax=" . Mysyn
endfunction

"" Zoom / Restore window.
function! ZoomToggle() abort
    if exists('t:zoomed') && t:zoomed
        execute t:zoom_winrestcmd
        let t:zoomed = 0
    else
        let t:zoom_winrestcmd = winrestcmd()
        resize
        vertical resize
        let t:zoomed = 1
    endif
endfunction

hi link EasyMotionTarget ErrorMsg
hi EasyMotionTarget2First ctermbg=280
hi link EasyMotionShade  Comment

" Link function to commands
command! GdiffInTab tabedit %|vsplit|Gdiff

" File type setup

filetype plugin indent on         " Turn on file type detection.

augroup AuNERDTreeCmd
  autocmd AuNERDTreeCmd VimEnter    * call s:CdIfDirectory(expand("<amatch>"))
  autocmd AuNERDTreeCmd FocusGained * call s:UpdateNERDTree()
  augroup AuNERDTreeCmd
  autocmd!
augroup end
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby setlocal tabstop=2
autocmd FileType ruby setlocal shiftwidth=2
autocmd FileType ruby setlocal softtabstop=2
autocmd FileType ruby setlocal commentstring=#\ %s
autocmd FileType ruby noremap view :Eview<CR>
autocmd FileType ruby noremap cont :Econtroller<CR>
autocmd FileType ruby noremap test :A<CR>
autocmd User Rails let b:surround_{char2nr('-')} = "<% \r %>" " displays <% %> correctly

"set autowriteall "save file when buffer switched
au! BufRead,BufNewFile     *.haml   set filetype=haml
au! BufRead,BufNewFile     *.slim   set filetype=slim
au! BufNewFile,BufReadPost *.styl   set filetype=stylus
au! BufNewFile,BufReadPost *.stylus set filetype=stylus

autocmd FileWritePre       * :silent! keepjumps call TrimWhiteSpace()
autocmd FileAppendPre      * :silent! keepjump call TrimWhiteSpace()
autocmd FilterWritePre     * :silent! keepjump call TrimWhiteSpace()
autocmd BufWritePre        * :silent! keepjump call TrimWhiteSpace()
autocmd BufLeave,FocusLost * :silent! wall

" Abbreviations/aliases
"
abbrev bp binding.pry

" Mappings

nnoremap Q <Nop>
nnoremap <silent><C-o> :call ZoomToggle()<CR>
nnoremap <Leader>rr :Dispatch rake rubocop<CR>
nnoremap <Leader>rs :call RunCurrentSpecFile()<CR>
nnoremap <Leader>rn :call RunNearestSpec()<CR>
nnoremap <Leader>rl :call RunLastSpec()<CR>
nnoremap <Leader>ra :call RunAllSpecs()<CR>
nnoremap <leader>d :GdiffInTab<cr>
nnoremap <leader>D :tabclose<cr>
nmap <leader>gb :Gblame<CR>
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gl :Glog<CR>
nmap <leader>gco :Gcommit<CR>
nmap <leader>gr :Git reset HEAD %<CR>
nmap <leader>gc :Git checkout --  %<CR>
nmap <leader>gp :Git push -f<CR>
nnoremap rm :Git rm %<CR>
nnoremap B ^
nnoremap E $

map <Leader>m :NERDTreeToggle<CR>
map <Leader>n :NERDTreeFind<CR>

" easy align
vmap <Enter> <Plug>(EasyAlign)

" choose win
"
map <space> <ESC>:silent! w<CR><Plug>(choosewin)

map <leader>p :set paste<CR>i<esc>"*]p:set nopaste<cr>"
imap <leader>p <ESC>:set paste<CR>i<esc>"*]p:set nopaste<cr>"

nnoremap j gj
nnoremap k gk
nnoremap s :set hlsearch!<cr>

nmap -  zz
map <Leader>r :SlimuxShellLast<CR>
map <leader>t :SlimuxShellPrompt<CR>

" easy motion
map / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)

" signify
nmap <leader>gj <plug>(signify-next-hunk)
nmap <leader>gk <plug>(signify-prev-hunk)

"Vim autoformat
noremap <F6> :Autoformat<CR><CR>

" Invert background
noremap <F1> :call LightBackground()<CR>
noremap <F2> :call DarkBackground()<CR>

" Toggle the undo tree
nnoremap <backspace> :UndotreeToggle<cr>
nnoremap U <C-r>
" ma to mark position to a, mma to recover
nmap ` gg
nnoremap M `

" Find all files in all non-dot directories starting in the working directory.
" Fuzzy select one of those. Open the selected file with :e.
nnoremap <enter> :call SelectaCommand("find * -type f" .g:excludes, "", ":e")<cr>
"nnoremap <space> :call SelectaCommand("git ls-files -cmo --exclude-standard" .g:excludes, "", ":e")<cr>
nnoremap fiv :call SelectaFile("app/views")<cr>
nnoremap fic :call SelectaFile("app/controllers")<cr>
nnoremap fim :call SelectaFile("app/models")<cr>
nnoremap fih :call SelectaFile("app/helpers")<cr>
nnoremap fil :call SelectaFile("lib")<cr>
nnoremap fip :call SelectaFile("public")<cr>
nnoremap fia :call SelectaFile("app/assets")<cr>
nnoremap fis :call SelectaFile("spec")<cr>
nnoremap <c-g> :call SelectaIdentifier()<cr>

nmap mv :call RenameFile()<cr>
nnoremap cd :cd %:p:h<CR>:pwd<CR>

" quick edit/reload vim file
nmap <silent> <leader>ev :e $MYVIMRC<CR>

" Use fd to save
imap fd <ESC>:w<CR>
nnoremap fd <ESC>:w<CR>

inoremap <leader>w <c-w>
nnoremap <leader>w <c-w>
" save the buffer before switching from insert mode
"inoremap <C-j> <ESC>:silent! w<CR><C-w>j
"inoremap <C-k> <ESC>:silent! w<CR><C-w>k
"inoremap <C-h> <ESC>:silent! w<CR>u
"inoremap <C-l> <ESC>:silent! w<CR><C-r>
nnoremap <C-j> <c-d>
nnoremap <C-k> <c-u>
"nnoremap <C-h> u
"nnoremap <C-l> <C-r>
"nnoremap <F3> <C-w><C-r>

nnoremap <down> :cn<CR>
nnoremap <up> :cp<CR>
nnoremap <right> :copen<CR>
nnoremap <left> :cclose<CR>

map <leader>s :split <CR>
map <leader>v :vsplit <CR>

call LightBackground()
