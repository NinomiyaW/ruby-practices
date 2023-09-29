# frozen_string_literal: true

COLUMN = 3
SPACE = 1
def main
  current_path = "#{Dir.getwd}/"
  current_entries = Dir.entries(current_path).sort
  hidden_removed_entries = current_entries.delete_if { |entry| entry.start_with?('.') }
  distincted_entries = get_distincted_entries(hidden_removed_entries, current_path)
  row = (distincted_entries.length.to_f / COLUMN).ceil
  aligned_entries = get_aligned_entries(row, distincted_entries)

  col_width = get_width(distincted_entries)
  aligned_entries.each do |col_entries|
    print_col(col_entries, col_width)
    puts
  end
end

def get_distincted_entries(entries, absolute_path)
  entries.map do |entry|
    entry_path = absolute_path + entry
    if File.symlink?(entry_path)
      "#{entry}@"
    elsif File.directory?(entry_path)
      "#{entry}/"
    else
      entry
    end
  end
end

def get_width(entries)
  entries.max_by(&:length).length + SPACE
end

def get_aligned_entries(row, entries)
  row_aligned_entries = entries.each_slice(row).to_a
  row_aligned_entries.map { |col_entries| col_entries.values_at(0...row) }.transpose
end

def print_col(col, width)
  col.each do |element|
    next if element.nil?

    print element.ljust(width)
  end
end

main
