"
" Vim cheatsheet => https://devhints.io/vimscript
"
set nocompatible                  "We run vim not VI
let g:polyglot_disabled = ['javascript']
" Ensure vim-plug is available even without network access
let s:dotfiles_dir = fnamemodify(expand('<sfile>'), ':p:h')
let s:plug_vim = stdpath('data') . '/site/autoload/plug.vim'
if !filereadable(s:plug_vim)
  let s:plug_vim = s:dotfiles_dir . '/vim/autoload/plug.vim'
endif
if filereadable(s:plug_vim)
  execute 'source ' . fnameescape(s:plug_vim)
endif
if has('nvim')
  let s:remote_plugins_updated = 0
  function! PlugRemotePlugins(info) abort
    if !s:remote_plugins_updated
      let s:remote_plugins_updated = 1
      UpdateRemotePlugins
    endif
  endfunction
else
  function! PlugRemotePlugins(info) abort
  endfunction
endif

function! PlugCoc(info) abort
  if a:info.status ==? 'installed' || a:info.force
    !./install.sh nightly
    if exists('s:coc_extensions')
      call call('coc#add_extension', s:coc_extensions)
    endif
  elseif a:info.status ==? 'updated'
    !./install.sh nightly
    call coc#util#update()
  endif
  call PlugRemotePlugins(a:info)
endfunction

" Use Neovim's standard data directory for plugins
call plug#begin(stdpath('data') . '/plugged')

" Plugins
"-------------------------------------------

" Coding Tools
Plug 'mbbill/undotree' " Display your undo history in a graph
Plug 'tpope/vim-fugitive' " Git tools "Plug 'jgdavey/tslime.vim'
"Plug 'mhinz/vim-signify' " show modified lines in gutter
Plug 'scrooloose/nerdcommenter'
Plug 'stefandtw/quickfix-reflector.vim' "Replace text from the copen pane
Plug 'editorconfig/editorconfig-vim'
Plug 'moll/vim-node'
Plug 'tpope/vim-rhubarb'
Plug 'terryma/vim-multiple-cursors'

"Code Completion
"Plug 'ervandew/supertab'

let s:coc_extensions = [
      \   'coc-css',
      \   'coc-html',
      \   'coc-json',
      \   'coc-yaml',
      \   'coc-eslint',
      "\   'coc-tslint',
      "\   'coc-tslint-plugin',
      \   'coc-prettier',
      "\   'coc-tsserver',
      "\   'coc-ultisnips'
      "\   'coc-neosnippet'
      \ ]
Plug 'neoclide/coc.nvim', {'branch':'release', 'do': function('PlugCoc')}
"Plug 'SirVer/ultisnips', {'do': function('PlugRemotePlugins')}
Plug 'honza/vim-snippets'
Plug 'hashivim/vim-terraform'
Plug 'vim-syntastic/syntastic'
Plug 'juliosueiras/vim-terraform-completion'
Plug 'cmather/vim-meteor-snippets'

Plug 'tpope/vim-endwise' "Add closing arg (end etc)
Plug 'Chiel92/vim-autoformat' "  code formatting
Plug 'tpope/vim-repeat'
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
Plug 'kana/vim-submode'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/incsearch-fuzzy.vim'
Plug 'haya14busa/incsearch-easymotion.vim'
"Plug 'gorkunov/smartpairs.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'szw/vim-ctrlspace'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'kshenoy/vim-signature' "add and navigate to marks
"Plug 't9md/vim-choosewin'  " NOTE: disavling this to force me to use easymotion
Plug 'haya14busa/vim-asterisk'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'tomtom/tlib_vim'

" Syntax
Plug 'sheerun/vim-polyglot'
Plug 'othree/yajs.vim'
"Plug 'jparise/vim-graphql', {'for': 'graphql'}
"Plug 'nathanaelkane/vim-indent-guides' "display indent guide
Plug 'marcweber/vim-addon-mw-utils'
"Plug 'Slava/vim-spacebars', {'for': 'html'}

"Formaters & linters
"Plug 'w0rp/ale', {
      "\ 'for': ['javascript', 'css', 'json','graphql'],  'do': 'npm install -g eslint' }
Plug 'junegunn/vim-easy-align' " easy align things

"The Theme
Plug 'morhetz/gruvbox'
Plug 'rakr/vim-one'
Plug 'joshdick/onedark.vim'
"Plug 'altercation/vim-colors-solarized'
"Plug 'vim-airline/vim-airline' "Bottom bar info
"Plug 'vim-airline/vim-airline-themes'
Plug 'itchyny/lightline.vim'
call plug#end()

let g:AutoPairsFlyMode = 1
let g:AutoPairsMapCR=0
let g:AutoPairsShortcutBackInsert = '<c-b>'
let g:ale_fixers = {
      \   '*': ['remove_trailing_lines', 'trim_whitespace'],
      \   'javascript': ['eslint'],
      \}
let g:ale_fix_on_save = 1
"let g:ale_linters_explicit = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_keep_list_window_open = 1
"let g:ale_open_list = 1
let g:ale_set_loclist = 1

