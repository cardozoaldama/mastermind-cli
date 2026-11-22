# Mastermind CLI

A dark-mode-accessible terminal Mastermind game written in Ruby 3.4.13.

## Features

- **Dark-mode color palette**: Uses bright, high-contrast ANSI colors (`Red`, `Green`, `Yellow`, `Cyan`, `Magenta`, `White`) designed for dark terminal themes, with automatic [`NO_COLOR`](https://no-color.org/) fallback.
- **Interactive menus**: Navigate the Main Menu and role selection using `↑`/`↓` arrow keys + `Enter`, or press a number (`1`–`3`). Works seamlessly with piped input too.
- **Two game roles**:
  - **CPU is Mastermind (You Guess)**: `SecureRandom` generates hard-to-guess 4-color codes (including repeated-pair and double-pair patterns, while filtering trivial runs).
  - **You are Mastermind (CPU Guesses)**: Set your own 4-color secret code and watch a constraint-filtering solver narrow down the remaining 1,296 possibilities turn by turn.
- **Clear turn-by-turn feedback**: Displays exact matches, misplaced matches, and misses on every turn.

## Prerequisites

- Ruby `3.4.13` (pinned via `.ruby-version` / `rbenv local 3.4.13`)
- Bundler

## Quick Start

```bash
bundle install
bundle exec bin/mastermind
```

## Color Legend & Input Formats

Playable colors (no numbers required for codes):

| Code | Color |
| :--- | :--- |
| `R` | Red |
| `G` | Green |
| `Y` | Yellow |
| `C` | Cyan |
| `M` | Magenta |
| `W` | White |

You can enter 4-color sequences in any of these formats (case-insensitive):

- Space-separated initials: `R G Y C`
- Compact initials: `rgyc`
- Comma-separated or full names: `red, green, yellow, cyan`

Type `menu` (or `quit` / `back` / `exit`) at any code prompt to return to the Main Menu.

## Feedback Key

- `●` (`+` in `NO_COLOR` mode): **Exact** — right color in the right position
- `◐` (`~` in `NO_COLOR` mode): **Misplaced** — right color in the wrong position
- `·` (`.` in `NO_COLOR` mode): **Miss** — color not in the secret code

## Development

Run RuboCop (including `rubocop-performance`) to check code style and Ruby 3.4 compliance:

```bash
bundle exec rubocop
```
