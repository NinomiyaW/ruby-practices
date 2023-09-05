# frozen_string_literal: true

require 'debug'

# class Array
#   def strike?
#     self[0] == 10
#   end

#   def spare?
#     sum == 10
#   end
# end

score = ARGV[0]
scores = score.split(',')
shots = []

# オプションから入力したスコアを計算できる形にする
scores.each do |s|
  if %w[x X].include?(s)
    shots << 10
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
  # binding.break
  if count >= 9
    point += frame.sum
    next
  end

  point +=
    if frame[0] == 10
      if frames[count + 1][0] == 10
        (20 + frames[count + 2][0])
      else
        (10 + frames[count + 1].sum)
      end

    elsif frame.sum == 10
      (10 + frames[count + 1][0])
    else
      frame.sum
    end
end

puts point
