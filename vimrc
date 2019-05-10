
set nocompatible                  "We run vim not VI
call plug#begin('~/.vim/plugged')

" Plugins
"-------------------------------------------

" Coding Tools
Plug 'mbbill/undotree' " Display your undo history in a graph
Plug 'tpope/vim-fugitive' " Git tools
"Plug 'jgdavey/tslime.vim'
Plug 'mhinz/vim-signify' " show modified lines in gutter
Plug 'scrooloose/nerdcommenter'
Plug 'stefandtw/quickfix-reflector.vim' "Replace text from the copen pane
Plug 'editorconfig/editorconfig-vim'
Plug 'moll/vim-node'
Plug 'tpope/vim-rhubarb'
Plug 'terryma/vim-multiple-cursors'

"Code Completion
"Plug 'ervandew/supertab'
Plug 'Shougo/neocomplete.vim'
"let g:deoplete#enable_at_startup = 1
"Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern'  }
"Plug 'Shougo/deoplete.nvim'
"Plug 'roxma/nvim-yarp'
"Plug 'roxma/vim-hug-neovim-rpc'

Plug 'hashivim/vim-terraform'
Plug 'vim-syntastic/syntastic'
Plug 'juliosueiras/vim-terraform-completion'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'cmather/vim-meteor-snippets'
Plug 'tpope/vim-endwise' "Add closing arg (end etc)
Plug 'Chiel92/vim-autoformat' "  code formatting
" Memo:
" S( will surround with (  ) the visual block
" ys+motion +( will surround motion with (
" cs([ will change surround ( by [
" ds( will remove surround (
" dst will remove tags around the current position
" yss{ will wrap sentence in {
Plug 'tpope/vim-surround'

" Navigation
Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle', 'NERDTreeFind']}
Plug 'easymotion/vim-easymotion'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/incsearch-fuzzy.vim'
Plug 'haya14busa/incsearch-easymotion.vim'
Plug 'gorkunov/smartpairs.vim'
Plug 'jiangmiao/auto-pairs'
let g:AutoPairsFlyMode = 1
let g:AutoPairsShortcutBackInsert = '<c-b>'
Plug 'szw/vim-ctrlspace'
Plug 'kshenoy/vim-signature' "add and navigate to marks
Plug 't9md/vim-choosewin'
Plug 'haya14busa/vim-asterisk'

