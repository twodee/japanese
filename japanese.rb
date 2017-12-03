#!/usr/bin/env ruby

require 'json'
require 'set'

class Verb
  attr_reader :hiragana, :definition

  E_HIRAGANA = Set.new %w{え け せ て ね へ め れ げ ぜ べ ぺ}
  I_HIRAGANA = Set.new %w{い き し ち に ひ み り ぎ じ び ぴ}

  def initialize d
    @properties = d
    @hiragana = d['hiragana']
    @definition = d['definition']
  end

  def is_ru?
    (@properties.has_key?('type') && @properties['type'] == 'ru') ||
    (hiragana[-1] == 'る' && (E_HIRAGANA.member?(hiragana[-2]) || I_HIRAGANA.member?(hiragana[-2])))
  end

  def is_u?
    (@properties.has_key?('type') && @properties['type'] == 'u') || !is_ru?
  end
end

module Japanese
  @@json = File.read('vocabulary.json')
  @@vocabulary = JSON.parse(@@json)

  def self.verbs
    @@vocabulary['verbs'].map { |d| Verb.new(d) }
  end
end
