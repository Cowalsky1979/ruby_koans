# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.


#!/usr/bin/env ruby
# encoding: utf-8

# Класс для бросков кубиков
class DiceSet
  attr_reader :values

  # Бросок number_of_dice кубиков (генерирует случайные числа от 1 до 6)
  def roll(number_of_dice)
    @values = Array.new(number_of_dice) { rand(1..6) }
  end
end

# Модуль для подсчёта очков по правилам игры Greed.
module ScoreCalculator
  module_function

  # Метод принимает массив значений кубиков и возвращает два значения:
  # - очки, набранные броском;
  # - количество кубиков, использованных для расчёта очков (scoring_dice_count).
  # Правила:
  #   • Тройка единиц => 1000 очков
  #   • Тройка x (2..6) => x * 100 очков
  #   • Каждая оставшаяся 1 => 100 очков
  #   • Каждая оставшаяся 5 => 50 очков
  def score(dice)
    counts = Hash.new(0)
    dice.each { |die| counts[die] += 1 }

    total = 0
    scoring_dice = 0

    # Обработка трёек
    counts.each do |num, count|
      if count >= 3
        if num == 1
          total += 1000
        else
          total += num * 100
        end
        scoring_dice += 3
        counts[num] -= 3
      end
    end

    # Обработка оставшихся 1 и 5
    if counts[1] && counts[1] > 0
      total += counts[1] * 100
      scoring_dice += counts[1]
    end
    if counts[5] && counts[5] > 0
      total += counts[5] * 50
      scoring_dice += counts[5]
    end

    return total, scoring_dice
  end
end

# Класс игрока
class Player
  attr_reader :name
  attr_accessor :total_score

  def initialize(name)
    @name = name
    @total_score = 0
    @in_game = false  # Игрок «не в игре», пока не наберёт не менее 300 очков за один ход
  end

  # Флаг "в игре"
  def in_game?
    @in_game
  end

  def enter_game!(turn_score)
    # Если за текущий ход набрано не менее 300 очков,
    # то игрок становится "в игре" и очки прибавляются.
    if turn_score >= 300
      @in_game = true
      @total_score += turn_score
    end
  end

  def add_turn_score(turn_score)
    @total_score += turn_score
  end
end

# Класс игры
class Game
  FINAL_SCORE = 3000

  def initialize(players)
    @players = players
    @final_round = false
    @final_round_counter = {}
  end

  def play
    puts "Добро пожаловать в игру Greed!"
    until game_over?
      @players.each do |player|
        next if final_round_finished?(player)
        puts "\nХод игрока #{player.name} (счёт: #{player.total_score})"
        turn_score = play_turn(player)
        if player.in_game?
          # Если игрок уже в игре, то просто прибавляем очки.
          if turn_score > 0
            player.add_turn_score(turn_score)
            puts "Вы завершили ход, заработав #{turn_score} очков. Ваш общий счёт: #{player.total_score}"
          else
            puts "Вы потеряли очки за этот ход."
          end
        else
          # Если игрок ещё не в игре, надо набрать минимум 300 очков за ход.
          if turn_score >= 300
            player.enter_game!(turn_score)
            puts "Поздравляем! Вы вошли в игру, заработав #{turn_score} очков."
          else
            puts "Недостаточно очков, чтобы войти в игру (необходимо 300). Очки за ход не засчитаны."
          end
        end

        # Если игрок достиг финального этапа, запускаем финальный раунд для остальных
        if player.total_score >= FINAL_SCORE && !@final_round
          puts "\nИгрок #{player.name} достиг #{FINAL_SCORE} очков. Финальный раунд начинается!"
          @final_round = true
          # Устанавливаем финальный раунд для остальных игроков
          @players.each do |p|
            @final_round_counter[p] = 1 unless p == player
          end
        elsif @final_round && @final_round_counter[player]
          @final_round_counter[player] -= 1
        end
      end
    end

    announce_winner
  end

  private

  # Определяет окончание игры:
  # Если игра находится в финальном раунде и у всех игроков, кроме лидера, закончились оставшиеся ходы.
  def game_over?
    return false unless @final_round
    @final_round_counter.values.all? { |turns| turns <= 0 }
  end

  # Проверка, завершён ли финальный ход для игрока
  def final_round_finished?(player)
    @final_round && @final_round_counter[player] && @final_round_counter[player] <= 0
  end

  # Игровой ход для одного игрока
  def play_turn(player)
    turn_score = 0
    dice_remaining = 5
    dice = DiceSet.new

    loop do
      puts "\nБросок #{dice_remaining} кубиков..."
      dice.roll(dice_remaining)
      roll = dice.values
      puts "Выпало: #{roll.join(', ')}"

      score, scoring_dice = ScoreCalculator.score(roll)
      if score == 0
        puts "Набрано 0 очков. Ход окончен, очки не учитываются!"
        turn_score = 0
        break
      else
        turn_score += score
        puts "Очки броска: #{score} (набрано за ход: #{turn_score})"
      end

      # Определение оставшихся кубиков для повторного броска.
      dice_remaining -= scoring_dice
      dice_remaining = 5 if dice_remaining == 0 # «Hot dice»: если все кубики использованы – бросаем заново все 5

      # Если ни один кубик не остался – завершаем ход
      if dice_remaining <= 0
        puts "Все кубики набрали очки. Вам предоставляется новый набор из 5 кубиков."
        dice_remaining = 5
      end

      # Запрос у игрока: продолжить бросок или завершить ход
      print "Завершить ход и зафиксировать очки? (y/n): "
      answer = gets.chomp.downcase
      if answer == "y" || answer == "yes"
        break
      end

      # Если игрок решает продолжить, следующий бросок производится с оставшимися кубиками
      puts "Продолжаем бросать #{dice_remaining} кубиков..."
    end

    turn_score
  end

  # Объявление победителя по общему счёту
  def announce_winner
    winner = @players.max_by { |player| player.total_score }
    puts "\nИгра окончена!"
    @players.each do |player|
      puts "#{player.name} набрал #{player.total_score} очков"
    end
    puts "\nПобедитель: #{winner.name} с #{winner.total_score} очками. Поздравляем!"
  end
end

# Основной запуск игры
if __FILE__ == $0
  puts "Введите имена игроков, разделив запятой (например: Alice,Bob):"
  input = gets.chomp
  player_names = input.split(',').map(&:strip)
  players = player_names.map { |name| Player.new(name) }

  game = Game.new(players)
  game.play
end
