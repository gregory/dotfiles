# Based on https://github.com/ryanb/dotfiles/blob/master/Rakefile
require 'rake'
require 'erb'

desc "install the dot files into user's home directory"
task :lunchtime do
  `(crontab -l ; echo "0 12 * * 1-5 bash -c \"say -v 'Vicki' 'It is lunch time, baby'\"") | sort - | uniq - | crontab -`
end

task :install do
  #`brew install reattach-to-user-namespace`
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew install direnv
  brew install ripgrep bat fzf
  brew install vim --with-lua #https://github.com/Shougo/neocomplete.vim#vim-for-mac-os-x
  `curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`

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
