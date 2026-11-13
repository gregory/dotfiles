# ~/.zshrc — symlinked from ~/dotfiles/zshrc by ./install.sh.
# Machine-specific bits (secrets, extra PATH entries, work aliases) go in
# ~/.zsh.local, which is sourced last and never tracked.

# Homebrew first so everything below (and oh-my-zsh) finds brew's binaries.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

typeset -U path
path=("$HOME/.local/bin" $path)

# --- oh-my-zsh --------------------------------------------------------------
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
DISABLE_AUTO_TITLE="true"
DISABLE_AUTO_UPDATE="true"
ZSH_DISABLE_COMPFIX="true"   # skip compaudit on every startup
plugins=(git)
[[ -s $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

# Allow [ or ] wherever you want
unsetopt nomatch
export dirstacksize=5

# --- tools ------------------------------------------------------------------
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
# fnm reads .nvmrc / .node-version on cd.
(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --shell zsh)"
# Ctrl-R / Ctrl-T / Alt-C
(( $+commands[fzf] )) && source <(fzf --zsh)

[[ -s ~/.bashrc ]] && source ~/.bashrc
[[ -s ~/.zsh.local ]] && source ~/.zsh.local