let mapleader="," " change the mapleader from \ to ,

"
" Pimping vim
"
"set foldmethod=syntax "slow
"augroup fold_manual
  "au FileType javascript setlocal re=1 foldmethod=syntax foldlevel=2
"augroup END
set nofoldenable
"set notimeout ttimeout timeoutlen=100
" cheatsheet: zO zm/M(minimize) zr/R(fold) zi(toggle zoom)
map zo zO
nmap bm <Plug>BookmarkToggle
nmap bi <Plug>BookmarkAnnotate
nmap bn <Plug>BookmarkNext
nmap bp <Plug>BookmarkPrev
nmap ba <Plug>BookmarkShowAll
nmap bC <Plug>BookmarkClearAll
nmap bx <Plug>BookmarkClear
"since i am opening vim in the main process, ctrl-z wont work
nmap <c-z> <nop>

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
set nocursorline "disable this for the moment: https://superuser.com/a/625994
set encoding=utf-8
set expandtab
set fileencoding=utf-8
set hidden
set hlsearch                   " highlight matches
set incsearch                  " show search matches as you type
set laststatus=2               " Show the status line all the time
set lazyredraw                 " tells Vim not to bother redrawing during these scenarios, leading to faster macros
set linebreak                  " tells Vim to only wrap at a character in the breakat option
set listchars=tab:>.,trail:.,extends:#,nbsp:.
"set mouse=nv nvica => normal visual insert commmandLine All
set mouse=                     " disabled
set nobackup
set noerrorbells               " don't beep
"set noea                       "Dont resize buffers when other closes
set ead=ver                    " Only auto resize vertical buffers
set nolist                     " list disables linebreak
set nonumber                   " hide line numbers
":set number relativenumber
":set nonumber norelativenumber  " turn hybrid line numbers off
set noswapfile                 " Don't create swap file
set nowritebackup

"set cmdheight=2 " Better display for messages
set shortmess+=c " don't give |ins-completion-menu| messages.
set signcolumn=yes " always show signcolumns

set scrolloff=3
set shell=/bin/zsh
set shiftround                 " use multiple of shiftwidth when indenting with '<' and '>'
set shiftwidth=2               " number of spaces to use for autoindenting
set showmatch                  " (set show matching parenthesis)
set noshowmatch "disable this for the moment: https://superuser.com/a/625994
set noshowmode                   " Dont Display the mode nymore since powerline
set showtabline=2              " Show tabs bar
set smartcase                  " ignore case if search pattern is all lowercase, case-sensitive otherwise
set ignorecase
set smartindent
set smarttab                   " insert tabs on the start of a line according to shiftwidth, not tabstop
set softtabstop=2
set splitbelow                 "split below the buffer
set splitright                 "split on the right of the buffer
set tabstop=2                  " a tab is 2 spaces
set textwidth=100
set title                      " change the erminal's title
set ts=2 sw=2 et
set ttyfast                    " fast scrolling
if exists('&ttymouse')
  set ttymouse=xterm2
endif
set undolevels=1000            " use many muchos levels of undo
set visualbell                 " don't beep
set t_vb=     "disable visual belt
set viminfo='100,f1
set wildignore=*.swp,*.bak,*.pyc,*.class
set wildmenu                   " Enhanced command line completion
set wildmode=longest:full:full      " Complete files like a shell
"set wrap                       " wrap line when too long
set formatoptions=l

" check file change every 4 seconds ('CursorHold') and reload the buffer upon detecting change
set autoread                   " refresh unchanged file

" rails.vim
set cpoptions+=$ " puts a $ marker for the end of words/lines in cw/c$ commands

let html_no_rendering=1 "disable this for the moment: https://superuser.com/a/625994
"nnoremap <s-tab> gT
let vimDir = '$HOME/.vim'

let &runtimepath.=','.vimDir
set path+=**
let g:EasyMotion_smartcase = 1
"utilsnip
""let g:UltiSnipsExpandTrigger="<c-%>"
"let g:UltiSnipsExpandTrigger="<nop>"
"let g:endwise_no_mappings = 1
"let g:ulti_expand_or_jump_res = 0
"function! <SID>ExpandSnippetOrReturn()
  "let snippet = UltiSnips#ExpandSnippetOrJump()
  "if g:ulti_expand_or_jump_res > 0
    "return snippet
  "else
    "return "\<C-Y>"
  "endif
"endfunction
"inoremap <expr> <CR> pumvisible() ? "\<C-R>=<SID>ExpandSnippetOrReturn()\<CR>" : "\<CR>\<C-R>=EndwiseDiscretionary()\<CR>"
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
"let g:UltiSnipsEditSplit="vertical"
"smartpairs
let g:smartpairs_uber_mode = 1
" vim-rspec

" Vim fzf
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction
let g:fzf_action = {
      \ 'ctrl-o': 'tab split',
      \ 'ctrl-s': 'split',
      \ 'ctrl-v': 'vsplit',
      \ 'ctrl-q': function('s:build_quickfix_list') }
