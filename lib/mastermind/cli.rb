# frozen_string_literal: true

module Mastermind
  # Coordinates the Mastermind CLI menus, role selection, and game loops.
  class CLI
    MAIN_MENU = UI::Menu::Config.new(
      title: 'Main Menu',
      subtitle: 'Crack the 4-color secret code in 12 turns.',
      options: [
        UI::Menu::Option.new(:new_game, 'New Game', 'Choose Mastermind vs Guesser and start playing'),
        UI::Menu::Option.new(:quit, 'Quit', 'Exit Mastermind CLI')
      ].freeze
    )

    ROLE_MENU = UI::Menu::Config.new(
      title: 'Choose Your Role',
      subtitle: 'Select who creates the secret code and who guesses.',
      options: [
        UI::Menu::Option.new(:human_guesser, 'CPU is Mastermind (You Guess)', 'Crack a hard randomized code'),
        UI::Menu::Option.new(:cpu_guesser, 'You are Mastermind (CPU Guesses)', 'Set a secret code for CPU'),
        UI::Menu::Option.new(:back, 'Back to Main Menu', 'Return without starting a game')
      ].freeze
    )

    def initialize(input: $stdin, output: $stdout, theme: UI::Theme.new)
      @input = input
      @output = output
      @theme = theme
      @board = UI::BoardRenderer.new(output:, theme:)
      @prompt = UI::CodePrompt.new(input:, output:, theme:)
    end

    def run
      loop do
        choice = build_menu(MAIN_MENU).select
        break if choice.nil? || choice == :quit

        start_selected_mode if choice == :new_game
      end
      @output.puts(@theme.muted('Thanks for playing Mastermind. Goodbye!'))
    rescue Interrupt
      @output.puts("\n#{@theme.muted('Goodbye!')}")
    end

    private

    def build_menu(config) = UI::Menu.new(config:, input: @input, output: @output, theme: @theme)

    def start_selected_mode
      role = build_menu(ROLE_MENU).select
      return if role.nil? || role == :back

      role == :human_guesser ? play_human_guesser : play_cpu_guesser
    end

    def play_human_guesser
      session = GameSession.new(secret: CodeGenerator.generate, role: :human_guesser)
      return if run_human_turns(session) == :aborted

      @board.render_result(session)
      wait_for_enter
    end

    def run_human_turns(session)
      until session.over?
        @board.render(session)
        label = "Turn #{session.current_turn_number}/#{session.max_turns} guess"
        guess = @prompt.ask(label:, hint: "Enter 4 colors (e.g. R G Y C, rgyc, or color names) or 'menu'.")
        return :aborted if guess == :abort

        session.submit_guess(guess)
      end
      :completed
    end

    def play_cpu_guesser
      secret = prompt_human_secret
      return if secret == :abort

      session = GameSession.new(secret:, role: :cpu_guesser)
      return if run_cpu_turns(session, CpuGuesser.new) == :aborted

      @board.render_result(session)
      wait_for_enter
    end

    def prompt_human_secret
      @theme.clear_screen(@output)
      @output.puts(@theme.title('=== MASTERMIND: SET YOUR SECRET CODE ==='))
      @output.puts(@theme.muted("Available colors: #{Color.all.map { @theme.swatch(it) }.join('  ')}"))
      @output.puts
      hint = "Enter 4 colors (e.g. R G Y M or rgym), or type 'menu' to cancel."
      @prompt.ask(label: 'Your 4-color secret code', hint:)
    end

    def run_cpu_turns(session, guesser)
      until session.over?
        advance_cpu_turn(session, guesser)
        @board.render(session)
        break if session.over?
        return :aborted unless continue_cpu_turns?
      end
      :completed
    end

    def advance_cpu_turn(session, guesser)
      guess = guesser.next_guess
      feedback = Feedback.evaluate(session.secret, guess)
      guesser.record_feedback(guess, feedback)
      session.submit_guess(guess, remaining_candidates: guesser.remaining_count)
    end

    def continue_cpu_turns?
      @output.print(@theme.muted("Press Enter for CPU's next guess (or type 'menu')... "))
      line = @input.gets
      !line.nil? && line.strip.downcase != 'menu'
    end

    def wait_for_enter
      @output.print(@theme.muted('Press Enter to return to the Main Menu... '))
      @input.gets
    end
  end
end
