# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
ZSH_THEME="robbyrussell"

DISABLE_AUTO_TITLE="true"

# Allow [ or ] whereever you want
unsetopt nomatch

export dirstacksize=5

plugins=(git brew)

source $ZSH/oh-my-zsh.sh

# User configuration

eval "$(/opt/homebrew/bin/direnv hook zsh)"

# --- Lazy-load nvm (saves ~1.5s on shell startup) ---
# nvm.sh itself is slow to source, and oh-my-zsh's load-nvmrc runs it eagerly.
# Instead we register shim functions that source nvm on first use.
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  _nvm_load() {
    unset -f nvm node npm npx yarn pnpm 2>/dev/null
    \. "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  }
  nvm()   { _nvm_load; nvm   "$@"; }
  node()  { _nvm_load; node  "$@"; }
  npm()   { _nvm_load; npm   "$@"; }
  npx()   { _nvm_load; npx   "$@"; }
  yarn()  { _nvm_load; yarn  "$@"; }
  pnpm()  { _nvm_load; pnpm  "$@"; }
  # Add default node bin to PATH so `which node` works without triggering load
  if [[ -f "$NVM_DIR/alias/default" ]]; then
    _nvm_default_ver="$(<"$NVM_DIR/alias/default")"
    [[ -d "$NVM_DIR/versions/node/$_nvm_default_ver/bin" ]] && \
      export PATH="$NVM_DIR/versions/node/$_nvm_default_ver/bin:$PATH"
    unset _nvm_default_ver
  fi
fi

[[ -s ~/.bashrc ]] && source ~/.bashrc
[[ -s ~/.zsh.local ]] && source ~/.zsh.local

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/opt/homebrew/opt/mongodb-community@4.2/bin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# Added by Antigravity
export PATH="/Users/greg/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
# Docker CLI completions (compinit is already run by oh-my-zsh)
fpath=(/Users/greg/.docker/completions $fpath)
