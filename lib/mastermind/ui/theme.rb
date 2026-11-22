# frozen_string_literal: true

module Mastermind
  module UI
    # Dark-mode-compatible ANSI color formatter with NO_COLOR support.
    class Theme
      RESET = "\e[0m"

      def initialize(color: ENV.fetch('NO_COLOR', '').empty?)
        @color = color
      end

      def color? = @color
      def title(text) = apply("\e[1;96m", text)
      def accent(text) = apply("\e[96m", text)
      def highlight(text) = apply("\e[1;97m", text)
      def muted(text) = apply("\e[37m", text)
      def success(text) = apply("\e[1;92m", text)
      def warning(text) = apply("\e[1;93m", text)
      def danger(text) = apply("\e[1;91m", text)
      def selected_option(text) = apply("\e[1;30;106m", " #{text} ")

      def peg(color)
        return "[#{color.code}]" unless @color

        "#{color.ansi}● #{color.code}#{RESET}"
      end

      def hidden_peg
        return '[?]' unless @color

        muted('● ?')
      end

      def swatch(color)
        label = "(#{color.code})#{color.name[1..]}"
        return label unless @color

        "#{color.ansi}● #{label}#{RESET}"
      end

      def feedback_pegs(feedback)
        build_feedback_tokens(feedback).join(' ')
      end

      def clear_screen(output)
        output.print("\e[2J\e[H") if output.tty?
      end

      private

      def apply(ansi, text)
        return text.to_s unless @color

        "#{ansi}#{text}#{RESET}"
      end

      def build_feedback_tokens(feedback)
        exact_icon = @color ? success('●') : '+'
        misplaced_icon = @color ? warning('◐') : '~'
        miss_icon = @color ? muted('·') : '.'

        Array.new(feedback.exact, exact_icon) +
          Array.new(feedback.misplaced, misplaced_icon) +
          Array.new(feedback.misses, miss_icon)
      end
    end
  end
end