" signify

let g:signify_vcs_list = [ 'git' ]
let g:signify_sign_change = '~'

noremap % v%
map vib viB
map cib ciB
map yib yiB

"cmap w!! w !sudo tee % >/dev/null

"map <silent><F3> <ESC>:exec &mouse!=""? "set mouse=" : "set mouse=nv"<CR>
"tmap <silent><F3> <c-w>: exec &mouse!=""? "set mouse=" : "set mouse=nv"<CR>
tmap <silent><F9> <c-w>: tabnext<cr>
tmap <silent><F7> <c-w>: tabprevious<cr>
tmap <silent><F8> <c-w>: tabnew<cr>
nmap <silent><F9> <c-w>: tabnext<cr>
nmap <silent><F7> <c-w>: tabprevious<cr>
nmap <silent><F8> <c-w>: tabnew<cr>
nmap <s-tab> <c-w>: CtrlSpace List

"nmap ( [
"nmap ) ]
"omap ( [
"omap ) ]
"xmap ( [
"xmap ) ]

" vim-bookmarks
let g:bookmark_save_per_working_dir = 1
let g:bookmark_auto_save = 1
" ctrl-space
"
let g:CtrlSpaceDefaultMappingKey ='<x>'
"let g:CtrlSpaceLoadLastWorkspaceOnStart = 1
let g:CtrlSpaceSaveWorkspaceOnSwitch = 1
"let g:CtrlSpaceSaveWorkspaceOnExit = 1
nnoremap <nowait> dir :CtrlSpace E<CR>
nmap <silent><nowait> Q :CtrlSpace Q<CR>
nmap <silent><nowait> <tab> :CtrlSpace a<CR>
"nnoremap <nowait>ls :set nomore<Bar>:ls<Bar>:set more<CR>:b<Space>
nnoremap <nowait><leader>f :echo join(sort(map(filter(range(0, bufnr('$')), 'bufwinnr(v:val)>=0'), 'fnamemodify(bufname(v:val), ":t")'), 'n'), "\n")
nnoremap <expr><silent><space> v:count ? ":\<c-u> ". v:count ." wincmd w\<cr>" : "\<c-w>"
nmap <silent><nowait> T :CtrlSpace l<CR>
nmap <silent><nowait> W :CtrlSpace w<CR>
nmap <nowait> <enter> :GFiles -cmo --exclude-standard<cr>
nmap <nowait> ge :Ggrep<cr>
"nnoremap <silent><enter> :CtrlSpace h<CR>
"nnoremap <silent><enter> :CtrlSpace O<CR>
"nnoremap <silent><tab> :bnext<CR>
"nnoremap <silent><s-tab> :bprev<CR>

" NERDTree
let g:NERDTreeMinimalUI = 1
"let g:NERDTreeChDirMode=2 "2 would update the cwd anytime i change the root
let g:NERDTreeWinSize = 40
let g:NERDTreeDirArrows = 0
let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeAutoDeleteBuffer = 1
let NERDTreeIgnore = ['^node_modules$[[dir]]', '^coverage$[[dir]]']

"Note: This option must be set in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0

let g:terraform_completion_keys = 1
let g:terraform_registry_module_completion = 0
"

" easymotion
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_startofline = 0
let g:EasyMotion_smartcase = 1

let g:tcd_blacklist = '\v(cheat40|denite|gundo|help|nerdtree|netrw|peekaboo|quickmenu|startify|tagbar|undotree|unite|vimfiler|vimshell|fzf)'
fu! ToggleCurline ()
  if &cursorline && &cursorcolumn
    "set nocursorline
    set nocursorcolumn
  else
    "set cursorline
    set cursorcolumn
  endif
endfunction

nmap <nowait> cl :call ToggleCurline()<CR>
augroup BgHighlight
    autocmd!
    autocmd WinEnter * set cul
    autocmd WinEnter * set colorcolumn=100
    autocmd WinLeave * set nocul
    autocmd WinLeave * set colorcolumn=0
augroup END

"set statusline=1
"set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
function! LightlineFilename()
  let root = fnamemodify(get(b:, 'git_dir'), ':h')
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    let file = path[len(root)+1:]
    return &filetype !~# g:tcd_blacklist && winwidth(0) <= len(file) ?  '' : file
  endif
  return &filetype !~# g:tcd_blacklist && winwidth(0) > 70 ? expand('%') : &filetype
endfunction
function! LightlineMode()
  return expand('%:t') ==# '__Tagbar__' ? 'Tagbar':
        \ expand('%:t') ==# 'ControlP' ? 'CtrlP' :
        \ &filetype ==# 'vimfiler' ? 'VimFiler' :
        \ &filetype ==# 'javascript.jsx' ? '[JS]' :
        \ &filetype ==# 'javascript' ? '[JS]' :
        \ &filetype ==# '' ? lightline#mode() : '[' . &filetype . ']'
endfunction
function! LightlineFileEncoding()
  return winwidth(0) > 100 ? &fileencoding: ''
