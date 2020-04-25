# This is free and unencumbered software released into the public domain.

module FFIDB
  class Parameter < Struct.new(:name, :type, keyword_init: true)
    include Comparable

    ##
    # @param  [Parameter] other
    # @return [Integer]
    def <=>(other)
      self.name <=> other.name
    end

    ##
    # @return [String]
    def to_s
      "#{self.name}: #{self.type}"
    end

    ##
    # @return [Hash<Symbol, String>]
    def to_h
      {self.name => self.type}
    end
  end # Parameter
end # FFIDB
