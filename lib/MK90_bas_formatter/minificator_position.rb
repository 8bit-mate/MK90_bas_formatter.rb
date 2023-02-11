# frozen_string_literal: true

#
# Stores positions.
#
class MinificatorPosition
  attr_accessor :index, :i_line, :n_arg_total, :n_arg_left, :line_num_step

  def initialize(index:, i_line:, n_arg_total:, n_arg_left:, line_num_step:)
    @index = index                  # current position in the array
    @i_line = i_line                # current BASIC line number
    @n_arg_total = n_arg_total      # number of arguments in operator.args
    @n_arg_left = n_arg_left        # number of arguments left to process
    @line_num_step = line_num_step  # step between two neighbor lines
  end
end
