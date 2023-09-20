# frozen_string_literal: true

# オプションなしのls
COLUMN = 3
curdir_fullpath = Dir.getwd
get_curdir_entries = Dir.children(curdir_fullpath)
# 隠しファイルを取り除く
hidden_removed_entries = get_curdir_entries.delete_if { |entry| entry.start_with?('.') }
# 出力用にエントリの中で一番名前の長いファイルの文字数を取っておく
longest_name_length = hidden_removed_entries.max_by(&:length).length + 3
# Array#transposeで要素数が3の配列を作るため、列(定数)を使ってまず行ごとにエントリを分割する
row = (hidden_removed_entries.length.to_f / COLUMN).ceil
row_aligned_entries = hidden_removed_entries.map.each_slice(row).to_a

# Array#transposeメソッドを使うには各要素の要素数を統一する必要がある
# 参照：https://patorash.hatenablog.com/entry/2021/03/17/163504
row_aligned_entries.map! { |entries_col| entries_col.values_at(0...row) }
# 縦に出力するため、行と列を入れ替える
col_aligned_entries = row_aligned_entries.transpose
# 出力
col_aligned_entries.each do |entries_col|
  entries_col.each do |entry|
    # values_atで作り出したnil?は無視する
    next if entry.nil?

    entry_path = curdir_fullpath + entry
    if File.symlink?(entry_path)
      print "#{entry}@".ljust(longest_name_length)
    elsif File.directory?(entry_path)
      print "#{entry}/".ljust(longest_name_length)
    else
      print entry.ljust(longest_name_length)
    end
  end
end
