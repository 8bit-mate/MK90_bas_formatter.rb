# frozen_string_literal: true

require_relative "MK90_bas_formatter/version"
require_relative "MK90_bas_formatter/minificator"
require_relative "MK90_bas_formatter/basic_statement"

#
# Provides methods to format output from the MK90_bas_img_generator gem to a valid executable MK90 BASIC code.
#
class MK90BasFormatter
  attr_reader :statements, :formatter

  #
  # @param [Array< Hash{ Symbol => Object }>] statements
  #   List of BASIC statements and their properties.
  #
  # @param [Symbol] formatter (Minificator)
  #   Formatter method name.
  #
  def initialize(statements:, formatter: Minificator, **kwargs)
    @statements = statements
    @formatter = formatter

    @line_num_step = 1
    @first_line_offset = 1

    if kwargs[:line_num_step]
      @line_num_step = kwargs[:line_num_step]
    elsif kwargs[:first_line_offset]
      @first_line_offset = kwargs[:first_line_offset]
    end
  end

  #
  # Format BASIC statements into executable BASIC code.
  #
  def format
    statements = _array_of_hash_to_bs(@statements)
    formatter.format(
      statements: statements,
      line_num_step: @line_num_step,
      first_line_offset: @first_line_offset
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
