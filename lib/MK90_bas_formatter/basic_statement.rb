# frozen_string_literal: true

#
# Stores BASIC statements (operators).
#
class BasicStatement
  #
  # Initialize an instance, use hash keys-values to create and initialize corresponding object fields.
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
