# frozen_string_literal: true

require "quecto_calc"

#
# A two-step generation is used to generate an executable BASIC script: first the 'MK90_bas_img_generator' is used to
# generate list of BASIC statements; then 'MK90_bas_formatter' is used to format list of statements into valid numbered
# BASIC lines. That means that during the first step BASIC lines numbers are undefined yet, but they still might appear
# in statements like N GOTO N, where N is the current line number. Only during the 2nd step (while formatting statements
# into a BASIC script) the calculation of the N number becomes possible.
#
# To handle this 'MK90_bas_img_generator' uses placeholders, and the task here is to find these placeholders and replace
# them with the actual values.
#
# Placeholders also could be used with a simple expressions like: N GOTO N + m (jump to a line that is m lines away from
# the current one). This expressions should be evaluated before placed in the actual script.
#
# To do so it is required to search for a string that starts with a 'magick' character 'PLACEHOLDER_CHAR'. Then the
# string should be parsed to find out if it actually has a placeholder (and optionally an expression associated with
# it). If a placeholder found: replace placeholder with the actual value.
#
module HandlePlaceholders
  PLACEHOLDER_CHAR = "%"
  CURRENT_LINE_LBL = "current_line"

  #
  # @param [BasicStatement] op_obj
  #
  # @param [MinificatorPosition] pos_params
  #
  # @return [Array]
  #
  def handle_placeholders(op_obj, pos_params)
    op_obj.args.map do |arg|
      str = arg.to_s
      current_line = pos_params.i_line

      case str.chars.first
      when PLACEHOLDER_CHAR
        str_to_eval = str.delete_prefix(PLACEHOLDER_CHAR)
        eval_result = _eval_expr(str_to_eval, current_line)
        eval_result || arg
      else
        arg
      end
    end
  end

  private

  #
  # Evaluate an expression with a placeholder.
  #
  # @param [String] str
  #   Expression to evaluate.
  #
  # @param [Integer] current_line
  #   Current BASIC line number.
  #
  # @return [Integer, nil]
  #
  def _eval_expr(str, current_line)
    calc = QuectoCalc.new
    calc.evaluate(str, { CURRENT_LINE_LBL => current_line })
  end
end
