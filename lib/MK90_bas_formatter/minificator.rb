# frozen_string_literal: true

#
# MK90/DEC PDP-11 BASIC code minificator.
#
class Minificator
  #
  # Formats array of BASIC statements to an executable BASIC code with numbered lines. Each line stores as many
  # statements (operators) as possible. There are no spaces between operators and/or its operands, as BASIC's lexer
  # simply ignores spaces (hence there's no need to store them).
  #
  # These features help to reduce size of the BASIC code.
  #
  # @return [Array] formatted_script
  #   The formatted executable BASIC code.
  #
  def format(statements)
    puts "formatting.."

    formatted_script = "placeholder"
    formatted_script
  end

  private

  #
  # Checks if obj is an array.
  #
  # @param [Object] obj
  #   Object to check.
  #
  # @raise [TypeError]
  #
  def _array?(obj)
    case obj
    when Array
      true
    else
      raise(TypeError, "wrong argument type #{obj.class} (expected Array)")
    end
  end
end
