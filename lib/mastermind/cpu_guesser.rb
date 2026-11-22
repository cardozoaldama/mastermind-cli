# frozen_string_literal: true

require 'securerandom'

module Mastermind
  # Solves a secret code via constraint filtering over remaining candidates.
  class CpuGuesser
    def initialize(palette: Color.all, code_length: Color::CODE_LENGTH, rng: SecureRandom)
      @palette = palette
      @code_length = code_length
      @rng = rng
      @candidates = palette.repeated_permutation(code_length).to_a
      @first_turn = true
    end

    def remaining_count = @candidates.length

    def next_guess
      return opening_guess if @first_turn

      @candidates.sample(random: @rng)
    end

    def record_feedback(guess, feedback)
      @candidates.select! { |code| Feedback.evaluate(code, guess) == feedback }
    end

    private

    def opening_guess
      @first_turn = false
      first, second = @palette.sample(2, random: @rng)
      half = @code_length / 2
      ([first] * half) + ([second] * (@code_length - half))
    end
  end
end