endfunction

function! LightlineFiletype()
  return winwidth(0) > 100 ? (&filetype !=# '' ? '' : '<>') : ''
endfunction
function! CocCurrentFunction()
  return get(b:, 'coc_current_function', '')
endfunction

let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode',  'paste'],
      \             [ 'filename', 'modified']
      \           ],
      \   'right': [ ['position', 'modified'],
      \              [ 'percent' , 'filetype', 'fileencoding'],
      \              ['syntastic', 'cocstatus']
      \            ]
      \ },
      \ 'inactive': {
      \   'left': [
      \             [ 'filename',  'modified']
      \           ],
      \   'right': [ ['position'],
      \            ]
      \ },
      \ 'component_function': {
      "\   'gitbranch': 'fugitive#head',
      \   'filename': 'LightlineFilename',
      \   'fileencoding': 'LightlineFileEncoding',
      \   'filetype': 'LightlineFiletype', 'mode': 'LightlineMode', 'cocstatus':'coc#status',
      \   'currentfunction': 'CocCurrentFunction'
      \ },
      \ 'component': {
      \   'charvaluehex': '0x%B',
      \   'position': '%{winnr()}:%n %2l:%-1v'
      \ },
      \ 'component_expand': {'syntastic': 'SyntasticStatuslineFlag'},
      \ 'component_type': {'syntastic': 'error'},
      \ 'subseparator': { 'left': ">", 'right': ">" },
      \ 'separator': { 'left': "", 'right': "" },
      \ }

let g:lightline.tab = {
      \ 'active': [ 'tabnum', 'filename', 'modified' ],
      \ 'inactive': [ 'tabnum', 'filename', 'modified' ] }

if exists('*lightline#colorscheme#fill')
  let g:lightline#colorscheme#Greg#palette = lightline#colorscheme#fill(g:lightline#colorscheme#one#palette)
  "let g:lightline#colorscheme#Greg#palette= lightline#colorscheme#fill(g:lightline#colorscheme#onedark#palette)
  let g:lightline#colorscheme#Greg#palette.inactive.right[0] = ['#fafafa', '#98c379', 255, 35, 'bold']
  "let g:lightline#colorscheme#Greg#palette.inactive.left[0] = ['#fafafa', '#98c379', 255, 35, 'bold']
  let g:lightline#colorscheme#Greg#palette.inactive.left[0] = g:lightline#colorscheme#Greg#palette.normal.left[1]
endif

"vim-javascript
let javascript_enable_domhtmlcss=1

let &t_ZH="\e[3m" " for italic comments end
let &t_ZR="\e[23m" " for italic comments start

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

let ignore = [".git", "node_modules/","packages", "vendor", ".svg", ".eot", "log/", ".jpg", '\/\.', '^\..*'] " ignore hidden files
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

function! SetProjectRoot()
  " default to the current file's directory
  lcd %:p:h
  let git_dir = system("git rev-parse --show-toplevel")
  " See if the command output starts with 'fatal' (if it does, not in a git repo)
  let is_not_git_dir = matchstr(git_dir, '^fatal:.*')
  " if git project, change local directory to git project root
  if empty(is_not_git_dir)
    lcd `=git_dir`
  endif
endfunction

augroup custom_augroup
  au!
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
  autocmd FileType json syntax match Comment +\/\/.\+$+

  autocmd FileType html,javascript set shiftwidth=2 tabstop=2 showtabline=2
  autocmd FileType html,javascript set nowrap list
  autocmd FileType html,javascript let g:indent_guides_start_level=2
  autocmd FileType html,javascript let g:indent_guides_guide_size=2

  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType less set omnifunc=csscomplete#CompleteCSS

  au CursorHold,FocusLost * checktime " checkfile when cursor moved
  autocmd BufEnter * if expand("%:p:h") !~ g:excludes | silent! lcd %:p:h | endif
  autocmd BufRead *
        \ call FollowSymlink() |
        \ call SetProjectRoot()
  "set autowriteall "save file when buffer switched
  au! BufRead,BufNewFile .envrc,.env set filetype=config
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
  autocmd User Rails let b:surround_{char2nr('-')} = "<% \r %>" " displays <% %> correctly

  autocmd FileWritePre       * :silent! keepjumps call TrimWhiteSpace()
  autocmd FileAppendPre      * :silent! keepjump call TrimWhiteSpace()
  autocmd FilterWritePre     * :silent! keepjump call TrimWhiteSpace()
  autocmd BufWritePre        * :silent! keepjump call TrimWhiteSpace()
  let term=$TERM
  if term == 'screen-256color'
    autocmd VimEnter * :silent !echo -ne "\033Ptmux;\033\033]1337;SetKeyLabel=F6=Format\a\033\\"
    autocmd VimLeave * :silent !echo -ne "\033Ptmux;\033\033]1337;SetKeyLabel=F6=F6\a\033\\"
  else
    autocmd VimEnter * :silent !echo -ne "\033]1337;SetKeyLabel=F6=Format\a"
    autocmd VimLeave * :silent !echo -ne "\033]1337;SetKeyLabel=F6=F6\a"
  endif
