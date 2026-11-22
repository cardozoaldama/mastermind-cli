# frozen_string_literal: true

module Mastermind
  # Immutable record of a single Mastermind turn and its feedback.
  Turn = Data.define(:number, :guess, :feedback, :remaining_candidates)
end
