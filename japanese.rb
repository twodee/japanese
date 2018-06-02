#!/usr/bin/env ruby

require 'json'
require 'set'
require 'date'

class String
  def colorize(code)
    "\e[#{code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end
end

module Japanese
  @@json = File.read('vocabulary.json')
  @@vocabulary = JSON.parse(@@json)

  @@vocabulary.each do |category, words|
    words.each do |word|
      if word.has_key?('born')
        word['born'] = DateTime.parse(word['born'])
      end
    end
  end

  def self.allCategories
    @@vocabulary.values.flatten.map { |w| Word.new(w) }
  end

  def self.quiz(collection, n=-1)
    collection.shuffle.take(n == -1 ? collection.size : n).each do |item|
      print "#{item.definition}? "
      guess = STDIN.gets.chomp
      if item.matches(guess)
        puts "Right!"
      else
        puts "Wrong...\n Expected: #{item.kana}\n   Actual: #{guess}"
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

  def self.[] category
    @@vocabulary[category].map { |d| Word.new(d) }
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
    answer += hours[h - 1].kana
    if m > 10 && m % 10 == 0
      answer += ones[m / 10].kana + minutes[9].kana
    elsif m > 10
      answer += tens[m / 10 - 1].kana + minutes[(m - 1) % 10 + 1 - 1].kana
    elsif m > 0
      answer += minutes[m - 1].kana
    end
    answer
  end

  def self.aPartner(letter)
    if Set.new(%w{あ い う え お}).member?(letter)
      'あ'
    elsif Set.new(%w{か き く け こ}).member?(letter)
      'か'
    elsif Set.new(%w{さ し す せ そ}).member?(letter)
      'さ'
    elsif Set.new(%w{た ち つ て と}).member?(letter)
      'た'
    elsif Set.new(%w{な に ぬ ね の}).member?(letter)
      'な'
    elsif Set.new(%w{は ひ ふ へ ほ}).member?(letter)
      'は'
    elsif Set.new(%w{ま み む め も}).member?(letter)
      'ま'
    elsif Set.new(%w{ら り る れ ろ}).member?(letter)
      'ら'
    elsif Set.new(%w{が ぎ ぐ げ ご}).member?(letter)
      'が'
    elsif Set.new(%w{ざ じ ず ぜ ぞ}).member?(letter)
      'ざ'
    elsif Set.new(%w{だ ぢ づ で ど}).member?(letter)
      'だ'
    elsif Set.new(%w{ば び ぶ べ ぼ}).member?(letter)
      'ば'
    elsif Set.new(%w{ぱ ぴ ぷ ぺ ぽ}).member?(letter)
      'ぱ'
    else
      raise "I don\'t know the a-counterpart to #{letter}..."
    end 
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

  def self.ePartner(letter)
    if Set.new(%w{あ い う え お}).member?(letter)
      'え'
    elsif Set.new(%w{か き く け こ}).member?(letter)
      'け'
    elsif Set.new(%w{さ し す せ そ}).member?(letter)
      'せ'
    elsif Set.new(%w{た ち つ て と}).member?(letter)
      'て'
    elsif Set.new(%w{な に ぬ ね の}).member?(letter)
      'ね'
    elsif Set.new(%w{は ひ ふ へ ほ}).member?(letter)
      'へ'
    elsif Set.new(%w{ま み む め も}).member?(letter)
      'め'
    elsif Set.new(%w{ら り る れ ろ}).member?(letter)
      'れ'
    elsif Set.new(%w{が ぎ ぐ げ ご}).member?(letter)
      'げ'
    elsif Set.new(%w{ざ じ ず ぜ ぞ}).member?(letter)
      'ぜ'
    elsif Set.new(%w{だ ぢ づ で ど}).member?(letter)
      'で'
    elsif Set.new(%w{ば び ぶ べ ぼ}).member?(letter)
      'べ'
    elsif Set.new(%w{ぱ ぴ ぷ ぺ ぽ}).member?(letter)
      'ぺ'
    else
      raise "I don\'t know the e-counterpart to #{letter}..."
    end 
  end


  class Word
    attr_reader :kana, :definition

    def initialize d
      @properties = d
      @kana = d['kana']
      @definition = d['definition']
    end

    def isBornAfter date
      @properties.has_key?('born') && @properties['born'] >= date
    end

    def isBornBefore date
      @properties.has_key?('born') && @properties['born'] <= date
    end

    def matches(that)
      @properties.has_key?('kana') && @properties['kana'] == that
    end
  end

  class Verb < Word
    E_HIRAGANA = Set.new %w{え け せ て ね へ め れ げ ぜ べ ぺ で}
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
        kana[-1] == 'る' && (E_HIRAGANA.member?(kana[-2]) || I_HIRAGANA.member?(kana[-2]))
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

    def stem
      long[0..-3]
    end

    def tari
      "#{short(true, false)}り"
    end

    def want is_present, is_positive
      if is_present && is_positive
        prefix = 'want'
      elsif is_present && !is_positive
        prefix = 'don\'t want'
      elsif !is_present && is_positive
        prefix = 'wanted'
      else
        prefix = 'didn\'t want'
      end
      Adjective.new({
        'kana' => stem + 'たい',
        'definition' => "#{prefix} #{definition}"
      })
    end

    def potential
      p = {definition: "to be able #{definition}"}

      if @properties.has_key?('potential')
        p['kana'] = @properties['potential']
      elsif is_ru?
        p['kana'] = kana[0..-2] + 'られる'
      else
        p['kana'] = kana[0..-2] + Japanese.ePartner(kana[-1]) + 'る'
      end

      Verb.new(p)
    end

    def sugiru
      p = {
        'definition' => "#{definition} too much",
        'kana' => stem + "すぎる"
      }
      Verb.new(p)
    end

    def short(is_present=true, is_positive=true)
      if is_present
        if is_positive
          return kana
        else
          if @properties.has_key?('shortnegative')
            @properties['shortnegative']
          elsif @properties.has_key?('like')
            model = Japanese.verbs.find { |verb| verb.kana == @properties['like'] }
            kana.sub(/#{model.kana}$/, model.short(is_positive))
          elsif is_ru?
            kana[0..-2] + 'ない'
          elsif kana[-1] == 'う'
            kana[0..-2] + 'わない'
          else
            kana[0..-2] + Japanese.aPartner(kana[-1]) + 'ない'
          end
        end
      else
        if is_positive
          te.sub(/て$/, 'た').sub(/で$/, 'だ')
        else
          short(false, true)[0..-2] + 'かった'
        end
      end
    end

    def te
      if @properties.has_key?('te')
        @properties['te']

      # Verbs that behave like another.
      elsif @properties.has_key?('like')
        model = Japanese.verbs.find { |verb| verb.kana == @properties['like'] }
        kana.sub(/#{model.kana}$/, model.te)

      # ru verbs
      elsif is_ru?
        kana[0..-2] + 'て'

      # u verbs
      elsif %w{う つ る}.include?(kana[-1])
        kana[0..-2] + 'って'
      elsif %w{む ぶ ぬ}.include?(kana[-1])
        kana[0..-2] + 'んで'
      elsif kana[-1] == 'す'
        kana[0..-2] + 'して'
      elsif kana[-1] == 'く'
        kana[0..-2] + 'いて'
      elsif kana[-1] == 'ぐ'
        kana[0..-2] + 'いで'
      end
    end

    def infinitive
      if @properties.has_key?('infinitive')
        @properties['infinitive']
      elsif @properties.has_key?('like')
        model = Japanese.verbs.find { |verb| verb.kana == @properties['like'] }
        kana.sub(/#{model.kana}$/, model.infinitive)
      elsif is_ru?
        kana[0..-2]
      else
        kana[0..-2] + Japanese.iPartner(kana[-1])
      end
    end

    def long(is_present=true, is_positive=true)
      if is_present
        suffix = is_positive ? 'ます' : 'ません'
        infinitive + suffix
      else
        suffix = is_positive ? 'ました' : 'ませんでした'
        infinitive + suffix
      end
    end
  end

  class Adjective < Word
    def initialize d
      super(d)
      @properties = d
    end

    def is_i?
      kana.end_with?('い')
    end

    def is_na?
      kana.end_with?('な')
    end

    def sugiru
      p = {
        'definition' => "#{definition} too much",
        'kana' => kana[0..-2] + "すぎる"
      }
      Verb.new(p)
    end

    def virtual
      if @properties.has_key?('alternate')
        @properties['alternate']
      else
        kana
      end
    end

    def is(is_present=true, is_positive=true, is_long=true)
      suffix = ''
      if is_long
        if is_na? && !is_present && is_positive
          suffix = 'でした'
        else
          suffix = 'です'
        end
      else
        if is_na? && is_positive
          if is_present
            suffix = 'だ'
          else
            suffix = 'だった'
          end
        end
      end
      long(is_present, is_positive) + suffix
    end

    def long(is_present=true, is_positive=true)
      if is_present
        if is_i?
          if is_positive
            kana
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
      else
        if is_i?
          if is_positive
            virtual[0..-2] + 'かった'
          else
            virtual[0..-2] + 'くなかった'
          end
        else
          if is_positive
            virtual[0..-2]
          else
            virtual[0..-2] + 'じゃなかった'
          end
        end
      end
    end
  end
end