augroup END
"autocmd CursorMoved silent *
"" short circuit for non-netrw files
      "\ if &filetype == 'netrw' |
      "\   call FollowSymlink() |
      "\   call SetProjectRoot() |
      "\ endif
"" Run a given vim command on the results of fuzzy selecting from a given shell
"" command. See usage below.
"" Note: I'm using Iterm2 and remapped ^[ to "Send Hex Codes: 0x03" which is == ^C

if has("persistent_undo")
  let myUndoDir = expand(vimDir . '/undodir')
  call system('mkdir ' . vimDir)
  call system('mkdir ' . myUndoDir)
  let &undodir = myUndoDir
  set undofile
endif

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
    exec ':Gmove ' . new_name
    "exec ':saveas ' . new_name
    "exec ':silent !rm ' . old_name
    "redraw!
  endif
endfunction

syntax enable

syntax keyword javascriptImport require

function! SetTransp()
  hi normal ctermbg=none
  hi Terminal ctermbg=none
  set t_vb=
endfunction

function! LightBackground()
  set notermguicolors
  set t_Co=256
  " 'term' option is read-only in Neovim
  let g:solarized_visibility = "high"
  let g:solarized_contrast = "high"
  let g:solarized_termtrans = 0

  let g:one_allow_italics = 1 " I love italic for comments
  set t_8b=^[[48;2;%lu;%lu;%lum
  set t_8f=^[[38;2;%lu;%lu;%lum
  "hi clear
  "syntax reset
  silent! colorscheme one
  set background=light
  let g:lightline.colorscheme = 'Greg'
  hi Comment cterm=italic
  hi! link javascriptOperator Identifier
  hi Terminal ctermfg=23 ctermbg=255
  hi! link IndentGuidesEven CursorLine
  hi! link IndentGuidesOdd noise
  let g:indent_guides_guide_size=2
  "hi jsStorageClass ctermfg=170 guifg=#C678DD
  "call SetTransp()
endfunction

function! DarkBackground()
  set notermguicolors
  set t_Co=256
  " 'term' option is read-only in Neovim
  "let g:solarized_visibility = "high"
  "let g:solarized_contrast = "high"
  "let g:solarized_termtrans = 0
  let g:onedark_termcolors=256
  set background=dark
  "colorscheme onedark
  silent! colorscheme gruvbox
  hi Comment cterm=italic
  let g:indent_guides_guide_size=2
  "https://github.com/pangloss/vim-javascript/blob/master/syntax/javascript.vim
  hi! link IndentGuidesEven CursorLine
  hi! link IndentGuidesOdd noise

  hi Terminal ctermfg=145 ctermbg=235

  let g:lightline.colorscheme = 'Greg'
  call SetTransp()
endfunction

function! TransparentBackground()
  set notermguicolors
  set t_Co=256
  " 'term' option is read-only in Neovim
  let g:solarized_visibility = "high"
  let g:solarized_contrast = "high"
  let g:solarized_termtrans = 0
  let g:onedark_termcolors=256
  "hi clear
  "syntax reset
  set background=dark
  silent! colorscheme onedark
  hi Comment cterm=italic
  hi! link javascriptAsyncFuncKeyword Keyword
  hi! link javascriptNodeGlobal Structure
  hi! link javascriptGlobal Structure
  hi! link javascriptOperator Identifier
  "colorscheme gruvbox
  let g:indent_guides_guide_size=2
  "https://github.com/pangloss/vim-javascript/blob/master/syntax/javascript.vim
  "hi! link jsGlobalNodeObjects GruvboxAqua
  "hi! link jsStorageClass Gruvboxyellow
  "hi! link jsOperator Gruvboxyellow
  "hi! link jsFuncCall Gruvboxorange
  "hi! link jsGlobalObjects Gruvboxyellow
  hi! link IndentGuidesEven CursorLine
  hi! link IndentGuidesOdd noise

  hi Terminal ctermfg=145 ctermbg=235

  let g:lightline.colorscheme = 'Greg'
  call SetTransp()
endfunction

function! SetTheme()
  let iterm_profile = $ITERM_PROFILE
  " Color scheme based on time
  if iterm_profile == "Dark"
    call DarkBackground()
  else
    call LightBackground()
  endif
  hi! link javascriptOperator Identifier
  "match ExtraWhitespace /\s\+$/
  "hi ExtraWhitespace ctermbg=red guibg=red
  set visualbell                 " don't beep
  set t_vb=     "disable visual belt
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
abbrev requrie require
cabbrev git Git

" File type setup

filetype plugin indent on         " Turn on file type detection.

"augroup AuNERDTreeCmd
  "autocmd!
  "autocmd AuNERDTreeCmd VimEnter    * call s:CdIfDirectory(expand("<amatch>"))
  "autocmd AuNERDTreeCmd FocusGained * call s:UpdateNERDTree()
"augroup END

let b:autopairs_enabled=0
autocmd FileType html,javascript,css,less let b:autopairs_enabled=1
"autocmd FileType html,javascript,css,less inoremap <buffer> <silent> <left> <ESC>:call search('["\[''({]','bW')<CR>a
"autocmd FileType html,javascript,css,less inoremap <buffer> <silent> <right> <ESC>:call search('["\]'')}]','W')<CR>a
let g:prettier#autoformat = 1
let g:prettier#config#trailing_comma = 'none'
let g:prettier#config#bracket_spacing = 'true'
let g:prettier#config#print_width = 100
"autocmd FileWritePre,BufWrite *.json,*.css,*.scss,*.less,*.graphql PrettierAsync
"autocmd FileWritePre,BufWrite *.js,*.jsx,*.json,*.css,*.scss,*.less,*.graphql PrettierAsync

"autocmd BufLeave,FocusLost * :silent! wall
"autocmd BufEnter * :call EasyMotion#S(2,1,0)<CR>

" NOTE: more events here: http://vimdoc.sourceforge.net/htmldoc/autocmd.html
"autocmd VimEnter * :silent! term ++curwin
command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument
noremap <silent><special> <F6> :Prettier<CR>

" Abbreviations/aliases
"
"abbrev bp binding.pry

" Mappings

"nnoremap Q <Nop>
nnoremap <silent><C-o> :call ZoomToggle()<CR>
tnoremap <silent><C-o> <c-w>: call ZoomToggle()<CR>
nnoremap <leader>d :GdiffInTab<cr>
nnoremap <leader>D :tabclose<cr>
nmap <nowait> gb :Git blame<CR>
nmap <nowait> gs :Git status<CR>
nmap <nowait> gd :Git diff<CR>
nmap <nowait> gl :Git log -15 --<CR>
nmap <nowait> gr :Git reset HEAD %<CR>
nmap <nowait> gck :Git checkout --  %<CR>
nmap <nowait> gc :Git commit<CR>
nmap <nowait> gp :Git push -f<CR>
nmap <nowait> rm :Git rm %<CR>
nnoremap a hea

" Disabling temporarily to see if used
map <nowait> <Leader>m :NERDTreeToggle<CR>
map <nowait> <Leader>n :NERDTreeFind<CR>

" easy align
augroup VCenterCursor
  au!
  au BufEnter,WinEnter,WinNew,VimResized *,*.*
        \ let &scrolloff=winheight(win_getid())/2
augroup END
""vmap <Enter> <Plug>(EasyAlign) VCenterCursor
vmap <Enter> <Plug>(EasyAlign)

" choose win
"
"nnoremap <silent> <space> :ChooseWinSwapStay<CR>
"nnoremap <silent> <C-r> :ChooseWinSwap<CR>
"nnoremap ? :<C-u>call EasyMotion#OverwinF(2)<cr>
nnoremap s :<C-u>call EasyMotion#OverwinF(2)<cr>

" clipboard unamed will yank vim to clipboard
"set clipboard=unnamed
"
" :r read the content of the command into the buffer
map <silent> <leader>p <c-w>: r! pbpaste<CR>
"tnoremap <silent> <leader>p <c-w>: r! pbpaste<CR>
tnoremap <silent> <leader>p <c-w>: set paste<CR>"*p<cr><c-w>: set nopaste<CR>a

"inoremap <silent> <leader>p :r! pbpaste<CR>
"nmap <silent> <leader>p :set paste<CR>"*p:set nopaste<CR>a
"imap <silent> <leader>p <ESC>"*pa
"imap <leader>p <ESC>:set paste<CR>"*]p:set nopaste<CR>i
"
"imap <leader>p <ESC>:set paste<CR>i<esc>"*]p:set nopaste<cr>"
"nmap <silent> <leader>p :set paste<CR>"*p:set nopaste<CR>a
"imap <silent> <leader>p :set paste<CR>"*p:set nopaste<CR>a

