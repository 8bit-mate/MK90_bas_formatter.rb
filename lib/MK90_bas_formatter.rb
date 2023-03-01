# frozen_string_literal: true

require_relative "MK90_bas_formatter/version"
require_relative "MK90_bas_formatter/minificator"
require_relative "MK90_bas_formatter/basic_statement"
require_relative "MK90_bas_formatter/constants"

#
# Formats output from the MK90_bas_img_generator gem to a valid executable MK90 BASIC code.
#
class MK90BasFormatter
  attr_reader :statements, :formatter

  include Constants

  #
  # Initialize a MK90BasFormatter instance.
  #
  # @param [Array< Hash{ Symbol => Object }>] statements
  #   List of BASIC statements and their properties.
  #
  # @param [Object] formatter (Minificator.new)
  #   Formatter instance.
  #
  # @option [Integer] line_step (Constants::DEF_LINE_STEP)
  #   Step between two neighbor BASIC line numbers.
  #
  # @option [Integer] line_offset (Constants::DEF_LINE_OFFSET)
  #   The offset to start the first line at.
  #
  def initialize(
    statements:,
    formatter: Minificator.new,
    line_step: DEF_LINE_STEP,
    line_offset: DEF_LINE_OFFSET,
    **
  )
    @statements = statements
    @formatter = formatter
    @line_step = line_step
    @line_offset = line_offset
  end

  #
  # Format BASIC statements into executable BASIC code.
  #
  def format
    statements = _array_of_hash_to_bs(@statements)
    formatter.format(
      statements: statements,
      line_step: @line_step,
      line_offset: @line_offset
    )
  end

  private

  #
  # Convert Array<Hash> to Array<BasicStatement>.
  #
  def _array_of_hash_to_bs(obj)
    obj.map { |e| BasicStatement.new(e) }
  end
end
