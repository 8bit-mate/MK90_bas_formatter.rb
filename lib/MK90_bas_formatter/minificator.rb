# frozen_string_literal: true

require_relative "minificator_adder"

#
# Elektronika MK90/DEC PDP-11 BASIC minificator.
#
class Minificator
  INIT_STATEMENTS_ARR_LENGTH = 1 # Initial statements array length.

  #
  # Format array of BASIC statements to an executable BASIC code with numbered lines. Each line stores as many BASIC
  # statements (operators) as possible. There are no spaces between operators and/or its operands, as BASIC's lexer
  # simply ignores spaces (hence there's no need to store them).
  #
  # These features help to reduce size of the BASIC code.
  #
  # @param [Array<BasicStatement>] statements
  #   List of BASIC statements and their properties.
  #
  # @param [Integer] line_step
  #   Step between two neighbor BASIC line numbers.
  #
  # @param [Integer] line_offset
  #   The offset to start the first line at.
  #
  # @return [Array] formatted_script
  #   The formatted executable BASIC code.
  #
  def format(statements:, line_step:, line_offset:)
    formatted_script = Array.new(INIT_STATEMENTS_ARR_LENGTH)
    formatted_script.extend(MinificatorAdder)

    line_args = { line_step: line_step, line_offset: line_offset }

    statements.each do |e|
      formatted_script.add_operator(e, line_args)
    end

    formatted_script
  end
end
