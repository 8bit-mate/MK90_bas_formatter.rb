# frozen_string_literal: true

require_relative "MK90_bas_formatter/version"
require_relative "MK90_bas_formatter/minificator"


class MK90BasFormatter
  attr_reader :statements, :formatter

  def initialize(statements, formatter = Minificator)
    @statements = statements
    @formatter = formatter
  end

  #
  # Formats BASIC statements into executable BASIC code.
  #
  def format
    formatter.format(statements)
  end
end
