Repo for my dotfiles
============

This repo is aim to unify all my dotfiles

# Setup

On a fresh Mac (or to repair an existing one — it is safe to re-run):

```
git clone https://github.com/gregory/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
```

(`rake install` does the same thing.)

`install.sh` does, in order:

1. Xcode Command Line Tools, Homebrew, and everything in [`Brewfile`](Brewfile)
   (neovim, vim, tmux, fzf, ripgrep, fnm, direnv, gh, git-lfs, tree-sitter-cli,
   Nerd Font, iTerm2, …)
2. Symlinks every dotfile into `~` (`nvim` → `~/.config/nvim`, `bin/heat` →
   `~/.local/bin/heat`). Anything already there is moved to
   `~/.dotfiles-backup/<timestamp>/`.
3. oh-my-zsh, Node LTS via fnm
4. vim-plug plugins, Neovim plugins at the `lazy-lock.json` commits, every Mason
   LSP/formatter from `nvim/lua/chadrc.lua` and every treesitter parser
5. iTerm2 key mappings + transparency (skipped while iTerm2 is running —
   quit it and run `rake iterm`)

Afterwards: `gh auth login`, `:Copilot auth` in nvim, and set iTerm2's font to
*JetBrainsMono Nerd Font*. Machine-specific config goes in `~/.zsh.local` and
`~/.gitconfig.local` (never tracked).
