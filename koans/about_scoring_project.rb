require File.expand_path(File.dirname(__FILE__) + '/neo')

def score(dice)
  total = 0
  counts = Hash.new(0)
  dice.each { |die| counts[die] += 1 }

  # Обработка троек единиц
  if counts[1] >= 3
    total += 1000
    counts[1] -= 3
  end
  # Добавляем очки за оставшиеся единицы
  total += counts[1] * 100

  # Обработка троек для чисел от 2 до 6
  (2..6).each do |num|
    if counts[num] >= 3
      total += num * 100
      counts[num] -= 3
    end
  end

  # Добавляем очки за оставшиеся пятёрки
  total += counts[5] * 50

  total
end

class AboutScoringProject < Neo::Koan
  def test_score_of_an_empty_list_is_zero
    assert_equal 0, score([])
  end

  def test_score_of_a_single_roll_of_5_is_50
    assert_equal 50, score([5])
  end

  def test_score_of_a_single_roll_of_1_is_100
    assert_equal 100, score([1])
  end

  def test_score_of_multiple_1s_and_5s_is_the_sum_of_individual_scores
    assert_equal 300, score([1,5,5,1])
  end

  def test_score_of_single_2s_3s_4s_and_6s_are_zero
    assert_equal 0, score([2,3,4,6])
  end

  def test_score_of_a_triple_1_is_1000
    assert_equal 1000, score([1,1,1])
  end

  def test_score_of_other_triples_is_100x
    assert_equal 200, score([2,2,2])
    assert_equal 300, score([3,3,3])
    assert_equal 400, score([4,4,4])
    assert_equal 500, score([5,5,5])
    assert_equal 600, score([6,6,6])
  end

  def test_score_of_mixed_is_sum
    assert_equal 250, score([2,5,2,2,3])
    assert_equal 550, score([5,5,5,5])
    assert_equal 1100, score([1,1,1,1])
    assert_equal 1200, score([1,1,1,1,1])
    assert_equal 1150, score([1,1,1,5,1])
  end
end
