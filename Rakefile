# Based on https://github.com/ryanb/dotfiles/blob/master/Rakefile
require 'rake'
require 'erb'

desc "install the dot files into user's home directory"
task :lunchtime do
  `(crontab -l ; echo "0 12 * * 1-5 bash -c \"say -v 'Vicki' 'It is lunch time, baby'\"") | sort - | uniq - | crontab -`
end

desc "install iTerm2 GlobalKeyMap entries + profile transparency"
task :iterm do
  # Must be run with iTerm2 quit (⌘Q) — the scripts enforce this and
  # exit with a clear message otherwise. Re-running is safe / idempotent.
  # Transparency pairs with nvim's Normal/NormalNC bg=NONE in user/init.lua
  # to give the "floating windows" look between splits.
  sh "bash #{File.expand_path('bin/iterm-setup-keys.sh', __dir__)}"
  sh "bash #{File.expand_path('bin/iterm-setup-transparency.sh', __dir__)}"
end

task :install do
  # Bare shell lines used to live here (brew install …, /usr/bin/ruby …)
  # but they aren't valid Ruby — they caused the whole Rakefile to fail
  # to parse, breaking every task including :iterm. Wrapping each in `sh`.
  sh 'which brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  sh 'brew install direnv'
  sh 'brew install ripgrep bat fzf'
  sh 'brew install vim'  # --with-lua was removed from Homebrew in 2019
  # Nerd Font for NvChad statusline icons (LSP, git branch, file icons, ...).
  sh 'brew install --cask font-jetbrains-mono-nerd-font'
  sh 'curl -fLo ~/.vim/autoload/plug.vim --create-dirs ' \
     'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

  # iTerm2 key-forwarding entries + profile transparency/background image.
  # Both scripts no-op with a clear message if iTerm2 is currently running.
  Rake::Task[:iterm].invoke

  system %Q{ cp -r $HOME/dotfiles/bin/* /usr/local/bin/}
  replace_all = ENV['REPLACE_ALL'] || false
  files = Dir['*'] - %w[Rakefile README.md LICENSE"]
  files.each do |file|
    system %Q{mkdir -p "$HOME/.#{File.dirname(file)}"} if file =~ /\//
    if File.exist?(File.join(ENV['PWD'], "#{file.sub(/\.erb$/, '')}"))
      if File.identical? file, File.join(ENV['HOME'], ".#{file.sub(/\.erb$/, '')}")
        puts "identical ~/.#{file.sub(/\.erb$/, '')}"
      elsif replace_all
        replace_file(file)
      else
        print "overwrite ~/.#{file.sub(/\.erb$/, '')}? [ynaq] "
        gets = $stdin.gets
        if gets
          case gets.chomp
          when 'a'
            replace_all = true
            replace_file(file)
          when 'y'
            replace_file(file)
          when 'q'
            exit
          else
            puts "skipping ~/.#{file.sub(/\.erb$/, '')}"
          end
        else
          puts "skipping ~/.#{file.sub(/\.erb$/, '')}"
        end
      end
      link_file(file)
    end
  end
end

task :vimify do
  system %Q{vim -c "silent! PlugInstall" -c "qa!" ~/.vimrc}
end

def replace_file(file)
  system %Q{rm -rf "$HOME/.#{file.sub(/\.erb$/, '')}"}
  link_file(file)
end

def link_file(file)
  if file =~ /.erb$/
    puts "generating ~/.#{file.sub(/\.erb$/, '')}"
    File.open(File.join(ENV['HOME'], ".#{file.sub(/\.erb$/, '')}"), 'w') do |new_file|
    new_file.write ERB.new(File.read(file)).result(binding)
  end
  elsif file =~ /zshrc$/ # copy zshrc instead of link
    puts "copying ~/.#{file}"
    system %Q{cp "$PWD/#{file}" "$HOME/.#{file}"}
  else
    puts "linking ~/.#{file}"
    system %Q{ln -fs "$PWD/#{file}" "$HOME/.#{file}"}
  end
end