" Syntax
Plug 'jparise/vim-graphql', {'for': 'javascript'}
Plug 'elixir-editors/vim-elixir', {'for': 'elixir'}
Plug 'tpope/vim-rails', { 'for': 'ruby' } "Rails tools
Plug 'thoughtbot/vim-rspec', { 'for': 'ruby' } "Rspec tools
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'jbgutierrez/vim-partial', {'for': 'ruby' } " extract file to partial
Plug 'groenewege/vim-less', {'for': 'less'}
Plug 'nathanaelkane/vim-indent-guides' "display indent guide
Plug 'tpope/vim-haml',          { 'for': 'haml' }
Plug 'slim-template/vim-slim',  { 'for': 'slim' }
Plug 'vim-ruby/vim-ruby',       { 'for': 'ruby' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'mustache/vim-mustache-handlebars', { 'for': 'html' }
Plug 'tpope/vim-markdown'
Plug 'wavded/vim-stylus',       { 'for': 'stylus'}
Plug 'digitaltoad/vim-jade'
Plug 'kchmck/vim-coffee-script'
Plug 'vim-addon-mw-utils'
Plug 'marcweber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'Slava/vim-spacebars', {'for': 'html'}

"Formaters & linters
"Plug 'w0rp/ale'
Plug 'junegunn/vim-easy-align' " easy align things
Plug 'prettier/vim-prettier', {
      \ 'do': 'npm install -g',
      \ 'for':    ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql'] }

"The Theme
Plug 'flazz/vim-colorschemes'
Plug 'altercation/vim-colors-solarized'
Plug 'zeis/vim-kolor'
Plug 'vim-airline/vim-airline' "Bottom bar info
Plug 'vim-airline/vim-airline-themes'
call plug#end()

let mapleader="," " change the mapleader from \ to ,

"
" Pimping vim
"
"set foldmethod=syntax "slow
set foldmethod=indent
set foldlevel=2
set nofoldenable
nnoremap <Leader>f :set nomore<Bar>:ls<Bar>:set more<CR>:b<Space>
" cheatsheet: zO zm/M(minimize) zr/R(fold) zi(toggle zoom)
map zo zO
nnoremap zz zi
nnoremap z+ zr
nnoremap z- zm
nnoremap z1 zR
nnoremap z0 zM
cnoremap $t <CR>:t''<CR>
cnoremap $T <CR>:T''<CR>
cnoremap $m <CR>:m''<CR>
cnoremap $M <CR>:M''<CR>
cnoremap $d <CR>:d<CR>``
set autoindent                 " always set autoindenting on
set autowrite
set backspace=indent,eol,start " allow backspacing over everything in insert mode
set colorcolumn=100
set copyindent                 " copy the previous indentation on autoindenting
set cursorline
set encoding=utf-8
set expandtab
set fileencoding=utf-8
set ignorecase
set smartcase
set hidden
set hlsearch                   " highlight matches
set ignorecase                 " ignore case when searching
set incsearch                  " show search matches as you type
set laststatus=2               " Show the status line all the time
set lazyredraw                 " tells Vim not to bother redrawing during these scenarios, leading to faster macros
set linebreak                  " tells Vim to only wrap at a character in the breakat option
set listchars=tab:>.,trail:.,extends:#,nbsp:.
set mouse-=a
set nobackup
set noerrorbells               " don't beep
"set nolist                     " list disables linebreak
set nonumber                   " hide line numbers
":set number relativenumber
":set nonumber norelativenumber  " turn hybrid line numbers off
set noswapfile                 " Don't create swap file
set nowritebackup
set scrolloff=3
set shell=zsh
set shiftround                 " use multiple of shiftwidth when indenting with '<' and '>'
set shiftwidth=2               " number of spaces to use for autoindenting
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
set textwidth=80
set title                      " change the terminal's title
set ts=2 sw=2 et
set ttyfast                    " fast scrolling
set ttymouse=xterm2
set undolevels=1000            " use many muchos levels of undo
set visualbell                 " don't beep
set wildignore=*.swp,*.bak,*.pyc,*.class
set wildmenu                   " Enhanced command line completion
set wildmode=longest:full:full      " Complete files like a shell
"set wrap                       " wrap line when too long
set formatoptions=l

" check file change every 4 seconds ('CursorHold') and reload the buffer upon detecting change
set autoread                   " refresh unchanged file
au CursorHold,FocusLost * checktime " checkfile when cursor moved

" rails.vim
set cpoptions+=$ " puts a $ marker for the end of words/lines in cw/c$ commands

"nnoremap <tab> gt
"nnoremap <s-tab> gT
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir
set path+=**
"utilsnip
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
"smartpairs
let g:smartpairs_uber_mode = 1
" vim-rspec

" signify

let g:signify_vcs_list = [ 'git' ]
let g:signify_sign_change = '~'

noremap % v%
map vib viB
map cib ciB
map yib yiB

"nmap ( [
"nmap ) ]
"omap ( [
"omap ) ]
"xmap ( [
"xmap ) ]

" ctrl-space
"
let g:CtrlSpaceDefaultMappingKey ='<enter>'
"let g:CtrlSpaceLoadLastWorkspaceOnStart = 1
"let g:CtrlSpaceSaveWorkspaceOnSwitch = 1
"let g:CtrlSpaceSaveWorkspaceOnExit = 1
nnoremap dir :CtrlSpace E<CR>
nmap <silent> Q :CtrlSpace Q<CR>
nmap <silent> <s-tab> :CtrlSpace h<CR>
nmap <silent> <tab> :CtrlSpace a<CR>
nmap <silent> T :CtrlSpace l<CR>
"nnoremap <silent><enter> :CtrlSpace h<CR>
"nnoremap <silent><enter> :CtrlSpace O<CR>
"nnoremap <silent><tab> :bnext<CR>
"nnoremap <silent><s-tab> :bprev<CR>

" NERDTree
let g:NERDTreeMinimalUI = 1
let g:NERDTreeChDirMode=1 "2 would update the cwd anytime i change the root
let g:NERDTreeWinSize = 40
let g:NERDTreeDirArrows = 0
let g:NERDTreeQuitOnOpen = 1

"set statusline=1
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

"Note: This option must be set in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
  let g:neocomplete#sources#syntax#min_keyword_length = 2

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }
" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  "return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
"inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"
let g:terraform_completion_keys = 1
let g:terraform_registry_module_completion = 0
"
let g:neocomplete#enable_auto_select = 1

" Enable heavy omni completion.
"if !exists('g:neocomplete#sources#omni#input_patterns')
  "let g:neocomplete#sources#omni#input_patterns = {}
"endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

"" syntastic
"let g:syntastic_mode_map = { 'passive_filetypes': ['html'] }
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0

"let g:syntastic_html_tidy_ignore_errors = [
 "\ 'plain text isn''t allowed in <head> elements',
 "\ '<template> is not recognized!',
 "\ 'discarding unexpected <template>',
 "\ 'discarding unexpected </template>'
 "\ ]

" easymotion
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_startofline = 0
let g:EasyMotion_smartcase = 1

"vim-airline
let g:airline#extensions#hunks#enabled=0
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1

"vim-javascript
let javascript_enable_domhtmlcss=1

set term=screen-256color
syntax enable
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
let g:indent_guides_start_level = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 100

let g:undotree_SetFocusWhenToggle = 1

" choosewin
"
let g:choosewin_overlay_enable = 1
" Custom Functions

let ignore = [".git", "node_modules","packages", "vendor", ".svg", ".eot", "log/", ".jpg", '\/\.', '^\..*'] " ignore hidden files
let excludes= " \| GREP_OPTIONS=\'\' egrep -v -e \'" . join(map(ignore, 'v:val'), "\|") . "\'"
function! FollowSymlink()
  let current_file = expand('%:p')
  " check if file type is a symlink
  if getftype(current_file) == 'link'
    " if it is a symlink resolve to the actual file path
    "   and open the actual file
    let actual_file = resolve(current_file)
    silent! execute 'file ' . actual_file
  end
endfunction
function! UpdateCurrentPwd()
  " default to the current file's directory
  if expand("%:p:h") !~ g:excludes
    lcd %:p:h
    let git_dir = system("git rev-parse --show-toplevel")
    " See if the command output starts with 'fatal' (if it does, not in a git repo)
    let is_not_git_dir = matchstr(git_dir, '^fatal:.*')
    " if git project, change local directory to git project root
    if empty(is_not_git_dir)
      let $GIT_DIR =git_dir
      lcd `=git_dir`
    endif
  endif
endfunction
function! SetProjectRoot()
  " default to the current file's directory
  if expand("%:p:h") !~ g:excludes
    lcd %:p:h
    let git_dir = system("git rev-parse --show-toplevel")
    " See if the command output starts with 'fatal' (if it does, not in a git repo)
    let is_not_git_dir = matchstr(git_dir, '^fatal:.*')
    " if git project, change local directory to git project root
    if empty(is_not_git_dir)
      let $GIT_DIR =git_dir
      lcd `=git_dir`
    endif
  endif
endfunction
autocmd BufEnter * if expand("%:p:h") !~ g:excludes | silent! lcd %:p:h | endif
autocmd BufRead *
  \ call FollowSymlink() |
  \ call SetProjectRoot()
"autocmd CursorMoved silent *
  "" short circuit for non-netrw files
  "\ if &filetype == 'netrw' |
  "\   call FollowSymlink() |
  "\   call SetProjectRoot() |
  "\ endif
"" Run a given vim command on the results of fuzzy selecting from a given shell
"" command. See usage below.
"" Note: I'm using Iterm2 and remapped ^[ to "Send Hex Codes: 0x03" which is == ^C

"if has("persistent_undo")
  ""let myUndoDir = expand(vimDir . '/undodir')
  ""call system('mkdir ' . vimDir)
  ""call system('mkdir ' . myUndoDir)
  ""let &undodir = myUndoDir
  ""set undofile
"endif

function! SelectaCommand(choice_command, selecta_args, vim_command)
  lcd %:p:h
  let git_dir = system("git rev-parse --show-toplevel")
  " See if the command output starts with 'fatal' (if it does, not in a git repo)
  let is_not_git_dir = matchstr(git_dir, '^fatal:.*')
  " if git project, change local directory to git project root
  if empty(is_not_git_dir)
    lcd `=git_dir`
    endif
  try
    let selection = system(a:choice_command . " | selecta " . a:selecta_args)
  catch /Vim:Interrupt/
    " Swallow the ^C so that the redraw below happens; otherwise there will be
    " leftovers from selecta on the screen
    lcd %:p:h
    redraw!
    return ''
  endtry
  redraw!
  exec a:vim_command . " " . "" .selection . ""
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
  syntax enable
  set t_Co=256
  let g:solarized_visibility = "high"
  let g:solarized_contrast = "high"
  let g:solarized_termtrans = 1
  let Mysyn=&syntax
  set background=light
  colorscheme solarized
  "hi Normal guibg=NONE ctermbg=NONE
  hi IndentGuidesEven ctermbg=252
  hi IndentGuidesOdd  ctermbg=NONE
  "highlight clear SignColumn
  hi ColorColumn cterm=bold ctermbg=280 guibg=#343d46
  hi Comment cterm=italic ctermfg=10 ctermbg=0 guifg=#80a0ff
  "exe "set syntax=" . Mysyn
endfunction

function! DarkBackground()
  syntax enable
  set t_Co=256
  let g:solarized_visibility = "high"
  let g:solarized_contrast = "high"
  let g:solarized_termtrans = 1
  let g:solarized_termtrans = 1
  let Mysyn=&syntax
  set background=dark
  "colorscheme OceanicNext
  colorscheme solarized
  hi IndentGuidesEven ctermbg=280
  hi IndentGuidesOdd  ctermbg=NONE
  hi Comment cterm=italic ctermfg=0 ctermbg=10 guifg=#80a0ff
  hi cursorline ctermbg=0 ctermfg=094108112
  "highlight clear SignColumn
  "hi Normal guibg=NONE ctermbg=NONE
  hi ColorColumn cterm=bold ctermbg=280 guibg=#343d46
  "exe "set syntax=" . Mysyn
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

cabbrev grep Ggrep

" File type setup

filetype plugin indent on         " Turn on file type detection.

"set autowriteall "save file when buffer switched
au! BufRead,BufNewFile     *.haml   set filetype=haml
au! BufRead,BufNewFile     *.slim   set filetype=slim
au! BufNewFile,BufReadPost *.styl   set filetype=stylus
au! BufNewFile,BufReadPost *.stylus set filetype=stylus
au! BufNewFile,BufReadPost *.builder set filetype=ruby
au! BufNewFile,BufReadPost *.voxml set filetype=ruby
au! BufNewFile,BufReadPost *.ex,*.exs set filetype=elixir
autocmd BufNewFile,BufRead *.less set filetype=less
au! BufRead,BufNewFile * set updatetime=2000 " set file diff checkevery 2 sec

autocmd BufReadPost fugitive://* set bufhidden=delete
autocmd User fugitive
  \ if get(b:, 'fugitive_type', '') =~# '^\%(tree\|blob\)$' |
  \   nnoremap <buffer> .. :edit %:h<CR> |
  \ endif

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
autocmd FileType slim set formatoptions-=t
autocmd FileType slim set nolist

autocmd FileType html,xml,json set colorcolumn=0

autocmd FileType html,javascript set shiftwidth=2 tabstop=2 showtabline=2
autocmd FileType html,javascript set nowrap nolist
autocmd FileType html,javascript let g:indent_guides_start_level=1
autocmd FileType html,javascript let g:indent_guides_guide_size=1

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType less set omnifunc=csscomplete#CompleteCSS

let b:autopairs_enabled=0
autocmd FileType html,javascript,css,less let b:autopairs_enabled=1
"autocmd FileType html,javascript,css,less inoremap <buffer> <silent> <left> <ESC>:call search('["\[''({]','bW')<CR>a
"autocmd FileType html,javascript,css,less inoremap <buffer> <silent> <right> <ESC>:call search('["\]'')}]','W')<CR>a
let g:prettier#autoformat = 1
let g:prettier#config#trailing_comma = 'none'
let g:prettier#config#bracket_spacing = 'true'
let g:prettier#config#print_width = 100
"autocmd FileWritePre,BufWrite *.json,*.css,*.scss,*.less,*.graphql PrettierAsync
"autocmd FileWritePre,BufWrite *.js,*.json,*.css,*.scss,*.less,*.graphql PrettierAsync

