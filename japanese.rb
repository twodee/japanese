#!/usr/bin/env ruby

require 'json'
require 'set'

module Japanese
  @@json = File.read('vocabulary.json')
  @@vocabulary = JSON.parse(@@json)

  def self.verbs
    @@vocabulary['verbs'].map { |d| Verb.new(d) }
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

  class Verb
    attr_reader :hiragana, :definition

    E_HIRAGANA = Set.new %w{え け せ て ね へ め れ げ ぜ べ ぺ}
    I_HIRAGANA = Set.new %w{い き し ち に ひ み り ぎ じ び ぴ}

    def initialize d
      @properties = d
      @hiragana = d['hiragana']
      @definition = d['definition']
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
      if @hiragana.end_with? 'する'
        'して'
      elsif @hiragana.end_with? 'くる'
        'きって'
      elsif @hiragana == 'いく'
        'いって'

      # ru verbs
      elsif is_ru?
        @hiragana[0..-2] + 'て'

      # u verbs
      elsif %w{う つ る}.include?(@hiragana[-1])
        @hiragana[0..-2] + 'って'
      elsif %w{む ぶ ぬ}.include?(@hiragana[-1])
        @hiragana[0..-2] + 'んで'
      elsif @hiragana[-1] == 'す'
        @hiragana[0..-2] + 'して'
      elsif @hiragana[-1] == 'く'
        @hiragana[0..-2] + 'いて'
      elsif @hiragana[-1] == 'ぐ'
        @hiragana[0..-2] + 'いで'
      end
    end

    def infinitive
      if @properties.has_key?('infinitive')
        @properties['infinitive']
      elsif is_ru?
        @hiragana[0..-2]
      else
        @hiragana[0..-2] + Japanese.iPartner(@hiragana[-1])
      end
    end

    def present is_positive
      suffix = is_positive ? 'ます' : 'ません'
      infinitive + suffix
    end
  end
end
