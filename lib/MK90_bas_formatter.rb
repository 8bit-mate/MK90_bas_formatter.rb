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
  def initialize(statements, formatter = Minificator)
    @statements = statements
    @formatter = formatter
  end

  #
  # Format BASIC statements into executable BASIC code.
  #
  def format
    statements = array_of_hash_to_bs(@statements)
    formatter.format(statements)
  end

  #
  # Convert Array<Hash> to Array<BasicStatement>.
  #
  def array_of_hash_to_bs(obj)
    obj.map { |e| BasicStatement.new(e) }
  end
end