autocmd User Rails let b:surround_{char2nr('-')} = "<% \r %>" " displays <% %> correctly

autocmd FileWritePre       * :silent! keepjumps call TrimWhiteSpace()
autocmd FileAppendPre      * :silent! keepjump call TrimWhiteSpace()
autocmd FilterWritePre     * :silent! keepjump call TrimWhiteSpace()
autocmd BufWritePre        * :silent! keepjump call TrimWhiteSpace()
"autocmd BufLeave,FocusLost * :silent! wall
"autocmd BufEnter * :call EasyMotion#S(2,1,0)<CR>

" NOTE: more events here: http://vimdoc.sourceforge.net/htmldoc/autocmd.html
let term=$TERM
if term == 'screen-256color'
  autocmd VimEnter * silent !echo -ne "\033Ptmux;\033\033]1337;SetKeyLabel=F6=Format\a\033\\"
  autocmd VimLeave * silent !echo -ne "\033Ptmux;\033\033]1337;SetKeyLabel=F6=F6\a\033\\"
else
  autocmd VimEnter * silent !echo -ne "\033]1337;SetKeyLabel=F6=Format\a"
  autocmd VimLeave * silent !echo -ne "\033]1337;SetKeyLabel=F6=F6\a"
endif
noremap <F6> :Prettier<CR><CR>

