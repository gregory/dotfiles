Repo for my dotfiles
============

This repo is aim to unify all my dotfiles

# Setup

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &&\
curl -L http://install.ohmyz.sh | sh &&\
git clone git@github.com:gregory/dotfiles.git ~/dotfiles &&\
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim &&\
cd ~/dotfiles &&\ rake install
brew install ctags-exuberant
```

Then Enter vim and do :BundleInstall


[![Analytics](https://ga-beacon.appspot.com/UA-34823890-2/dotfiles/readme?pixel)](https://github.com/gregory/dotfiles)
