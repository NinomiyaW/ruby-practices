# frozen_string_literal: true

COLUMN = 3
SPACE = 1

def main
  current_path = '../../dummy/' # "#{Dir.getwd}/"
  current_entries = Dir.entries(current_path).sort
  hidden_removed_entries = current_entries.delete_if { |entry| entry.start_with?('.') }
  distinct_entries = distinguish_entries(hidden_removed_entries, current_path)
  row = (distinct_entries.length.to_f / COLUMN).ceil
  aligned_entries = align_entries(row, distinct_entries)

  width = calculate_width(distinct_entries)
  aligned_entries.each do |col_entries|
    print_col(width, col_entries)
    puts
  end
end

def distinguish_entries(entries, absolute_path)
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

def calculate_width(entries)
  entries.max_by(&:length).length + SPACE
end

def align_entries(row, entries)
  row_aligned_entries = entries.each_slice(row).to_a
  row_aligned_entries.map { |col_entries| col_entries.values_at(0...row) }.transpose
end

def print_col(width, col_entries)
  col_entries.each do |entry|
    next if entry.nil?

    print entry.ljust(width)
  end
end

main