" Abbreviations/aliases
"
abbrev bp binding.pry

" Mappings

"nnoremap Q <Nop>
nnoremap <silent><C-o> :call ZoomToggle()<CR>
nnoremap <leader>d :GdiffInTab<cr>
nnoremap <leader>D :tabclose<cr>
nmap gb :Gblame<CR>
nmap gst :Gstatus<CR>
nmap gd :Gdiff<CR>
nmap gl :Glog -15 --<CR>
nmap gco :Gcommit<CR>
nmap gr :Git reset HEAD %<CR>
nmap gc :Git checkout --  %<CR>
nmap gp :Git push -f<CR>
nnoremap a hea
nnoremap rm :Git rm %<CR>

" Disabling temporarily to see if used
map <Leader>m :NERDTreeToggle<CR>
map <Leader>n :NERDTreeFind<CR>

" easy align
augroup VCenterCursor
  au!
  au BufEnter,WinEnter,WinNew,VimResized *,*.*
        \ let &scrolloff=winheight(win_getid())/2
augroup END
"vmap <Enter> <Plug>(EasyAlign) VCenterCursor
vmap <Enter> <Plug>(EasyAlign)

" choose win
"
"nnoremap <silent> <space> :ChooseWinSwapStay<CR>
nnoremap <silent> <C-r> :ChooseWinSwap<CR>
nmap <space> <Plug>(choosewin)
"map <space> <Plug>(easymotion-overwin-line)
"map <space> <Plug>(easymotion-overwin-w)
"nnoremap ? :<C-u>call EasyMotion#OverwinF(2)<cr>
nnoremap s :<C-u>call EasyMotion#OverwinF(2)<cr>

