# frozen_string_literal: true

# Root namespace for the Mastermind CLI game.
module Mastermind
  # Raised when a player enters an invalid color code sequence.
  class InvalidCodeError < StandardError; end

  # Represents a playable high-contrast peg color.
  Color = Data.define(:key, :name, :code, :ansi)

  Color::CODE_LENGTH = 4

  Color::PALETTE = [
    Color.new(key: :red, name: 'Red', code: 'R', ansi: "\e[1;91m"),
    Color.new(key: :green, name: 'Green', code: 'G', ansi: "\e[1;92m"),
    Color.new(key: :yellow, name: 'Yellow', code: 'Y', ansi: "\e[1;93m"),
    Color.new(key: :cyan, name: 'Cyan', code: 'C', ansi: "\e[1;96m"),
    Color.new(key: :magenta, name: 'Magenta', code: 'M', ansi: "\e[1;95m"),
    Color.new(key: :white, name: 'White', code: 'W', ansi: "\e[1;97m")
  ].freeze

  Color::LOOKUP = Color::PALETTE.each_with_object({}) do |color, index|
    index[color.code.downcase] = color
    index[color.name.downcase] = color
  end.freeze

  class << Color
    def all = Color::PALETTE

    def parse_sequence(raw_input, length: Color::CODE_LENGTH)
      tokens = tokenize(raw_input.to_s.strip, length:)
      validate_length!(tokens, length)
      tokens.map { |token| find_color!(token) }
    end

    private

    def tokenize(text, length:)
      raise InvalidCodeError, "Enter #{length} colors (e.g. R G Y C or rgyc)." if text.empty?

      parts = text.split(/[\s,]+/)
      return parts.first.chars if parts.one? && parts.first.length == length

      parts
    end

    def validate_length!(tokens, length)
      return if tokens.length == length

      raise InvalidCodeError, "Expected #{length} colors, got #{tokens.length}."
    end

    def find_color!(token)
      Color::LOOKUP.fetch(token.downcase) do
        valid = Color::PALETTE.map(&:code).join(', ')
        raise InvalidCodeError, "Unknown color '#{token}'. Use: #{valid}."
      end
    end
  end
end
