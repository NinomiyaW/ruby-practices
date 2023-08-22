require 'date'
require 'optparse'

# コマンドライン引数を保存するための変数
opt = OptionParser.new
opt_params = {}
month = Date.today.month
year = Date.today.year
opt.on('-y VAL') {|v|v.to_i }
opt.on('-m VAL') {|v|v.to_i }
opt.parse!(ARGV, into:opt_params)

if opt_params.any?
  if !opt_params[:y].nil?
    if opt_params[:y] <= 2100 && opt_params[:y] >=1970
    year = opt_params[:y]
    else
      puts "-yオプションに無効な数値が入力されました"
      return
    end
  end
  # コマンドラインからmオプションで入力された月が有効かどうか
  if !opt_params[:m].nil?
    if opt_params[:m] >= 1 && opt_params[:m] <=12
      month = opt_params[:m]
    else
      puts "-mオプションに無効な数値が入力されました"
      return
    end
  elsif opt_params[:m].nil?
    puts "-mオプションの入力は必須です"
    return
  end
end

# コマンドライン引数がない場合
puts (month.to_s + "月 " + year.to_s).center(20)
puts "日 月 火 水 木 金 土"
first_date = Date.new(year.to_i, month.to_i, 1)
end_date = Date.new(year.to_i,month.to_i, -1)

(first_date..end_date).each{ |date|
  # ブロックパラメータがfirst_dateの場合、開始の曜日の個数分出力を右にずらす
  # １日が日曜日だと、第一週の出力がずれてしまう
  if date.day == 1 && !date.sunday?
    print  "   " * (date.cwday)
  end
  print sprintf("%2d", date.day).ljust(3)
  if date.saturday?
    puts ""
  end
}
# 改行しないと末尾にプロンプト文字が出力される
puts ""



