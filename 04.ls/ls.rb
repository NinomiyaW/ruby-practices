# frozen_string_literal: true

require 'optparse'
require 'debug'
COLUMN_COUNT = 3
SPACE = 1
PERMISSION_TYPE = ['--x', '-w-', '-wx', 'r--', 'r-x', 'rw-', 'rwx'].freeze

def main
  options = {}
  opt = OptionParser.new
  opt.on('-r') { |v| v }
  opt.on('-a') { |v| v }
  opt.on('-l') { |v| v }
  opt.parse!(ARGV, into: options)

  path =  "/"
  entries = Dir.entries(path).sort
  sorted_entries = options.key?(:r) ? entries.reverse : entries
  filtered_entries = options.key?(:a) ? sorted_entries : sorted_entries.reject { |entry| entry.start_with?('.') }
  options.key?(:l) ? show_in_long_format(filtered_entries, path) : show_in_short_format(filtered_entries, path)
end

def show_in_long_format(entries, path)
  Dir.chdir(path)
  entries_long_format = []
  total_blocks = 0
  width = 0
  entries.each do |entry|
    entry_details = File.lstat(entry)
    total_blocks += entry_details.blocks
    entry_details_array = []

    entry_details_array << export_permission(entry_details)
    entry_details_array << entry_details.nlink.to_s.rjust(2)
    entry_details_array << Etc.getpwuid(entry_details.uid).name
    entry_details_array << Etc.getgrgid(entry_details.gid).name
    entry_details_array << entry_details.size.to_s.rjust(4)
    entry_details_array << format_time(entry_details.ctime)
    entry_details_array << fetch_filetype(entry,path)
    # binding.break
    temp_width = calculate_width(entry_details_array)
    width = temp_width if width < temp_width
    # binding.break
    entries_long_format << entry_details_array
  end
  # binding.break
  puts 'total ' + total_blocks.to_s
  entries_long_format.each do |entry|
    # binding.break
    entry.each do | element |
      print element.to_s + ' '
    end
    puts
  end
end

def export_permission(entry_details)
  filetype_string =
    case ftype = entry_details.ftype
    when 'fifo'
      'p'
    when 'file'
      '-'
    else
      ftype.slice(0)
    end
  # File::lstat#modeの結果から権限に関わる部分を切り取る
  for_permission_check = entry_details.mode.to_s(8).rjust(6, '0')[3..6]
  permission_string =
    for_permission_check.each_char.map do |permission|
      PERMISSION_TYPE[permission.to_i - 1]
    end.join
  filetype_string + permission_string + " "
end

def format_time(time)
  [:month,:day,:hour,:min].map do | unit |
    if unit == :hour
      time.hour.to_s.rjust(2) + ':'
    elsif unit == :min
      time.min.to_s.rjust(2,'0')
    else
      time.send(unit).to_s.rjust(2) + ' '
    end
  end.join
end

def fetch_filetype(entry,path)
  entry_path = path + entry
  if File.symlink?(entry_path)
    "#{entry}@"
  elsif File.directory?(entry_path)
    "#{entry}/"
  else
    entry
  end
end

def show_in_short_format(entries, path)
  entries_with_suffix = append_suffix_by_file_type(entries, path)

  row_count = (entries_with_suffix.length.to_f / COLUMN_COUNT).ceil
  aligned_entries = align_entries(row_count, entries_with_suffix)

  width = calculate_width(entries_with_suffix)
  aligned_entries.each do |row_entries|
    print_row_data(width, row_entries)
  end
end

def append_suffix_by_file_type(entries, path)
  entries.map do |entry|
    fetch_filetype(entry,path)
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
