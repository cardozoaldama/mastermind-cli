# frozen_string_literal: true

require 'io/console'

module Mastermind
  module UI
    # Interactive CLI menu supporting arrow keys and number selection.
    class Menu
      Option = Data.define(:value, :label, :description)
      Config = Data.define(:title, :subtitle, :options)

      def initialize(config:, input: $stdin, output: $stdout, theme: Theme.new)
        @title = config.title
        @subtitle = config.subtitle
        @options = config.options
        @input = input
        @output = output
        @theme = theme
      end

      def select
        return select_line unless @input.tty?

        select_interactive
      end

      private

      def select_interactive
        @output.print("\e[?25l")
        run_interactive_loop
      ensure
        @output.print("\e[?25h")
      end

      def run_interactive_loop
        index = 0
        loop do
          render(index)
          action, payload = read_key
          return @options[index].value if action == :enter
          return payload if action == :number

          index = next_index(index, action)
        end
      end

      def next_index(index, action)
        case action
        when :up then (index - 1) % @options.length
        when :down then (index + 1) % @options.length
        else index
        end
      end

      def read_key
        @input.raw do |io|
          char = io.getc
          raise Interrupt if char.nil? || char == "\u0003"
          return [:enter, nil] if ["\r", "\n"].include?(char)
          return [parse_escape(io), nil] if char == "\e"

          number_action(char)
        end
      end

      def parse_escape(io)
        return :noop unless io.wait_readable(0.05)

        sequence = io.getc.to_s + io.getc.to_s
        return :up if ['[A', 'OA'].include?(sequence)
        return :down if ['[B', 'OB'].include?(sequence)

        :noop
      end

      def number_action(char)
        return [:noop, nil] unless char.match?(/\A[1-9]\z/)

        idx = char.to_i - 1
        return [:noop, nil] unless idx < @options.length

        [:number, @options[idx].value]
      end

      def select_line
        render(0)
        loop do
          @output.print(@theme.accent("Select option (1-#{@options.length}): "))
          line = @input.gets
          return nil if line.nil?

          choice = match_line_choice(line.strip)
          return choice unless choice.nil?

          @output.puts(@theme.danger("Invalid choice. Enter 1-#{@options.length}."))
        end
      end

      def match_line_choice(text)
        return nil unless text.match?(/\A[1-9]\z/)

        idx = text.to_i - 1
        return nil unless idx < @options.length

        @options[idx].value
      end

      def render(selected_index)
        @theme.clear_screen(@output)
        @output.puts(@theme.title('=== MASTERMIND ==='))
        @output.puts(@theme.highlight(@title))
        @output.puts(@theme.muted(@subtitle)) unless @subtitle.to_s.empty?
        @output.puts
        @options.each_with_index { |option, idx| render_option(option, idx, idx == selected_index) }
        @output.puts
        @output.puts(@theme.muted("Use ↑/↓ arrows + Enter, or press 1-#{@options.length}."))
      end

      def render_option(option, idx, selected)
        text = "#{selected ? '❯' : ' '} #{idx + 1}. #{option.label}"
        @output.puts(selected ? @theme.selected_option(text) : @theme.highlight(" #{text}"))
        return if option.description.to_s.empty?

        desc = "      #{option.description}"
        @output.puts(selected ? @theme.accent(desc) : @theme.muted(desc))
      end
    end
  end
end