" clipboard unamed will yank vim to clipboard
"set clipboard=unnamed
"nmap <silent> <leader>p :r !pbpaste<CR>
nmap <silent> <leader>p :set paste<CR>"*p:set nopaste<CR>a
imap <silent> <leader>p <ESC>"*pa
"imap <leader>p <ESC>:set paste<CR>"*]p:set nopaste<CR>i
"map <leader>p :set paste<CR>i<esc>"*]p:set nopaste<cr>"
"imap <leader>p <ESC>:set paste<CR>i<esc>"*]p:set nopaste<cr>"

"nnoremap j gj
"nnoremap k gk
nnoremap S :set hlsearch!<cr>

"ropen the previous file
nmap -  :e#<CR>

"nmap <space> <Plug>(easymotion-overwin-line)

" easy motion
"map / <Plug>(easymotion-sn)
"omap / <Plug>(easymotion-tn)
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)
"map  <Leader>f <Plug>(easymotion-bd-w)
"nmap <Leader>f <Plug>(easymotion-overwin-w)

function! s:incsearch_config(...) abort
  " Add   \     incsearch#config#fuzzyspell#converter() for spell converter
  return incsearch#util#deepextend(deepcopy({
  \   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
  \   'keymap': {
  \     "\<CR>": '<Over>(easymotion)'
  \   },
  \   'is_expr': 0
  \ }), get(a:, 1, {}))