"
"
" This allow to past directly from alfred
"
function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif

  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"

  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction

"let &t_SI .= WrapForTmux("\<Esc>[?2004h")
"let &t_EI .= WrapForTmux("\<Esc>[?2004l")

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

"tnoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

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
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'. synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
"map  <Leader>f <Plug>(easymotion-bd-w)
"nmap <Leader>f <Plug>(easymotion-overwin-w)

function! s:incsearch_config(...) abort
  " Add   \     incsearch#config#fuzzyspell#converter() for spell converter
  return incsearch#util#deepextend(deepcopy({
        \   'modules': [incsearch#config#easymotion#module()],
        \   'keymap': {
        \     "\<CR>": '<Over>(easymotion)'
        \   },
        \   'is_expr': 0
        \ }), get(a:, 1, {}))
endfunction
noremap <silent><expr> ?  incsearch#go(<SID>incsearch_config({'command': '?'}))
noremap <silent><expr> g/ incsearch#go(<SID>incsearch_config({'is_stay': 1}))
noremap <silent><expr> / incsearch#go(<SID>incsearch_config({'is_stay': 0}))
noremap <silent><expr> f incsearch#go(<SID>incsearch_config({'converters': [incsearch#config#fuzzy#converter()]}))

augroup incsearch-keymap
  autocmd!
  autocmd VimEnter * call s:incsearch_keymap()
