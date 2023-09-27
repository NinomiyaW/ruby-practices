# frozen_string_literal: true

# オプションなしのls
COLUMN = 3
curdir_fullpath = "#{Dir.getwd}/"
# オプションなしの場合アルファベット順にファイルが並ぶ
get_curdir_entries = Dir.entries(curdir_fullpath).sort
# 隠しファイルを取り除く
hidden_removed_entries = get_curdir_entries.delete_if { |entry| entry.start_with?('.') }
# 出力用にエントリの中で一番名前の長いファイルの文字数を取っておく
longest_name_length = hidden_removed_entries.max_by(&:length).length + 3
# Array#transposeで要素数が3の配列を作るため、列(定数)を使ってまず行ごとにエントリを分割する
row = (hidden_removed_entries.length.to_f / COLUMN).ceil

col_aligned_entries =
  # 行数が列数以下の場合、1個ずつ分割する(13行目で切り上げた値がファイルの項目数を超えるため)
  if row < COLUMN
    hidden_removed_entries.each_slice(1).to_a
  else
    row_aligned_entries = hidden_removed_entries.each_slice(row).to_a
    # Array#transposeメソッドを使うには各要素の要素数を統一する必要がある
    # 参照：https://patorash.hatenablog.com/entry/2021/03/17/163504
    row_aligned_entries.map! { |entries_col| entries_col.values_at(0...row) }.transpose
  end

# 出力
col_aligned_entries.each do |entries_col|
  entries_col.each do |entry|
    # values_atで作り出したnil?は無視
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
  puts
end
