# frozen_string_literal: true

# Root namespace for the Mastermind CLI game.
module Mastermind
  # Immutable evaluation of a guess against a secret code.
  Feedback = Data.define(:exact, :misplaced, :code_length) do
    def won? = exact == code_length

    def misses = code_length - exact - misplaced
  end

  class << Feedback
    def evaluate(secret, guess)
      exact = secret.zip(guess).count { |secret_peg, guess_peg| secret_peg == guess_peg }
      total = color_overlap(secret, guess)
      new(exact:, misplaced: total - exact, code_length: secret.length)
    end

    private

    def color_overlap(secret, guess)
      secret_counts = secret.tally
      guess_counts = guess.tally
      secret_counts.sum { |color, count| [count, guess_counts.fetch(color, 0)].min }
    end
  end
end
