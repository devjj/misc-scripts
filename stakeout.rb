#!/usr/bin/env ruby

# Based on http://www.pragmaticautomation.com/cgi-bin/pragauto.cgi/Monitor/StakingOutFileChanges.rdoc

if ARGV.size < 2
  puts "Usage: stakeout.rb (haml|sass) [files to watch]+"
  exit 1
end

command = ARGV.shift

unless ['haml','sass'].detect{ |c| c == command }
  puts "Usage: stakeout.rb (haml|sass) [files to watch]+"
  exit 1
end

files = {}

ARGV.each do |arg|
  Dir[arg].each { |file|
    files[file] = File.mtime(file)
  }
end

loop do

  sleep 1

  changed_file, last_changed = files.find { |file, last_changed|
    File.mtime(file) > last_changed
  }

  if changed_file
    files[changed_file] = File.mtime(changed_file)
    puts "=> #{changed_file} changed, rebuilding (#{command == 'haml' ? 'HTML' : 'CSS'})..."
    if command == 'haml'
      system(command, changed_file, changed_file.split('.')[0] + '.html')
    elsif command == 'sass'
      system(command, changed_file, '../' + changed_file.split('.')[0] + '.css')
    end
    puts "=> done"
  end

end
