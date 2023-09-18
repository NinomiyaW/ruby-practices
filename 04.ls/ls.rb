require 'debug'

# オプションなしのls
curdir_fullpath = '/'
curdir = Dir.children(curdir_fullpath)
curdir.delete_if{|entry| entry.chars[0] == '.'}
MAX_COLUMN = 3

# カレントディレクトリ直下のファイル表示
curdir.each.with_index(1) do |entry,index|
    # binding.break
    temp_file = curdir_fullpath + entry

    if File.symlink?(temp_file)
        puts "#{File.basename(temp_file)}@".ljust(15)
    elsif File.directory?(temp_file)
        puts "#{File.basename(temp_file)}/".ljust(15)
    else
        puts File.basename(temp_file).ljust(15)
    end
end
puts
