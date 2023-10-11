# frozen_string_literal: true

require 'optparse'
COLUMN_COUNT = 3
SPACE = 1
def main
  got_options = {}
  opt = OptionParser.new
  opt.on('-a') { |v| v }
  opt.parse!(ARGV, into: got_options)

  path =  "#{Dir.getwd}/"
  entries = Dir.entries(path).sort
  entries_after_checked_options = got_options.key(true) == :a ? entries : entries.delete_if { |entry| entry.start_with?('.') }
  marked_entries = append_suffix_by_file_type(entries_after_checked_options, path)
  row_count = (marked_entries.length.to_f / COLUMN_COUNT).ceil
  aligned_entries = align_entries(row_count, marked_entries)

  width = calculate_width(marked_entries)
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
