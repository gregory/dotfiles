# Everything the dotfiles expect on PATH. Installed by ./install.sh via
# `brew bundle`; safe to re-run (already-installed entries are skipped).

# shell
brew "zsh"
brew "direnv"            # zshrc: direnv hook
brew "fnm"               # zshrc: node version manager (replaced nvm)
brew "fzf"               # zshrc: Ctrl-R / Ctrl-T / Alt-C, bashrc helpers
brew "ripgrep"           # lgrep, fzf-lua
brew "fd"                # fzf-lua file pickers
brew "bat"               # lgrep preview
brew "tmux"
brew "reattach-to-user-namespace" # tmux.conf copy/paste
brew "ack"               # ackrc
brew "sqlite"            # bashrc: c() chrome history

# git
brew "git"
brew "git-lfs"           # gitconfig [filter "lfs"]
brew "gh"                # gitconfig credential helper

# editors
brew "neovim"
brew "vim"
brew "tree-sitter-cli"   # nvim-treesitter (main) compiles parsers with it
brew "universal-ctags"
brew "luarocks"          # lazy.nvim checkhealth / rocks support
brew "wget"

# fonts / apps
cask "font-jetbrains-mono-nerd-font" # NvChad statusline icons
# skip if installed by hand (the cask refuses to overwrite an existing app)
cask "iterm2" unless File.exist?("/Applications/iTerm.app")
