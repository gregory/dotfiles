# Based on https://github.com/ryanb/dotfiles/blob/master/Rakefile
require 'rake'

desc "lunch-time reminder in crontab"
task :lunchtime do
  `(crontab -l ; echo "0 12 * * 1-5 bash -c \"say -v 'Vicki' 'It is lunch time, baby'\"") | sort - | uniq - | crontab -`
end

desc "point iTerm2 at the repo's preferences folder + profile transparency"
task :iterm do
  # Must be run with iTerm2 quit (⌘Q): it rewrites its prefs on quit and would
  # clobber this. Re-running is safe / idempotent.
  # Shortcuts, profiles and colours come from the checked-in
  # iterm2/com.googlecode.iterm2.plist. Transparency stays a script because it
  # needs this machine's wallpaper; it pairs with nvim's Normal/NormalNC
  # bg=NONE in user/init.lua to give the "floating windows" look between splits.
  sh %q{defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true}
  sh %Q{defaults write com.googlecode.iterm2 PrefsCustomFolder -string "#{__dir__}/iterm2"}
  sh "bash #{File.expand_path('bin/iterm-setup-transparency.sh', __dir__)}"
end

desc "install everything (brew packages, symlinks, oh-my-zsh, node, vim + nvim plugins, LSPs)"
task :install do
  # All the logic lives in install.sh so a fresh Mac needs nothing but bash.
  sh File.expand_path('install.sh', __dir__)
end

desc "install vim + nvim plugins only"
task :vimify do
  sh 'vim -E -s -u ~/.vimrc +"PlugInstall --sync" +qa </dev/null'
  sh %q{nvim --headless "+Lazy! restore" +qa}
end
