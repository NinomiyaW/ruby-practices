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

  path =  "#{Dir.getwd}/"
  entries = Dir.entries(path).sort
  sorted_entries = options.key?(:r) ? entries.reverse : entries
  filtered_entries = options.key?(:a) ? sorted_entries : sorted_entries.reject { |entry| entry.start_with?('.') }
  options.key?(:l) ? show_in_long_format(filtered_entries, path) : show_in_short_format(filtered_entries, path)
end

def show_in_long_format(entries, _path)
  entries_long_format = []
  entries.each do |entry|
    entry_details = File.lstat(entry)
    entry_details_hash = {}

    entry_details_hash[:permission] = export_permission(entry_details)
    entry_details_hash[:hardlink] = entry_details.nlink
    entry_details_hash[:owner_name] = Etc.getpwuid(entry_details.uid).name
    entry_details_hash[:group_name] = Etc.getgrgid(entry_details.gid).name
    entries_long_format << entry_details_hash
  end

  p entries_long_format
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
  filetype_string + permission_string
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
    entry_path = path + entry
    if File.symlink?(entry_path)
      "#{entry}@"
    elsif File.directory?(entry_path)
      "#{entry}/"
    else
      entry
    end
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
