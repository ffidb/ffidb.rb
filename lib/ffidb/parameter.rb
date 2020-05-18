# This is free and unencumbered software released into the public domain.

require_relative 'type'

module FFIDB
  class Parameter < ::Struct.new(:name, :type)
    include Comparable

    ##
    # @param  [Symbol, #to_sym] name
    # @param  [Type] type
    def initialize(name, type = nil)
      super(name.to_sym, type ? Type.for(type) : nil)
    end

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
    # @return [Hash<Symbol, Type>]
    def to_h
      {self.name => self.type}
    end
  end # Parameter
end # FFIDB
