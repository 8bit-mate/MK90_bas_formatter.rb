# frozen_string_literal: true

require_relative "minificator_position"
require_relative "handle_placeholders"
require_relative "constants"

require "logger"

#
# Set of methods to add a BASIC statement to the BASIC script.
#
module MinificatorAdder
  include HandlePlaceholders
  include Constants

  #
  # Add a BASIC statement (operator) to the BASIC script.
  #
  # @param [BasicStatement] operator
  #   An operator to be added to the BASIC script.
  #
  # @param [Hash{ Symbol => Object }] line_args
  #   Line numbers options.
  #
  # @option line_args [Integer] :line_step (Constants::DEF_LINE_STEP)
  #   Step between two neighbor BASIC line numbers.
  #
  # @option line_args [Integer] :line_offset (Constants::DEF_LINE_OFFSET)
  #   The offset to start the first line at.
  #
  # @return [Array<String>] self
  #   The formatted executable BASIC script. Each element is a single numbered line of BASIC code.
  #
  def add_operator(operator, line_args = { line_step: DEF_LINE_STEP, line_offset: DEF_LINE_OFFSET })
    pos_params = MinificatorPosition.new(operator, line_args, length)

    if operator.sliceable
      _add_sliceable_operator(operator, pos_params)
    else
      _add_solid_operator(operator, pos_params)
    end

    self
  end

  private

  #
  # Add a 'solid' (i.e. unsliceable) statement to the BASIC code.
  #
  # A 'solid' statement is a statement that should be written in a single line. It cannot be splitted into parts.
  # Therefore, if a statement doesn't fit in the current line, a new line is added, and a statement placed there.
  #
  # @param [BasicStatement] op_obj
  #   Describes a single 'solid' BASIC statement to be added to the BASIC code.
  #
  # @param [Hash{ Symbol => Integer }] pos_params
  #   Positions in the arrays and BASIC code.
  #
  # @return [Array] self
  #   Current state of the formatted BASIC code.
  #
  def _add_solid_operator(op_obj, pos_params)
    op_args = handle_placeholders(op_obj, pos_params)

    new_operator = op_obj.keyword + op_args.join(op_obj.separator)

    logger = Logger.new($stdout)

    if new_operator.length > MAX_CHARS_PER_LINE
      msg = "String '#{new_operator}' is not sliceable, but exceeds '#{MAX_CHARS_PER_LINE}' characters"
      logger.warn(msg)
    end

    separator_btw_operators = _choose_separator(pos_params.index)
    _mark_new_line(pos_params.index, pos_params.i_line)

    tmp_string = self[pos_params.index] + separator_btw_operators + new_operator

    if tmp_string.length <= MAX_CHARS_PER_LINE
      self[pos_params.index] = tmp_string
    else
      pos_params.upd_new_line
      self[pos_params.index] = pos_params.i_line.to_s + new_operator
    end
    self
  end

  #
  # Add a 'sliceable' statement to the BASIC code.
  #
  # A 'sliceable' statement is a statement those agruments can be split and continued onto a following line. E.g.:
  #
  #   10 DATA 100, 200
  # =>
  #   10 DATA 100
  #   20 DATA 200
  #
  # @param [BasicStatement] op_obj
  #   Describes a single 'sliceable' BASIC statement to be added to the BASIC code.
  #
  # @param [Hash{ Symbol => Integer }] pos_params
  #   Positions in the arrays and BASIC code.
  #
  # @return [Array] self
  #   Current state of the formatted BASIC code.
  #
  def _add_sliceable_operator(op_obj, pos_params)
    args_left = op_obj.args

    while true
      separator_btw_operators = _choose_separator(pos_params.index)
      _mark_new_line(pos_params.index, pos_params.i_line)

      current_line = self[pos_params.index]
      fit_results = _fit_arguments(current_line, op_obj, separator_btw_operators)

      args_fit = fit_results[:args_fit]
      args_left = fit_results[:args_left]

      case args_fit
      when nil
        # args_fit == nil indicates that no arguments could be added to a current line - update index and continue to
        # append arguments on a new line.
        pos_params.upd_new_line
      else
        # Add statement with arguments that fit into the current BASIC line.
        self[pos_params.index] =
          self[pos_params.index] <<
          separator_btw_operators <<
          op_obj.keyword <<
          args_fit.join(op_obj.separator)

        case args_left
        when []
          # args_left == [] indicates that all arguments of a current operator were added to the BASIC code, so job is
          # done. Break from the loop.
          break
        else
          # Some arguments are left to be added - update index and continue to append arguments on a new line.
          pos_params.upd_new_line
        end
      end
    end

    self
  end

  #
  # Calculate all possible combinations of a current BASIC statement's length.
  #
  # @param [Hash{ Symbol => Integer }] pos_params
  #   Positions in the arrays and BASIC code.
  #
  # @param [String] separator_btw_operators0
  #   Separator between_operators.
  #
  def _calc_lengths_combinations(op_obj, separator_btw_operators)
    lengths_combinations = []

    op_obj.args.each_with_index do |_e, i|
      array_chunk = op_obj.args.slice(0..i)
      sep_count = array_chunk.length - 1 # number of separators that will apear between operator's arguments

      statement_full_length = _calc_statement_length(
        keyword_length: op_obj.keyword.length,
        current_args_length: array_chunk.join("").length,
        args_sep_count: sep_count,
        args_sep_length: op_obj.separator.length,
        statement_sep_length: separator_btw_operators.length
      )
      
      lengths_combinations.append(statement_full_length)
    end
    lengths_combinations
  end

  #
  # Calculate total length of a new BASIC statement (with an i-th set of arguments).
  #
  # @param [Integer] keyword_length
  #   Length of the statement keyword.
  #
  # @param [Integer] current_args_length
  #   Sum of lengths of arguments on a current iteration.
  #
  # @param [Integer] args_sep_count
  #   Number of separators that will apear between operator's arguments.
  #
  # @param [Integer] args_sep_length
  #   Legth of the separator between operator's arguments.
  #
  # @param [Integer] statement_sep_length
  #   Legth of the separator between statements.
  #
  def _calc_statement_length(
    keyword_length:,
    current_args_length:,
    args_sep_count:,
    args_sep_length:,
    statement_sep_length:
  )
    keyword_length + current_args_length + args_sep_count * args_sep_length + statement_sep_length
  end

  #
  # Check if a current BASIC line (self[index] element) is empty (nil) or not (initialized), and choose an appropriate
  # separator for a next statement.
  #
  # @param [Integer] index
  #   Current position in the [Array] self.
  #
  # @return [String]
  #   A chosen separator.
  #
  def _choose_separator(index)
    self[index].nil? ? EMPTY_SEPARATOR : DEF_SEPARATOR
  end

  #
  # Return arguments that could be added to a curent BASIC line, and arguments that are left to the next line.
  #
  # @param [Integer] current_line
  #
  # @param [BasicStatement] op_obj
  #
  # @param [String] separator_btw_operators
  #
  # @return [Hash{ Symbol => Array }]
  #   :args_fit - arguments that could be added to a current BASIC line;
  #   :args_left - arguments left to be processed.
  #
  def _fit_arguments(current_line, op_obj, separator_btw_operators)
    # Calculate free space left in a current BASIC line:
    free_space = MAX_CHARS_PER_LINE - current_line.length

    args = op_obj.args

    lengths_combinations = _calc_lengths_combinations(op_obj, separator_btw_operators)

    lengths_combinations_desc = lengths_combinations.sort { |a, b| b <=> a }

    f_e = lengths_combinations_desc.bsearch { |e| e <= free_space }

    return { args_fit: nil, args_left: args } if f_e.nil?

    b_inx = lengths_combinations.index(f_e)

    args_fit = args.slice!(0..b_inx)
    { args_fit: args_fit, args_left: args }
  end

  #
  # Check if a current BASIC line (self[index] element) is empty (nil). If true, mark new line with a number.
  #
  # @param [Integer] index
  #   Current position in the [Array] self.
  #
  # @param [Integer] i_line
  #   Current BASIC line.
  #
  # @return [String]
  #   A chosen separator.
  #
  def _mark_new_line(index, i_line)
    self[index] = i_line.to_s if self[index].nil?
  end
end