augroup END
function! s:incsearch_keymap()
  IncSearchNoreMap <Right> <Over>(incsearch-next)
  IncSearchNoreMap <Left>  <Over>(incsearch-prev)
  IncSearchNoreMap <Tab>  <Over>(incsearch-scroll-f)
  IncSearchNoreMap <S-Tab>    <Over>(incsearch-scroll-b)
endfunction

let g:asterisk#keeppos = 1
let g:incsearch#auto_nohlsearch = 1
map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)
nnoremap i :noh<cr>i
"turn off hl search when insert

nnoremap <backspace> mzJ`z

" signify
nmap gj <plug>(signify-next-hunk)
nmap gk <plug>(signify-prev-hunk)

" Invert background
noremap <F1> :call DarkBackground()<CR>
noremap <F2> :call LightBackground()<CR>
noremap <F3> :call TransparentBackground()<CR>

" Toggle the undo tree
nnoremap <C-u> :UndotreeToggle<cr>
nnoremap U <C-r>

" ma to mark position to a, mma to recover
"nmap ` gg
"nmap m `
"nnoremap M m

nnoremap cd :call SelectaCommand("find * -type d" .g:excludes, "", "lcd")<cr>
nnoremap gs :GFiles?<cr>
nnoremap ? :BLines<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NOTE: Remap :CtrlSpace a to this function
function! PrintFooBar(k)
  ":Windows
  echo "Foo Bar!"
  "call SelectaCommand("git ls-files -cmo --exclude-standard" .g:excludes ."\|sort\| uniq", "", ":e")
endfunction
let g:CtrlSpaceKeys = { "Buffer": { "b": "PrintFooBar" } }
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'
" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)
" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      "\ pumvisible() ? "\<C-n>" :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
"inoremap <silent><expr><cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

"let g:coc_snippet_next = '<tab>'
"let g:coc_node_path='/usr/local/bin/node'
let g:coc_node_path='/Users/greg/.nvm/versions/node/v16.12.0/bin/node'
" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
"nmap <leader>f  <Plug>(coc-format-selected)
augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

"if executable("ag")
"let g:CtrlSpaceGlobCommand = 'ag -l --nocolor -g ""'
"endif
"inoremap <expr> <c-g> fzf#vim#complete(fzf#wrap({
      "\ 'prefix': '^.*$',
      "\ 'source': 'rg -n ^ --color always',
      "\ 'options': '--ansi --delimiter : --nth 3..',
      "\ 'reducer': { lines -> join(split(lines[0], ':\zs')[2:], '') }}))

nnoremap mru :call fzf#run({
      \  'source':  v:oldfiles,
      \  'sink':    'e',
      \  'options': '-m -x +s --exact',
      \  'down':    '20%'})<cr>
"command! -bang -nargs=* GGrep
      "\ call fzf#vim#grep(
      "\   'git grep --line-number '.shellescape(<q-args>), 1,
      "\ fzf#vim#with_preview(),
      "\ <bang>0)

command! -bang -nargs=* Ggrep
      \ call fzf#vim#grep('rg --column --no-heading --ignore -S --follow -C3 --line-number --color=always '.shellescape(<q-args>),1,
      \ fzf#vim#with_preview(),
      \ <bang>0)

command! -bang -nargs=* Rg
  \ call fzf#vim#grep('rg --column --no-heading --ignore -S --follow -C3 --line-number --color=always '.shellescape(<q-args>),
  \ 1,
      \     fzf#vim#with_preview({ 'dir':system('git rev-parse --show-toplevel 2> /dev/null')[:-2] }, 'right:50%:hidden', 'f3'),
  \ <bang>0)
command! -bang -nargs=* GrepLocal
  \ call fzf#vim#grep('rg --column --no-heading --ignore -S --follow -C3 --line-number --color=always '.shellescape(<q-args>),
  \ 1,
      \     fzf#vim#with_preview('right:50%:hidden', 'f3'),
  \ <bang>0)
command! -bang -nargs=* MarksWithPreview
  \ call fzf#vim#marks( fzf#vim#with_preview({ 'dir':system('git rev-parse --show-toplevel 2> /dev/null')[:-2] }, 'right:50%:hidden', 'f3'),
  \ <bang>0)
"command! -bang -nargs=* Rg
  "\ call fzf#vim#grep('rg --column --no-heading --ignore -S --follow --line-number --color=always '.shellescape(<q-args>),
  "\ 1,
      "\   <bang>0 ? fzf#vim#with_preview('up:60%')
      "\           : fzf#vim#with_preview('right:50%:hidden', 'f3'),
  "\ <bang>0)

command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>,
  \     fzf#vim#with_preview({ 'dir':system('git rev-parse --show-toplevel 2> /dev/null')[:-2] }, 'right:50%:hidden', 'f3'),
  \ <bang>0)

