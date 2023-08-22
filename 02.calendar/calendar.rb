require 'date'
require 'optparse'

# コマンドライン引数を保存するための変数
opt = OptionParser.new
opt_params = {}
month = Date.today.month
year = Date.today.year
# コマンドライン引数の入力を受け付ける
opt.on('-y VAL') {|v|v.to_i }
opt.on('-m VAL') {|v|v.to_i }
opt.parse!(ARGV, into:opt_params)

# コマンドライン引数が入力されていた場合の処理
if opt_params.any?
  # コマンドラインからyオプションで入力された西暦が有効かどうか
  if !opt_params[:y].nil?
    if opt_params[:y] <= 2100 && opt_params[:y] >=1970
      # 有効な値が入力されているため変数yearに代入
       year = opt_params[:y]
    else
      # 無効な値が入力されているためカレンダーを出力しない
      puts "-yオプションに無効な数値が入力されました"
      return
    end
  end
  # コマンドラインからmオプションで入力された月が有効かどうか
  if !opt_params[:m].nil?
    if opt_params[:m] >= 1 && opt_params[:m] <=12
      # 有効な数値が入力されているため変数monthに代入
      month = opt_params[:m]
    else
      # 無効な数値が入力されているためカレンダーを出力しない
      puts "-mオプションに無効な数値が入力されました"
      return
    end

  else
    # -yオプションが指定されているのに-mオプションが指定されていない場合、カレンダーを出力しない
    puts "-yオプションを指定するとき、-mオプションの入力は必須です"
    return
  end
end

# 以下カレンダーーのタイトルと曜日の出力
puts (month.to_s + "月 " + year.to_s).center(20)
puts "日 月 火 水 木 金 土"
# eachメソッドの準備
first_date = Date.new(year.to_i, month.to_i, 1)
end_date = Date.new(year.to_i,month.to_i, -1)

(first_date..end_date).each{ |date|
  # ブロックパラメータがfirst_dateの場合、開始の曜日の個数分出力を右にずらす
  # １日が日曜日だと、第一週の出力がずれてしまうので日曜日かつ１日のケースをはじく
  if date.day == 1 && !date.sunday?
    print  "   " * (date.cwday)
  end
  # 日付を出力する
  print sprintf("%2d", date.day).ljust(3)
  # ブロックパラメータが土曜日の場合改行を入れる
  if date.saturday?
    puts ""
  end
}
# 改行しないと末尾にプロンプト文字が出力される
puts ""
