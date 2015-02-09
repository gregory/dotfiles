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
  export PS1='\[\e[00;37m\]\u\[\e[01;37m\]:`[[ $(git status 2> /dev/null | head -n2 | tail -n1) != "# Changes to be committed:" ]] && echo "\[\e[31m\]" || echo "\[\e[33m\]"``[[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]] || echo "\[\e[32m\]"`$(__git_ps1 "(%s)\[\e[00m\]")\[\e[01;34m\]\w\[\e[00m\]\$ '
fi

# Fix tmux vim color
export LESSPIPE=`which src-hilite-lesspipe.sh`
export LESSOPEN="| ${LESSPIPE} %s"
export LESS='-RNf'

alias bower='noglob bower'
alias tmux="TERM=screen-256color-bce tmux"

# find a file and less it
function lgrep {
  less $(egrep -r -e $1 $2 | selecta | cut -d: -f1)
}

# find a file and less it
function lfind {
  less $(find ${1-.} -not -path '*.git/*' -type f | selecta | cut -d: -f1)
}

# find a file and vim it
function vfind {
  vim $(find ${1-.} -not -path '*.git/*' -type f | selecta | cut -d: -f1)
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
function log {
  git log --pretty=oneline $* | selecta | cut -d' ' -f1 | xargs git show
}

# find a file, then a version, then show the file at that moment
function show {
  file=$(git ls-files $* | selecta ) && git log --oneline $file | selecta | cut -d' ' -f1 | xargs -I commit git show commit:$file
}

# go to working dir
function cdw {
  pushd $(find $(echo $WORK_PATHS | tr ':' ' ') -maxdepth 1 -type d | selecta)
}
