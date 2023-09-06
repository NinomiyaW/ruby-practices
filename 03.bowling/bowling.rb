# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
MAX_POINT = 10
# オプションから入力したスコアを計算できる形にする
scores.each do |s|
  if %w[x X].include?(s)
    shots << MAX_POINT
    shots << 0
  else
    shots << s.to_i
  end
end
# フレームごとに点を分割する
frames = shots.each_slice(2).to_a

# 点数を計算する
point = 0
frames.each_with_index do |frame, count|
  point += frame.sum
  next if count >= 9 || frame.sum != 10

  # ストライクまたはスペアの場合の計算
  point +=
    if frame[0] == MAX_POINT
      if frames[count + 1][0] == MAX_POINT
        (MAX_POINT + frames[count + 2][0])
      else
        frames[count + 1].sum
      end
    else
      (frames[count + 1][0])
    end
end

puts point