endfunction
noremap <silent><expr> /  incsearch#go(<SID>incsearch_config())
noremap <silent><expr> ?  incsearch#go(<SID>incsearch_config({'command': '?'}))
noremap <silent><expr> g/ incsearch#go(<SID>incsearch_config({'is_stay': 1}))
noremap <silent><expr> f incsearch#go(<SID>incsearch_config({'converters': [incsearch#config#fuzzy#converter()]}))

let g:asterisk#keeppos = 1
let g:incsearch#auto_nohlsearch = 1
map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)
nnoremap <backspace> mzJ`z

" signify
nmap gj <plug>(signify-next-hunk)
nmap gk <plug>(signify-prev-hunk)
" Invert background
noremap <F2> :call LightBackground()<CR>
noremap <F1> :call DarkBackground()<CR>

" Toggle the undo tree
nnoremap <C-u> :UndotreeToggle<cr>
nnoremap U <C-r>
" ma to mark position to a, mma to recover
nmap ` gg
nnoremap M `

" Find all files in all non-dot directories starting in the working directory.
" Fuzzy select one of those. Open the selected file with :e.
"nnoremap gt :call SelectaCommand("find * -type f" .g:excludes, "", ":e")<cr>
"nnoremap gt :call SelectaCommand("git ls-files -cmo --exclude-standard" .g:excludes, "", ":e")<cr>
nnoremap cd :call SelectaCommand("find * -type d" .g:excludes, "", "lcd")<cr>
nnoremap gt :call SelectaCommand("git ls-files -cmo --exclude-standard" .g:excludes ."\|sort\| uniq", "", ":tabe")<cr>
nnoremap ge :call SelectaCommand("git ls-files -cmo --exclude-standard" .g:excludes ."\|sort\| uniq", "", ":e")<cr>
nnoremap gv :call SelectaCommand("git ls-files -cmo --exclude-standard" .g:excludes ."\|sort\| uniq", "", ":vs")<cr>
nnoremap gs :call SelectaCommand("git ls-files -cmo --exclude-standard" .g:excludes ."\|sort\| uniq", "", ":sp")<cr>
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
"nnoremap cd :cd %:p:h<CR>:pwd<CR>

" quick edit/reload vim file
nmap <silent> <leader>ev :e $MYVIMRC<CR>

" Use fd to save
imap fd <ESC>:update<CR>
nnoremap fd <ESC>:w<CR>
vnoremap fd <ESC>:w<CR>gv
"cnoremap <silent> w<CR> <ESC>:w<CR>:redraw!<CR>

"ino " ""<left>
"ino ' ''<left>
"ino ( ()<left>
"ino [ []<left>
"ino { {}<left>
"ino {<CR> {<CR>}<ESC>O
"ino {;<CR> {<CR>};<ESC>O

inoremap <leader>w <c-w>
nnoremap <leader>w <c-w>
" save the buffer before switching from insert mode
"inoremap <C-j> <ESC>:silent! w<CR><C-w>j
"inoremap <C-k> <ESC>:silent! w<CR><C-w>k
"inoremap <C-h> <ESC>:silent! w<CR>u
"inoremap <C-l> <ESC>:silent! w<CR><C-r>
nnoremap j jzz
nnoremap k kzz
nnoremap l e
nnoremap h b
"nnoremap J <c-w>j
"nnoremap K <c-w>k
"nnoremap H <c-w>h
"nnoremap L <c-w>l
nnoremap J 5j
nnoremap K 5k
nnoremap H 5b
nnoremap L 5e
"nnoremap J <c-d>
"nnoremap K <c-u>
"nnoremap <C-h> u
"nnoremap <C-l> <C-r>
"nnoremap <F3> <C-w><C-r>

"nnoremap <C-r> <C-w>r

"Move the current window to far:
"nnoremap <leader>wh <C-w>H
"nnoremap <leader>wj <C-w>J
"nnoremap <leader>wk <C-w>K
"nnoremap <leader>wl <C-w>L
nnoremap <down> :cn<CR>
nnoremap <up> :cp<CR>
nnoremap <right> :copen<CR>
nnoremap <left> :cclose<CR>

map <leader>s :split <CR>
map <leader>v :vsplit <CR>

call DarkBackground()
