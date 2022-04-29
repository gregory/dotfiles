stty -ixon

export RUBY_GC_HEAP_INIT_SLOTS=600000
export RUBY_GC_HEAP_FREE_SLOTS=600000
export RUBY_GC_HEAP_GROWTH_FACTOR=1.25
export RUBY_GC_HEAP_GROWTH_MAX_SLOTS=300000
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR='vim'
export GREP_OPTIONS='--color=auto -n' GREP_COLOR='7;35'
export ZEUSSOCK=/tmp/zeus.sock
if [ -f ~/.git-prompt.sh ]; then
  source ~/.git-prompt.sh
  export PS1='\h \w$(__git_ps1 "(%s)") \$ '
fi

# Fix tmux vim color
export LESS='-NR'
alias more='less'

alias bower='noglob bower'
alias tmux="TERM=screen-256color-bce $HOME/dotfiles/bin/tmux"

# find a file and less it
function lgrep {
   /usr/local/bin/rg --files-with-matches --no-messages $1 | fzf --preview "bat --style=numbers --color=always {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 $1 || rg --ignore-case --pretty --context 10 $1 {}"
  #less $(egrep -r -e $1 $2 | selecta | cut -d: -f1)
}

# find a file and less it
function lfind {
  less $(find ${1-.} -not -path '*.git/*' -type f | fzf | cut -d: -f1)
}

# find a file and vim it
function vfind {
  vim $(find ${1-.} -not -path '*.git/*' -type f | fzf | cut -d: -f1)
}

fbr() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

fcs() {
  local commits commit
  commits=$(git log --color=always --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e --ansi --reverse) &&
  echo -n $(echo "$commit" | sed "s/ .*//")
}

function fstash() {
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
    fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b);
  do
    mapfile -t out <<< "$out"
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break;
    else
      git stash show -p $sha
    fi
  done
}
function c() {
  local cols sep google_history open
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  if [ "$(uname)" = "Darwin" ]; then
    google_history="$HOME/Library/Application Support/Google/Chrome/Default/History"
    open=open
  else
    google_history="$HOME/.config/google-chrome/Default/History"
    open=xdg-open
  fi
  cp -f "$google_history" /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
}

# find a branch and checkout to it (stash all work before)
function branch {
  git add --all; git stash; git branch | cut -c 3- | selecta | xargs git checkout
}

# find branches and checkout to it (stash all work before)
function checkout {
  git add --all; git stash; git log --pretty=oneline | selecta | cut -d' ' -f1 | xargs git checkout
}

# find a commmit for a file and show it
function commit {
  git log --oneline $1 | selecta | cut -d' ' -f1 | xargs -I commit git show commit:$1
}

# find a commit and show the diff
#function log {
  #git log --pretty=oneline $* | selecta | cut -d' ' -f1 | xargs git show
#}

# find a file, then a version, then show the file at that moment
function show {
  file=$(git ls-files $* | selecta ) && git log --oneline $file | selecta | cut -d' ' -f1 | xargs -I commit git show commit:$file
}

# go to working dir
function cdw {
  pushd $(find $(echo $WORK_PATHS | tr ':' ' ') -maxdepth 3 -type d | selecta)
}

function cdpc {
  eval "$(docker-machine env $1)"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -z "$ZSH_NAME" ] && [ -f ~/.fzf.bash ] && source ~/.fzf.bash
