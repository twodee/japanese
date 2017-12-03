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
end

module Japanese
  @@json = File.read('vocabulary.json')
  @@vocabulary = JSON.parse(@@json)

  def self.verbs
    @@vocabulary['verbs'].map { |d| Verb.new(d) }
  end
end
