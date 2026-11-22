# frozen_string_literal: true

module Mastermind
  # Tracks the secret code, turn history, and win/loss state for a game.
  class GameSession
    DEFAULT_MAX_TURNS = 12

    attr_reader :secret, :max_turns, :turns, :role

    def initialize(secret:, role:, max_turns: DEFAULT_MAX_TURNS)
      @secret = secret.freeze
      @role = role
      @max_turns = max_turns
      @turns = []
    end

    def submit_guess(guess, remaining_candidates: nil)
      feedback = Feedback.evaluate(@secret, guess)
      turn = Turn.new(
        number: current_turn_number,
        guess: guess.freeze,
        feedback:,
        remaining_candidates:
      )
      @turns << turn
      turn
    end

    def won? = @turns.any? { it.feedback.won? }

    def over? = won? || turns_left.zero?

    def turns_left = [@max_turns - @turns.length, 0].max

    def current_turn_number = @turns.length + 1
  end
end
