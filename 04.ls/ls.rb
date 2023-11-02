# frozen_string_literal: true

require 'optparse'
require 'ffi-xattr'
require 'etc'

COLUMN_COUNT = 3
SPACE = 1
PERMISSION_TYPES = ['--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze

def main
  options = {}
  opt = OptionParser.new
  opt.on('-r')
  opt.on('-a')
  opt.on('-l')
  opt.parse!(ARGV, into: options)

  path = "#{Dir.getwd}/"
  entries = Dir.entries(path).sort

  sorted_entries = options.key?(:r) ? entries.reverse : entries
  filtered_entries = options.key?(:a) ? sorted_entries : sorted_entries.reject { |entry| entry.start_with?('.') }
  options.key?(:l) ? show_long_format(filtered_entries, path) : show_short_format(filtered_entries, path)
end

def show_long_format(entries, path)
  long_format_rows = []
  total_blocks = 0
  entries.each do |entry|
    lstat = File.lstat(entry)
    total_blocks += lstat.blocks
    long_format_rows << load_status_each_entry(entry, lstat, path)
  end
  print_long_data(long_format_rows, total_blocks)
end

def load_status_each_entry(entry, lstat, path)
  xattr = Xattr::Lib.list(path + entry, true)
  columns = []
  permission = format_permission(lstat)
  columns << (xattr.empty? ? "#{permission} " : "#{permission}@")
  columns << lstat.nlink.to_s.rjust(3)
  columns << Etc.getpwuid(lstat.uid).name
  columns << Etc.getgrgid(lstat.gid).name.rjust(5)
  columns << lstat.size.to_s.rjust(5)
  columns << lstat.ctime.strftime('%m %d %H:%M')
  file_name = append_suffix_by_filetype(entry, path)
  detailed_file_name = lstat.ftype == 'link' ? "#{file_name} -> #{File.readlink(entry)}" : file_name
  columns << detailed_file_name
end

def format_permission(lstat)
  filetype =
    case ftype = lstat.ftype
    when 'fifo'
      'p'
    when 'file'
      '-'
    else
      ftype.slice(0)
    end
  # File::lstat#modeの結果から権限に関わる部分を切り取る
  octal_permission = lstat.mode.to_s(8).rjust(6, '0')[3..6]
  permission =
    octal_permission.each_char.map do |num|
      PERMISSION_TYPES[num.to_i - 1]
    end.join
  "#{filetype}#{permission}"
end

def append_suffix_by_filetype(entry, path)
  entry_path = path + entry
  if File.symlink?(entry_path)
    "#{entry}@"
  elsif File.directory?(entry_path)
    "#{entry}/"
  else
    entry
  end
end

def print_long_data(long_format_rows, blocks)
  puts "total #{blocks}"
  long_format_rows.each do |columns|
    puts columns.join(' ')
  end
end

def show_short_format(entries, path)
  entries_with_suffix = append_suffix_to_entries(entries, path)

  row_count = (entries_with_suffix.length.to_f / COLUMN_COUNT).ceil
  aligned_entries = align_entries(row_count, entries_with_suffix)

  width = calculate_width(entries_with_suffix)
  aligned_entries.each do |row_entries|
    print_row_data(width, row_entries)
  end
end

def append_suffix_to_entries(entries, path)
  entries.map do |entry|
    append_suffix_by_filetype(entry, path)
  end
end

def calculate_width(entries)
  entries.max_by(&:length).length + SPACE
end

def align_entries(row_count, entries)
  row_aligned_entries = entries.each_slice(row_count).to_a
  row_aligned_entries.map { |col_entries| col_entries.values_at(0...row_count) }.transpose
end

def print_row_data(width, row_entries)
  row_entries.each do |col_entry|
    print col_entry.ljust(width) unless col_entry.nil?
  end
  puts
end

main
