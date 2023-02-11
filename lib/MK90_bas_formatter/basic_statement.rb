# frozen_string_literal: true

#
# Class to store BASIC statements (operators).
#
class BasicStatement
  #
  # Initialize object, use hash keys and values to create and initialize corresponding obj fields.
  #
  # @param [Hash{ Symbol => Object }] hash
  #
  def initialize(hash)
    hash.each do |k, v|
      instance_variable_set("@#{k}", v)
      self.class.send(:attr_reader, k)
    end
  end
end