"" Command for git grep
"" - fzf#vim#grep(command, with_column, [options], [fullscreen])
"command! -bang -nargs=* GGrep
      "\ call fzf#vim#grep(
      "\   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
      "\   <bang>0 ? fzf#vim#with_preview('up:60%')
      "\           : fzf#vim#with_preview('right:50%:hidden', '?'),
      "\   <bang>0)

nnoremap <c-g> :Rg<cr>
nmap mv :call RenameFile()<cr>
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
"nnoremap cd :cd %:p:h<CR>:pwd<CR>

" quick edit/reload vim file
nmap <silent> <leader>ev :e $MYVIMRC<CR>

" Use fd to save
inoremap fd <ESC>:update<CR>
nnoremap <silent> fd :w<CR>
vnoremap <silent> fd :w<CR>gv
"cnoremap <silent> w<CR> <ESC>:w<CR>:redraw!<CR>

"ino " ""<left>
"ino ' ''<left>
"ino ( ()<left>
"ino [ []<left>
"ino { {}<left>
"ino {<CR> {<CR>}<ESC>O
"ino {;<CR> {<CR>};<ESC>O

nnoremap <silent> <c-f>v :vert term ++close ++kill="kill"<cr>
nnoremap <silent> <c-f>s :term ++close ++kill="kill"<cr>
nnoremap <silent> <c-f>t :term ++close ++kill="kill" ++rows=25<cr>
nnoremap <silent> <c-f>= :term ++close ++kill="kill" ++rows=25<cr>
nnoremap <silent> <c-k> :wincmd k<cr>
nnoremap <silent> <c-h> :wincmd h<cr>
nnoremap <silent> <c-l> :wincmd l<cr>
nnoremap <silent> <c-j> :wincmd j<cr>
nnoremap <silent> <s-up> :resize +5<cr>
nnoremap <silent> <s-down> :resize -5<cr>
nnoremap <silent> <s-left> :vertical resize -5<cr>
nnoremap <silent> <s-right> :vertical resize +5<cr>

if has("terminal")
  tnoremap <Leader>f <c-w>: set nomore<Bar>:ls<Bar>:set more<CR>:b<Space>
  tnoremap <nowait> <c-f>: <c-w>:
  tnoremap <nowait> fd <c-w>N
  tnoremap <nowait> gt <c-w>: tabnext<cr>
  tnoremap <nowait> :q <c-w>: q!
  tnoremap <silent> <c-k> <c-w>: wincmd k<cr>
  tnoremap <silent> <c-h> <c-w>: wincmd h<cr>
  tnoremap <silent> <c-l> <c-w>: wincmd l<cr>
  tnoremap <silent> <c-j> <c-w>: wincmd j<cr>
  tnoremap <silent> <s-up>    <c-w>: resize +5<cr>
  tnoremap <silent> <s-down>  <c-w>: resize -5<cr>
  tnoremap <silent> <s-left>  <c-w>: vertical resize +5<cr>
  tnoremap <silent> <s-right> <c-w>: vertical resize -5<cr>
  "tnoremap <silent> : <c-w>:
  tmap <leader>S <c-w>: aboveleft new<CR>
  tmap <leader>V <c-w>: aboveleft vert new<CR>
  tmap <leader>s <c-w>: new<CR>
  tmap <leader>v <c-w>: vert new<CR>

  "tnoremap <silent> <F2> <c-w>: call LightBackground()<CR>
  "tnoremap <silent> <F1> <c-w>: call DarkBackground()<CR>
  tnoremap <silent> <c-f>v <c-w>: vert term ++close ++kill="int"<cr>
  tnoremap <silent> <c-f>s <c-w>: term ++close ++kill="int"<cr>
  tnoremap <silent> <c-f>t <c-w>: term ++close ++kill="int" ++rows=25<cr>
  tnoremap <silent> <c-f>= <c-w>=
endif

"Move to marks
"nnoremap <c-j> ]`
"nnoremap <c-k> [`
"
"nmap mm m,
nnoremap <silent> M :MarksWithPreview<cr>
nnoremap j jzz
nnoremap k kzz
nnoremap l e
nnoremap h b
"nnoremap J <c-w>j
"nnoremap K <c-w>k
"nnoremap H <c-w>h
"nnoremap L <c-w>l
nnoremap J 10jzz
nnoremap K 10kzz
nnoremap H 5b
nnoremap L 5e

nnoremap <down> :cn<CR>
nnoremap <up> :cp<CR>
nnoremap <right> :copen<CR>
nnoremap <left> :cclose<CR>
nnoremap <c-down> :lne<CR>
nnoremap <c-up> :lpr<CR>
nnoremap <c-right> :lop<CR>
nnoremap <c-left> :lcl<CR>

map <leader>S :aboveleft split <CR>
map <leader>V :aboveleft vsplit <CR>
map <leader>s :split <CR>
map <leader>v :vsplit <CR>

call SetTheme()

