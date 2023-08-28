require 'date'
require 'optparse'
require 'debug'

# コマンドライン引数を保存するための変数
opt = OptionParser.new
opt_params = { y: Date.today.year, m: Date.today.month }
# input = {}
# コマンドライン引数の入力を受け付ける
opt.on('-y VAL') { |v| v.to_i }
opt.on('-m VAL') { |v| v.to_i }
opt.parse!(ARGV, into: opt_params)

# コマンドラインからyオプションで入力された西暦が有効かどうか
if opt_params[:y] <= 2100 && opt_params[:y] >= 1970
  # 有効な値が入力されているため変数yearに代入
  year = opt_params[:y]
else
  # 無効な値が入力されているためカレンダーを出力しない
  puts '-yオプションに無効な数値が入力されました'
  return
end

# コマンドラインからmオプションで入力された月が有効かどうか
if opt_params[:m] >= 1 && opt_params[:m] <= 12
  # 有効な数値が入力されているため変数monthに代入
  month = opt_params[:m]
else
  # 無効な数値が入力されているためカレンダーを出力しない
  puts '-mオプションに無効な数値が入力されました'
  return
end

# 以下カレンダーーのタイトルと曜日の出力
puts("#{month}月 #{year}".center(20))
puts '日 月 火 水 木 金 土'
# eachメソッドの準備
first_date = Date.new(year.to_i, month.to_i, 1)
end_date = Date.new(year.to_i, month.to_i, -1)

# ブロックパラメータがfirst_dateの場合、開始の曜日の個数分出力を右にずらす
# １日が日曜日だと、第一週の出力がずれてしまうので日曜日かつ１日のケースをはじく
print '   ' * first_date.cwday if !first_date.sunday?

(first_date..end_date).each do |date|
  # 日付を出力する
  # 書式指定を行った上で左詰め
  print ('%2d' % date.day).to_s.ljust(3)
  # ブロックパラメータが土曜日の場合改行を入れる
  puts if date.saturday?
end
# 改行しないと末尾にプロンプト文字が出力される
puts
