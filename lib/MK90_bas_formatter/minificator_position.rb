# frozen_string_literal: true

#
# Stores positions in the script array.
#
class MinificatorPosition
  attr_accessor :index, :i_line, :n_arg_total, :n_arg_left, :line_step

  #
  # Initialize an instance.
  #
  # @param [BasicStatement] operator
  #
  # @param [Hash{ Symbol => Integer }] line_args
  #
  # @param [Integer] length
  #
  def initialize(operator, line_args, length)
    n_arg = operator.args.length
    n_arg_left = n_arg

    line_step = line_args[:line_step]
    line_offset = line_args[:line_offset]

    index = length - 1
    index += 1 if operator.require_nl

    i_line = line_offset + index * line_step

    @index = index                  # current position in the array
    @i_line = i_line                # current BASIC line number
    @n_arg_total = n_arg_total      # number of arguments in operator.args
    @n_arg_left = n_arg_left        # number of arguments left to process
    @line_step = line_step  # step between two neighbor lines
  end

  #
  # Update index and current line number to append a new BASIC line.
  #
  def upd_new_line
    @index += 1
    @i_line += @line_step
  end
end
