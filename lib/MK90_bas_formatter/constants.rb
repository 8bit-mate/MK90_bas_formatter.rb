# frozen_string_literal: true

#
# Global constants.
#
module Constants
  MAX_CHARS_PER_LINE = 80 # Max. characters per BASIC line, defined by the MK90 software.

  DEF_SEPARATOR = ":"     # Default separator between BASIC statements.
  EMPTY_SEPARATOR = ""    # Empty separator - used between a line number and the first statement in a line.

  DEF_LINE_OFFSET = 1     # Default first line offset.
  DEF_LINE_STEP = 1       # Default step between two neighbor BASIC line numbers.
end
