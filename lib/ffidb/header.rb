# This is free and unencumbered software released into the public domain.

require 'pathname'

module FFIDB
  class Header < ::Struct.new(:name, :comment, :functions, keyword_init: true)
    include Comparable

    ##
    # @param  [Header] other
    # @return [Integer]
    def <=>(other)
      self.name <=> other.name
    end
  end # Header
end # FFIDB
