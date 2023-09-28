# frozen_string_literal: true

COLUMN = 3
SPACE = 3

def get_space(entries)
  entries.max_by(&:length).length + SPACE
end

def get_aligned_entries(row, entries)
  # 項目の数が規定列数以下の場合、横に出力してしまうのでそれを回避する
  if row < COLUMN
    entries.each_slice(1).to_a
  else
    row_aligned_entries = entries.each_slice(row).to_a
    row_aligned_entries.map! { |entries_col| entries_col.values_at(0...row) }.transpose
  end
end

def col_print(col, absolute_path, width)
  col.each do |element|
    next if element.nil?

    entry_path = absolute_path + element
    if File.symlink?(entry_path)
      print "#{element}@".ljust(width)
    elsif File.directory?(entry_path)
      print "#{element}/".ljust(width)
    else
      print element.ljust(width)
    end
  end
end

curdir_fullpath = "#{Dir.getwd}/"
curdir_entries = Dir.entries(curdir_fullpath).sort
hidden_removed_entries = curdir_entries.delete_if { |entry| entry.start_with?('.') }
row = (hidden_removed_entries.length.to_f / COLUMN).ceil
aligned_entries = get_aligned_entries(row, hidden_removed_entries)

col_width = get_space(curdir_entries)
aligned_entries.each do |entries_col|
  col_print(entries_col, curdir_fullpath, col_width)
  puts
end
