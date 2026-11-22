# frozen_string_literal: true

module Mastermind
  module UI
    # Prompts the player for a 4-color code and validates color tokens.
    class CodePrompt
      ABORT_WORDS = %w[menu quit exit back].freeze

      def initialize(input: $stdin, output: $stdout, theme: Theme.new)
        @input = input
        @output = output
        @theme = theme
      end

      def ask(label:, hint: nil)
        @output.puts(@theme.muted(hint)) if hint
        loop do
          @output.print(@theme.accent("#{label}: "))
          raw = @input.gets
          return :abort if abort_requested?(raw)

          return Color.parse_sequence(raw)
        rescue InvalidCodeError => e
          @output.puts(@theme.danger("Invalid code: #{e.message}"))
        end
      end

      private

      def abort_requested?(raw)
        return true if raw.nil?

        ABORT_WORDS.include?(raw.strip.downcase)
      end
    end
  end
end
