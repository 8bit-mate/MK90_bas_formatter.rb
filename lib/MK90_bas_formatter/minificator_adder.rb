# frozen_string_literal: true

require "ostruct"
require "logger"

#
# MK90 BASIC code minificator.
#
module MinificatorAdder
  MAX_CHARS_PER_LINE = 80
  CURRENT_LINE_LBL = "#current_line"

  DEF_SEPARATOR = ":"
  EMPTY_SEPARATOR = ""

  DEF_LINE_OFFSET = 1
  DEF_LINE_STEP = 1

  #
  # Add a BASIC statement (operator) to the script.
  #
  # @param [BasicStatement] operator
  #   An operator to be added to the BASIC code.
  #
  # @param [Hash{ Symbol => Object }] line_args
  #   Line numbers options.
  #
  # @option line_args [Integer] :line_num_step (DEF_LINE_STEP)
  #   Step between two neighbor lines.
  #
  # @option line_args [Integer] :first_line_offset (DEF_LINE_OFFSET)
  #   The offset to start the first line at.
  #
  # @return [Array<String>] self
  #   The formatted executable BASIC code. Each element is a single numbered line of BASIC code.
  #
  def add_operator(operator, line_args = {line_num_step: DEF_LINE_STEP, first_line_offset: DEF_LINE_OFFSET})
    n_arg = operator.args.length
    n_arg_left = n_arg

    line_num_step = line_args[:line_num_step]
    first_line_offset = line_args[:first_line_offset]

    index = length - 1
    index += 1 if operator.require_nl

    i_line = first_line_offset + index * line_num_step

    pos_params = {
      index: index,                 # current position in the array
      i_line: i_line,               # current BASIC line number
      n_arg: n_arg,                 # number of arguments in operator.args
      n_arg_left: n_arg_left,       # number of arguments left to process
      line_num_step: line_num_step  # step between two neighbor lines
    }

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
    e = OpenStruct.new(pos_params)

    placeholders_values = { current_line_num: e.i_line }
    op_args = _put_placeholders_values(op_obj.args, placeholders_values)

    new_operator = op_obj.keyword + op_args.join(op_obj.separator)

    logger = Logger.new($stdout)

    if new_operator.length > MAX_CHARS_PER_LINE
      msg = "String '#{new_operator}' is not sliceable, but exceeds '#{MAX_CHARS_PER_LINE}' characters"
      logger.warn(msg)
    end

    separator_btw_operators = _check_empty_line(e.index, e.i_line)

    tmp_string = self[e.index] + separator_btw_operators + new_operator

    if tmp_string.length <= MAX_CHARS_PER_LINE
      self[e.index] = tmp_string
    else
      e.index = e.index + 1
      e.i_line = e.i_line + e.line_num_step
      self[e.index] = e.i_line.to_s + new_operator
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
    e = OpenStruct.new(pos_params)

    args_left = op_obj.args

    while true
      separator_btw_operators = _check_empty_line(e.index, e.i_line)

      current_line = self[e.index]
      fit_results = _fit_arguments(current_line, op_obj, separator_btw_operators)

      args_fit = fit_results[:args_fit]
      args_left = fit_results[:args_left]

      case args_fit
      when nil
        # args_fit == nil indicates that no arguments could be added to a current line. In this case it's required to
        # update the index and start a new BASIC line.
        e.index += 1
        e.i_line += e.line_num_step
      else
        # Add statement with arguments that fit into the current BASIC line.
        self[e.index] = self[e.index] << separator_btw_operators << op_obj.keyword << args_fit.join(op_obj.separator)

        case args_left
        when []
          # args_left == [] indicates that all arguments of a current operator were added to the BASIC code, so job is
          # done. Break from the loop.
          break
        else
          # Some arguments are left to be added
          e.index += 1
          e.i_line += e.line_num_step
        end
      end
    end

    self
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
  #   :args_left - arguments left.
  #
  def _fit_arguments(current_line, op_obj, separator_btw_operators)
    # calculate free space left in a current BASIC line:
    free_space = MAX_CHARS_PER_LINE - current_line.length

    args = op_obj.args

    lengths_combinations = calc_lengths_combinations(op_obj, separator_btw_operators)

    lengths_combinations_desc = lengths_combinations.sort { |a, b| b <=> a }

    f_e = lengths_combinations_desc.bsearch { |e| e <= free_space }

    return { args_fit: nil, args_left: args } if f_e.nil?

    b_inx = lengths_combinations.index(f_e)

    args_fit = args.slice!(0..b_inx)
    { args_fit: args_fit, args_left: args }
  end

  #
  # 
  #
  def calc_lengths_combinations(op_obj, separator_btw_operators)
    lengths_combinations = []

    op_obj.args.each_with_index do |_e, i|
      array_chunk = op_obj.args.slice(0..i)
      sep_count = array_chunk.length - 1 # how many separators will apear between operator's arguments

      # calculate full length of a new BASIC statement:
      full_length =
        op_obj.keyword.length +
        array_chunk.join("").length +
        sep_count * op_obj.separator.length +
        separator_btw_operators.length

      lengths_combinations.append(full_length)
    end
    lengths_combinations
  end

  #
  # Check if a current BASIC line (self[index] element) is empty (nil) or not (initialized), and choose an appropriate
  # separator for a next statement.
  #
  # If nil: mark a line with a number, and use an 'empty' separator to append a next statement (a separator between
  # a line number and a statement that follows it is not required).
  #
  # Else: use a default separator (a colon).
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
  def _check_empty_line(index, i_line)
    case self[index]
    when nil
      self[index] = i_line.to_s
      EMPTY_SEPARATOR
    else
      DEF_SEPARATOR
    end
  end

  #
  # Replace placeholders with actual values.
  #
  # @param [Array] array
  #   Array those elements should be processed.
  #
  # @param [Hash{ Symbol => String }] values
  #   Actual values to replace placeholders with.
  #
  # @output [Array]
  #
  def _put_placeholders_values(array, values)
    _stringify_hash_elements(values)
    array.map! { |e| e.to_s % values }
  end

  #
  # Convert hash values to strings.
  #
  # @param [Hash] hash
  #
  # @output [Hash]
  #
  def _stringify_hash_elements(hash)
    hash.transform_values!(&:to_s)
  end
end
