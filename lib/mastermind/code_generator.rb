# frozen_string_literal: true

require 'securerandom'

module Mastermind
  # Generates hard-to-guess secret codes using SecureRandom.
  class CodeGenerator
    def self.generate(palette: Color.all, code_length: Color::CODE_LENGTH, rng: SecureRandom)
      new(palette:, code_length:, rng:).generate
    end

    def initialize(palette: Color.all, code_length: Color::CODE_LENGTH, rng: SecureRandom)
      @palette = palette
      @code_length = code_length
      @rng = rng
    end

    def generate
      roll = @rng.random_number(100)
      return repeated_pair if roll < 45
      return double_pair if roll < 65

      shuffled_distinct
    end

    private

    def repeated_pair
      chosen = @palette.sample(@code_length - 1, random: @rng)
      duplicate = chosen.sample(random: @rng)
      (chosen + [duplicate]).shuffle(random: @rng)
    end

    def double_pair
      pair_count = (@code_length / 2.0).ceil
      chosen = @palette.sample(pair_count, random: @rng)
      (chosen * 2).first(@code_length).shuffle(random: @rng)
    end

    def shuffled_distinct
      loop do
        candidate = @palette.sample(@code_length, random: @rng).shuffle(random: @rng)
        return candidate unless trivial_run?(candidate)
      end
    end

    def trivial_run?(candidate)
      @palette.each_cons(@code_length).any? do |slice|
        candidate == slice || candidate == slice.reverse
      end
    end
  end
end
