# This is free and unencumbered software released into the public domain.

require_relative 'symbol_table'

require 'pathname'

module FFIDB
  class Header < ::Struct.new(:name, :comment, :typedefs, :enums, :structs, :unions, :functions, keyword_init: true)
    include SymbolTable
    include Comparable

    ##
    # @param  [Header] other
    # @return [Integer]
    def <=>(other)
      self.name <=> other.name
    end
  end # Header
end # FFIDB
