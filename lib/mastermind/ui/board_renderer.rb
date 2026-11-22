# frozen_string_literal: true

module Mastermind
  module UI
    # Renders the dark-mode Mastermind board, legend, turns, and outcome.
    class BoardRenderer
      DIVIDER = '─' * 64

      def initialize(output: $stdout, theme: Theme.new)
        @output = output
        @theme = theme
      end

      def render(session)
        @theme.clear_screen(@output)
        render_header(session)
        render_secret(session)
        render_legend
        render_turns(session)
      end

      def render_result(session)
        render(session)
        @output.puts
        @output.puts(outcome_message(session))
      end

      private

      def render_header(session)
        @output.puts(@theme.title('=== MASTERMIND ==='))
        mode = role_label(session.role)
        turn_info = "Turns used: #{session.turns.length}/#{session.max_turns} | Remaining: #{session.turns_left}"
        @output.puts("#{@theme.highlight(mode)}  #{@theme.muted(turn_info)}")
        @output.puts
      end

      def role_label(role)
        role == :human_guesser ? 'CPU is Mastermind (You Guess)' : 'You are Mastermind (CPU Guesses)'
      end

      def render_secret(session)
        reveal = session.role == :cpu_guesser || session.over?
        pegs = if reveal
                 session.secret.map { @theme.peg(it) }.join('  ')
               else
                 Array.new(session.secret.length, @theme.hidden_peg).join('  ')
               end
        @output.puts("#{@theme.highlight('Secret Code:')} #{pegs}")
      end

      def render_legend
        swatches = Color.all.map { @theme.swatch(it) }.join('  ')
        @output.puts("#{@theme.muted('Colors:     ')} #{swatches}")
        @output.puts("#{@theme.muted('Feedback:   ')} #{feedback_key}")
      end

      def feedback_key
        if @theme.color?
          "#{@theme.success('●')} Exact  #{@theme.warning('◐')} Misplaced  #{@theme.muted('·')} Miss"
        else
          '+ Exact  ~ Misplaced  . Miss'
        end
      end

      def render_turns(session)
        @output.puts(@theme.muted(DIVIDER))
        if session.turns.empty?
          @output.puts(@theme.muted('No guesses yet.'))
        else
          session.turns.each { |turn| render_turn(turn, session.role) }
        end
        @output.puts(@theme.muted(DIVIDER))
      end

      def render_turn(turn, role)
        num = format('%02d', turn.number)
        pegs = turn.guess.map { @theme.peg(it) }.join('  ')
        fb = @theme.feedback_pegs(turn.feedback)
        details = turn_details(turn, role)
        @output.puts("#{num} │ #{pegs} │ #{fb}  #{@theme.muted(details)}")
      end

      def turn_details(turn, role)
        base = "(#{turn.feedback.exact} exact, #{turn.feedback.misplaced} misplaced)"
        return base unless role == :cpu_guesser && turn.remaining_candidates

        "#{base} | #{turn.remaining_candidates} possibilities left"
      end

      def outcome_message(session)
        if session.role == :human_guesser
          human_outcome(session)
        else
          cpu_outcome(session)
        end
      end

      def human_outcome(session)
        return @theme.success("You cracked the code in #{session.turns.length} turns!") if session.won?

        @theme.danger('Out of turns! The CPU Mastermind protected the secret code.')
      end

      def cpu_outcome(session)
        return @theme.warning("CPU cracked your code in #{session.turns.length} turns!") if session.won?

        @theme.success('CPU ran out of turns! Your secret code stumped the solver.')
      end
    end
  end
end
