#!/usr/bin/env bash
# One-shot setup for a fresh (or existing) Mac:
#
#   git clone https://github.com/gregory/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh
#
# Safe to re-run: every step skips what is already done. Existing files that
# would be replaced by a symlink are moved to ~/.dotfiles-backup/<timestamp>/.
#
# Env switches (mostly for testing):
#   SKIP_BREW=1   don't install Homebrew / run `brew bundle`
#   SKIP_ITERM=1  don't touch iTerm2 preferences
set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
FAILED=()

bold() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$*"; }
ok()   { printf '  ✓ %s\n' "$*"; }

# Run a step; record it as failed instead of aborting the whole install.
step() {
  local name=$1; shift
  bold "$name"
  if ! "$@"; then
    warn "$name failed — continuing"
    FAILED+=("$name")
  fi
}

# ---------------------------------------------------------------- prerequisites
xcode_tools() {
  if xcode-select -p >/dev/null 2>&1; then ok "Command Line Tools present"; return 0; fi
  xcode-select --install || true
  echo "Finish the Command Line Tools installer, then re-run $0"
  exit 1
}

homebrew() {
  if ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew && ! -x /usr/local/bin/brew ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1
  fi
  load_brew
  ok "$(brew --version | head -1)"
}

load_brew() {
  if [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then eval "$(/usr/local/bin/brew shellenv)"
  fi
}

brew_bundle() {
  brew bundle --file="$DOTFILES/Brewfile"
}

oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then ok "oh-my-zsh present"; return 0; fi
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

# -------------------------------------------------------------------- symlinks
# link <file in repo> <destination>
link() {
  local src="$DOTFILES/$1" dst=$2
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    ok "${dst/#$HOME/~}"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/"
    warn "moved existing ${dst/#$HOME/~} to ${BACKUP/#$HOME/~}/"
  fi
  ln -s "$src" "$dst"
  ok "${dst/#$HOME/~} -> $1"
}

symlinks() {
  local f
  for f in ackrc bashrc gemrc gitconfig gitignore guardfile pryrc rspec tmux.conf vimrc zshrc vim; do
    link "$f" "$HOME/.$f"
  done
  link nvim "$HOME/.config/nvim"
  # Not bin/tmux: it calls `tmux` itself and would recurse once on PATH
  # (bashrc aliases tmux to it instead).
  link bin/heat.mjs "$HOME/.local/bin/heat"
  link bin/it2setkeylabel "$HOME/.local/bin/it2setkeylabel"
  # gitconfig [include]s this for machine-specific settings.
  [[ -e "$HOME/.gitconfig.local" ]] || touch "$HOME/.gitconfig.local"
}

# ---------------------------------------------------------------------- node
node_lts() {
  command -v fnm >/dev/null 2>&1 || { warn "fnm not installed"; return 1; }
  eval "$(fnm env --shell bash)"
  if fnm list | grep -q 'default'; then
    ok "node default already set"
  else
    fnm install --lts || return 1
    fnm list | grep -q 'default' || fnm default "$(fnm list | grep -o 'v[0-9.]*' | tail -1)"
  fi
  eval "$(fnm env --shell bash)"
  fnm use default >/dev/null
  ok "node $(node --version)"
}

# ---------------------------------------------------------------------- vim
vim_plugins() {
  command -v vim >/dev/null 2>&1 || return 1
  vim -E -s -u "$HOME/.vimrc" +'PlugInstall --sync' +qa </dev/null
  ok "vim-plug plugins installed"
}

# --------------------------------------------------------------------- neovim
nvim_setup() {
  command -v nvim >/dev/null 2>&1 || return 1
  command -v node >/dev/null 2>&1 || warn "node missing — npm-based Mason packages will fail"
  # lazy.nvim auto-installs missing plugins at their *latest* commit and
  # rewrites lazy-lock.json whenever nvim starts with plugins missing (the first
  # start also errors until NvChad's base46 theme cache is built). So: keep a
  # copy of the committed lockfile, let those first starts happen, then put the
  # lockfile back and `Lazy! restore` to check out exactly the pinned commits.
  local lock="$DOTFILES/nvim/lazy-lock.json" saved rc=0
  saved=$(mktemp)
  cp "$lock" "$saved"
  nvim --headless '+Lazy! restore' +qa >/dev/null 2>&1
  nvim --headless '+Lazy! restore' +qa >/dev/null 2>&1
  ok "lazy.nvim plugins installed"

  # Mason LSPs/formatters (chadrc.lua) + treesitter parsers, blocking.
  nvim --headless -c "luafile $DOTFILES/setup/nvim-bootstrap.lua" 2>&1 || rc=1

  cp "$saved" "$lock" && rm -f "$saved"
  nvim --headless '+Lazy! restore' +qa >/dev/null 2>&1 || rc=1
  ok "plugins pinned to lazy-lock.json"
  return $rc
}

# ---------------------------------------------------------------------- iTerm
# Shortcuts, profiles and colours all live in iterm2/com.googlecode.iterm2.plist
# and are read by iTerm2's own "load preferences from a custom folder", so there
# is nothing to script for them. Transparency stays a script: it resolves THIS
# machine's wallpaper at run time, which a checked-in plist cannot carry.
iterm() {
  if [[ -n "${SKIP_ITERM:-}" ]]; then ok "skipped"; return 0; fi
  if pgrep -xq iTerm2 || pgrep -xq iTerm; then
    warn "iTerm2 is running — quit it (⌘Q) and re-run $0"
    return 0
  fi
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES/iterm2"
  killall cfprefsd 2>/dev/null || true
  ok "prefs from $DOTFILES/iterm2 (shortcuts, profiles, colours)"
  bash "$DOTFILES/bin/iterm-setup-transparency.sh"
}

# ------------------------------------------------------------------------ run
cd "$DOTFILES" || exit 1

if [[ -z "${SKIP_BREW:-}" ]]; then
  step "Xcode Command Line Tools" xcode_tools
  step "Homebrew" homebrew
  step "Brewfile packages" brew_bundle
else
  load_brew
fi
# Symlinks first: with ~/.zshrc already in place, the oh-my-zsh installer keeps it.
step "Symlinks" symlinks
step "oh-my-zsh" oh_my_zsh
step "Node (fnm, LTS)" node_lts
step "Vim plugins" vim_plugins
step "Neovim (plugins, LSP servers, formatters, treesitter parsers)" nvim_setup
step "iTerm2 (prefs folder + transparency)" iterm

bold "Done"
if ! gh auth status >/dev/null 2>&1; then
  warn "GitHub CLI not logged in (git uses it for credentials): gh auth login"
fi
echo "  • Copilot in nvim: open nvim and run :Copilot auth"
echo "  • Set iTerm2's font to 'JetBrainsMono Nerd Font' for nvim icons"
echo "  • iTerm2 → Settings → General → Preferences: set 'Save changes' to"
echo "    Automatically, so what you change in the UI flows back to the repo"
echo "  • Machine-specific shell config goes in ~/.zsh.local, git config in ~/.gitconfig.local"
if ((${#FAILED[@]})); then
  warn "Failed steps: ${FAILED[*]} — fix and re-run $0 (it skips what is done)"
  exit 1
fi
echo "  Open a new terminal (exec zsh) to pick everything up."
