Repo for my dotfiles
============

This repo is aim to unify all my dotfiles

# Setup

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &&\
curl -L http://install.ohmyz.sh | sh &&\
git clone git@github.com:gregory/dotfiles.git ~/dotfiles &&\
cd ~/dotfiles &&\ rake install
brew install ctags-exuberant
```

## Neovim plugins

Neovim uses [lazy.nvim](https://github.com/folke/lazy.nvim) and bootstraps it automatically.

1. Launch Neovim (`nvim`).
2. Run `:Lazy sync` to clone and build all plugins (this replaces the old `:BundleInstall`).
3. Restart Neovim once the sync completes so all remote plugins are registered.

The Lua configuration re-sources your `~/.vimrc` so all of the existing
Vimscript options, keybindings, and autocommands remain active in Neovim. If
`~/.vimrc` is not available, it falls back to the tracked snapshot at
`nvim/legacy.vim`.


[![Analytics](https://ga-beacon.appspot.com/UA-34823890-2/dotfiles/readme?pixel)](https://github.com/gregory/dotfiles)
