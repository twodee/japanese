#!/usr/bin/env ruby

require 'json'
require 'set'

module Japanese
  @@json = File.read('vocabulary.json')
  @@vocabulary = JSON.parse(@@json)

  def self.quiz(collection)
    collection.shuffle.each do |item|
      print "#{item.definition}? "
      answer = gets.chomp
      if item.matches(answer)
        puts "Right!"
      else
        puts "Wrong..."
      end
      puts
    end
  end

  def self.verbs
    @@vocabulary['verbs'].map { |d| Verb.new(d) }
  end

  def self.adjectives
    @@vocabulary['adjectives'].map { |d| Adjective.new(d) }
  end

  def self.method_missing *args
    if args.length == 1 && @@vocabulary.has_key?(args[0].to_s) 
      @@vocabulary[args[0].to_s].map { |d| Word.new(d) }
    else
      super
    end
  end

  def self.time(h, m, isAM)
    answer = isAM ? 'ごぜん' : 'ごご'
    answer += hours[h - 1].hiragana
    if m > 10 && m % 10 == 0
      answer += ones[m / 10].hiragana + minutes[9].hiragana
    elsif m > 10
      answer += tens[m / 10 - 1].hiragana + minutes[(m - 1) % 10 + 1 - 1].hiragana
    elsif m > 0
      answer += minutes[m - 1].hiragana
    end
    answer
  end

  def self.iPartner(letter)
    if Set.new(%w{あ い う え お}).member?(letter)
      'い'
    elsif Set.new(%w{か き く け こ}).member?(letter)
      'き'
    elsif Set.new(%w{さ し す せ そ}).member?(letter)
      'し'
    elsif Set.new(%w{た ち つ て と}).member?(letter)
      'ち'
    elsif Set.new(%w{な に ぬ ね の}).member?(letter)
      'に'
    elsif Set.new(%w{は ひ ふ へ ほ}).member?(letter)
      'ひ'
    elsif Set.new(%w{ま み む め も}).member?(letter)
      'み'
    elsif Set.new(%w{ら り る れ ろ}).member?(letter)
      'り'
    elsif Set.new(%w{が ぎ ぐ げ ご}).member?(letter)
      'ぎ'
    elsif Set.new(%w{ざ じ ず ぜ ぞ}).member?(letter)
      'じ'
    elsif Set.new(%w{だ ぢ づ で ど}).member?(letter)
      'ぢ'
    elsif Set.new(%w{ば び ぶ べ ぼ}).member?(letter)
      'び'
    elsif Set.new(%w{ぱ ぴ ぷ ぺ ぽ}).member?(letter)
      'ぴ'
    else
      raise "I don\'t know the i-counterpart to #{letter}..."
    end 
  end

  class Word
    attr_reader :hiragana, :definition

    def initialize d
      @properties = d
      @hiragana = d['hiragana']
      @definition = d['definition']
    end

    def matches(that)
      (@properties.has_key?('hiragana') && @properties['hiragana'] == that) ||
      (@properties.has_key?('katakana') && @properties['katakana'] == that)
    end
  end

  class Verb < Word
    E_HIRAGANA = Set.new %w{え け せ て ね へ め れ げ ぜ べ ぺ}
    I_HIRAGANA = Set.new %w{い き し ち に ひ み り ぎ じ び ぴ}

    def initialize d
      super(d)
      @properties = d
    end

    # Same as ichidan.
    def is_ru?
      if @properties.has_key?('type')
        @properties['type'] == 'ru'
      else
        hiragana[-1] == 'る' && (E_HIRAGANA.member?(hiragana[-2]) || I_HIRAGANA.member?(hiragana[-2]))
      end
    end

    # Same as godan.
    def is_u?
      if @properties.has_key?('type')
        @properties['type'] == 'u'
      else
        !is_ru?
      end
    end

    def te
      # irregular verbs
      if hiragana.end_with? 'する'
        hiragana[0..-3] + 'して'
      elsif hiragana.end_with? 'くる'
        hiragana[0..-3] + 'きて'
      elsif hiragana == 'いく'
        hiragana[0..-3] + 'いって'

      # ru verbs
      elsif is_ru?
        hiragana[0..-2] + 'て'

      # u verbs
      elsif %w{う つ る}.include?(hiragana[-1])
        hiragana[0..-2] + 'って'
      elsif %w{む ぶ ぬ}.include?(hiragana[-1])
        hiragana[0..-2] + 'んで'
      elsif hiragana[-1] == 'す'
        hiragana[0..-2] + 'して'
      elsif hiragana[-1] == 'く'
        hiragana[0..-2] + 'いて'
      elsif hiragana[-1] == 'ぐ'
        hiragana[0..-2] + 'いで'
      end
    end

    def infinitive
      if @properties.has_key?('infinitive')
        @properties['infinitive']
      elsif is_ru?
        hiragana[0..-2]
      else
        hiragana[0..-2] + Japanese.iPartner(hiragana[-1])
      end
    end

    def present is_positive
      suffix = is_positive ? 'ます' : 'ません'
      infinitive + suffix
    end

    def past is_positive
      suffix = is_positive ? 'ました' : 'ませんでした'
      infinitive + suffix
    end
  end

  class Adjective < Word
    def initialize d
      super(d)
      @properties = d
    end

    def is_i?
      hiragana.end_with?('い')
    end

    def is_na?
      hiragana.end_with?('な')
    end

    def virtual
      if @properties.has_key?('alternate')
        @properties['alternate']
      else
        hiragana
      end
    end

    def present is_positive
      if is_i?
        if is_positive
          hiragana
        else
          virtual[0..-2] + 'くない'
        end
      else
        if is_positive
          virtual[0..-2]
        else
          virtual[0..-2] + 'じゃない'
        end
      end
    end

    def past is_positive
      if is_i?
        if is_positive
          virtual[0..-2] + 'かった'
        else
          virtual[0..-2] + 'くなかった'
        end
      else
        if is_positive
          virtual[0..-2] + 'なかった'
        else
          virtual[0..-2] + 'じゃなかった'
        end
      end
    end
  end
end
