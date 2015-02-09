# Based on https://github.com/ryanb/dotfiles/blob/master/Rakefile
require 'rake'
require 'erb'

desc "install the dot files into user's home directory"
task :install do
  replace_all = false
  files = Dir['*'] - %w[Rakefile README.md LICENSE"]
  files.each do |file|
    system %Q{mkdir -p "$HOME/.#{File.dirname(file)}"} if file =~ /\//
    if File.exist?(File.join(ENV['HOME'], ".#{file.sub(/\.erb$/, '')}"))
      if File.identical? file, File.join(ENV['HOME'], ".#{file.sub(/\.erb$/, '')}")
        puts "identical ~/.#{file.sub(/\.erb$/, '')}"
    elsif replace_all
      replace_file(file)
    else
      print "overwrite ~/.#{file.sub(/\.erb$/, '')}? [ynaq] "
      case $stdin.gets.chomp
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
    end
    else
      link_file(file)
    end
  end
  system %Q{vim -c "silent! PluginInstall" -c "qa!" ~/.vimrc}
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
    system %Q{ln -s "$PWD/#{file}" "$HOME/.#{file}"}
  end
end
